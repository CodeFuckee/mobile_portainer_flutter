import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_portainer_flutter/l10n/app_localizations.dart';
import 'package:mobile_portainer_flutter/utils/notify_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../services/docker_service.dart';
import '../models/container_file.dart';

import '../screens/file_content_screen.dart';

class ContainerFilesScreen extends StatefulWidget {
  final String containerId;
  final String containerName;
  final String apiUrl;
  final String apiKey;
  final bool ignoreSsl;
  final bool isRunning;

  const ContainerFilesScreen({
    super.key,
    required this.containerId,
    required this.containerName,
    required this.apiUrl,
    required this.apiKey,
    this.ignoreSsl = false,
    required this.isRunning,
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

  @override
  void didUpdateWidget(ContainerFilesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      _fetchFiles();
    }
  }

  Future<void> _fetchFiles() async {
    if (!widget.isRunning) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

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

  Future<void> _shareFile(ContainerFile file) async {
    final t = AppLocalizations.of(context)!;
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
      final bytes = await service.downloadContainerFile(widget.containerId, fullPath);
      
      if (!mounted) return;

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${file.name}');
      await tempFile.writeAsBytes(bytes);
      
      setState(() {
        _isLoading = false;
      });

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tempFile.path)],
          text: 'Download ${file.name}',
        ),
      );
      
      if (result.status == ShareResultStatus.success) {
         if (mounted) NotifyUtils.showNotify(context, t.msgFileSaved);
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        NotifyUtils.showNotify(context, t.msgErrorSavingFile(e.toString()));
      }
    }
  }

  Future<void> _downloadFile(ContainerFile file) async {
    final t = AppLocalizations.of(context)!;
    final fullPath = _currentPath == '/' ? '/${file.name}' : '$_currentPath/${file.name}';
    
    // Check permissions
    bool hasPermission = false;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
         hasPermission = true; // No explicit storage permission needed for public downloads on Android 13+? Actually maybe need to use specific API, but standard file writing to Download usually works if permission is irrelevant. 
         // Actually for Android 13+ (SDK 33), READ_EXTERNAL_STORAGE is deprecated for media. WRITE_EXTERNAL_STORAGE is also deprecated.
         // We should just try to write to the Download directory.
      } else if (androidInfo.version.sdkInt >= 30) {
         // Android 11+
         // WRITE_EXTERNAL_STORAGE is ignored. We can write to app-specific dirs or use MediaStore.
         // But users want "Internal Storage".
         // Let's try to get permission.
         var status = await Permission.manageExternalStorage.status;
         if (!status.isGranted) {
           status = await Permission.manageExternalStorage.request();
         }
         hasPermission = status.isGranted;
      } else {
        // Android < 10
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        hasPermission = status.isGranted;
      }
    } else {
      hasPermission = true; // iOS/others usually handled by OS dialogs or not supported this way
    }

    if (!hasPermission) {
      if (mounted) NotifyUtils.showNotify(context, 'Storage permission denied');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final service = DockerService(
      baseUrl: widget.apiUrl,
      apiKey: widget.apiKey,
      ignoreSsl: widget.ignoreSsl,
    );

    try {
      final bytes = await service.downloadContainerFile(widget.containerId, fullPath);
      
      if (!mounted) return;

      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
        if (!downloadDir.existsSync()) {
          downloadDir = await getExternalStorageDirectory(); // Fallback
        }
      } else {
        downloadDir = await getDownloadsDirectory();
      }

      if (downloadDir == null) {
        throw Exception('Could not find download directory');
      }

      final saveFile = File('${downloadDir.path}/${file.name}');
      // Avoid overwriting?
      // Simple implementation: overwrite
      await saveFile.writeAsBytes(bytes);
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) NotifyUtils.showNotify(context, '${t.msgFileSaved}: ${saveFile.path}');
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        NotifyUtils.showNotify(context, t.msgErrorSavingFile(e.toString()));
      }
    }
  }

  void _showFileOptions(ContainerFile file) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.download),
                title: Text(t.labelDownload),
                onTap: () {
                  Navigator.pop(context);
                  _downloadFile(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: Text(t.labelShare),
                onTap: () {
                  Navigator.pop(context);
                  _shareFile(file);
                },
              ),
            ],
          ),
        );
      },
    );
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

    return _buildBody(t);
  }

  Widget _buildBody(AppLocalizations t) {
    if (!widget.isRunning) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, color: Colors.grey, size: 48),
              const SizedBox(height: 16),
              Text(
                t.msgContainerClosed,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

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

    return ListView.separated(
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
      trailing: !file.isDirectory
          ? IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showFileOptions(file),
            )
          : null,
      onTap: file.isDirectory
          ? () => _navigateTo(file.name)
          : () => _openFile(file),
    );
  }
}
