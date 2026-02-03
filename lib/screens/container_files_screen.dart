import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_portainer_flutter/l10n/app_localizations.dart';
import 'package:mobile_portainer_flutter/utils/notify_utils.dart';
import '../services/docker_service.dart';
import '../models/container_file.dart';

import '../screens/file_content_screen.dart';

class ContainerFilesScreen extends StatefulWidget {
  final String containerId;
  final String containerName;
  final String apiUrl;
  final String apiKey;
  final bool ignoreSsl;

  const ContainerFilesScreen({
    super.key,
    required this.containerId,
    required this.containerName,
    required this.apiUrl,
    required this.apiKey,
    this.ignoreSsl = false,
  });

  @override
  State<ContainerFilesScreen> createState() => _ContainerFilesScreenState();
}

class _ContainerFilesScreenState extends State<ContainerFilesScreen> {
  bool _isLoading = true;
  String? _error;
  List<ContainerFile> _files = [];
  String _currentPath = '/';

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _files = [];
    });

    final service = DockerService(
      baseUrl: widget.apiUrl,
      apiKey: widget.apiKey,
      ignoreSsl: widget.ignoreSsl,
    );

    try {
      final files = await service.getContainerFiles(widget.containerId, path: _currentPath);
      // Sort: Directories first, then files. Alphabetically.
      files.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      
      if (!mounted) return;
      setState(() {
        _files = files;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openFile(ContainerFile file) async {
    // Construct the full path
    final fullPath = _currentPath == '/' ? '/${file.name}' : '$_currentPath/${file.name}';
    
    setState(() {
      _isLoading = true;
    });

    final service = DockerService(
      baseUrl: widget.apiUrl,
      apiKey: widget.apiKey,
      ignoreSsl: widget.ignoreSsl,
    );

    try {
      final content = await service.getContainerFileContent(widget.containerId, fullPath);
      
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FileContentScreen(
            containerId: widget.containerId,
            filePath: fullPath,
            initialContent: content,
            apiUrl: widget.apiUrl,
            apiKey: widget.apiKey,
            ignoreSsl: widget.ignoreSsl,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      NotifyUtils.showNotify(context, 'Error reading file: $e');
    }
  }

  void _navigateTo(String directoryName) {
    setState(() {
      if (_currentPath == '/') {
        _currentPath = '/$directoryName';
      } else {
        _currentPath = '$_currentPath/$directoryName';
      }
    });
    _fetchFiles();
  }

  void _navigateUp() {
    if (_currentPath == '/') return;
    
    final parts = _currentPath.split('/');
    if (parts.length <= 2) {
      // empty, "", "dir" -> remove last
      setState(() {
        _currentPath = '/';
      });
    } else {
      parts.removeLast();
      setState(() {
        _currentPath = parts.join('/');
      });
    }
    _fetchFiles();
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPath),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchFiles,
          ),
        ],
      ),
      body: _buildBody(t),
    );
  }

  Widget _buildBody(AppLocalizations t) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                t.msgErrorLoadingFiles,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchFiles,
                child: Text(t.msgRetry),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: _currentPath == '/',
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _navigateUp();
      },
      child: ListView.separated(
        itemCount: _files.length + (_currentPath == '/' ? 0 : 1),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (_currentPath != '/' && index == 0) {
            return ListTile(
              leading: const Icon(Icons.folder, color: Colors.blue),
              title: const Text('..'),
              onTap: _navigateUp,
            );
          }

          final file = _files[_currentPath == '/' ? index : index - 1];
          return _buildFileItem(file);
        },
      ),
    );
  }

  Widget _buildFileItem(ContainerFile file) {
    IconData icon;
    Color iconColor;
    final t = AppLocalizations.of(context)!;

    if (file.isDirectory) {
      icon = Icons.folder;
      iconColor = Colors.blue;
    } else {
      icon = Icons.insert_drive_file;
      iconColor = Colors.grey;
    }

    if (file.isSymlink) {
      // Maybe overlay a small arrow or just change icon
      icon = Icons.shortcut;
    }

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Row(
        children: [
          Expanded(child: Text(file.name)),
          if (file.isMounted)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: .1),
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                t.labelMounted,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        '${file.isDirectory ? '-' : _formatSize(file.size)} | ${_formatDate(file.modifiedDate)}',
        style: const TextStyle(fontSize: 12),
      ),
      onTap: file.isDirectory
          ? () => _navigateTo(file.name)
          : () => _openFile(file),
    );
  }
}
