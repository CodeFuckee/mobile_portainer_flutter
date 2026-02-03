import 'package:flutter/material.dart';
import 'package:mobile_portainer_flutter/l10n/app_localizations.dart';
import '../services/docker_service.dart';

class VolumeDetailsScreen extends StatefulWidget {
  final String volumeName;
  final String apiUrl;
  final String apiKey;
  final bool ignoreSsl;

  const VolumeDetailsScreen({
    super.key,
    required this.volumeName,
    required this.apiUrl,
    required this.apiKey,
    this.ignoreSsl = false,
  });

  @override
  State<VolumeDetailsScreen> createState() => _VolumeDetailsScreenState();
}

class _VolumeDetailsScreenState extends State<VolumeDetailsScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _volumeDetails;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final service = DockerService(baseUrl: widget.apiUrl, apiKey: widget.apiKey, ignoreSsl: widget.ignoreSsl);
    try {
      final details = await service.getVolume(widget.volumeName);
      setState(() {
        _volumeDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.volumeName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDetails,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(t.msgCurrentApi(widget.apiUrl), style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchDetails,
              child: Text(t.msgRetry),
            ),
          ],
        ),
      );
    }

    if (_volumeDetails == null) {
      return const Center(child: Text('No details available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(t),
          const SizedBox(height: 16),
          if (_volumeDetails!['Labels'] != null && (_volumeDetails!['Labels'] as Map).isNotEmpty)
            _buildLabelsCard(t, _volumeDetails!['Labels']),
           if (_volumeDetails!['Options'] != null && (_volumeDetails!['Options'] as Map).isNotEmpty)
            _buildOptionsCard(t, _volumeDetails!['Options']),
        ],
      ),
    );
  }

  Widget _buildInfoCard(AppLocalizations t) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(t.labelDriver, _volumeDetails!['Driver'] ?? ''),
            const Divider(),
            _buildInfoRow(t.labelScope, _volumeDetails!['Scope'] ?? ''),
            const Divider(),
            _buildInfoRow(t.labelCreated, _volumeDetails!['CreatedAt'] ?? ''),
            const Divider(),
            _buildInfoRow(t.labelMountpoint, _volumeDetails!['Mountpoint'] ?? '', isMonospace: true),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelsCard(AppLocalizations t, Map<String, dynamic> labels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.labelLabels, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: labels.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: SelectableText(e.value.toString()),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsCard(AppLocalizations t, Map<String, dynamic> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(t.labelOptions, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: options.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: SelectableText(e.value.toString()),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isMonospace = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontFamily: isMonospace ? 'monospace' : null,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
