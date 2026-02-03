import 'package:flutter/material.dart';
import 'package:mobile_portainer_flutter/l10n/app_localizations.dart';
import 'package:mobile_portainer_flutter/utils/notify_utils.dart';
import 'images_screen.dart';
import 'networks_screen.dart';
import 'stacks_screen.dart';
import 'volumes_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/docker_service.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    
    final items = [
      _ResourceItem(
        title: t.titleImages,
        icon: Icons.layers,
        color: Colors.purple,
        screen: const ImagesScreen(),
        hasFab: true,
      ),
      _ResourceItem(
        title: t.titleNetworks,
        icon: Icons.hub,
        color: Colors.orange,
        screen: const NetworksScreen(),
      ),
      _ResourceItem(
        title: t.titleStacks,
        icon: Icons.apps,
        color: Colors.teal,
        screen: const StacksScreen(),
      ),
      _ResourceItem(
        title: t.titleVolumes,
        icon: Icons.storage,
        color: Colors.brown,
        screen: const VolumesScreen(),
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: item.color, size: 28),
            ),
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: Text(item.title),
                    ),
                    body: item.screen,
                    floatingActionButton: item.hasFab
                        ? FloatingActionButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(36),
                            ),
                            onPressed: () => _showPullImageDialog(context),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: const Icon(Icons.add, color: Colors.white, size: 28),
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showPullImageDialog(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final tagController = TextEditingController(text: 'latest');

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t.titlePullImage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: t.labelImageName,
                  hintText: t.hintImageName,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tagController,
                decoration: InputDecoration(
                  labelText: t.labelTag,
                  hintText: t.hintTag,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t.actionCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final tag = tagController.text.trim().isEmpty
                    ? 'latest'
                    : tagController.text.trim();
                Navigator.pop(dialogContext);
                if (name.isEmpty) {
                  NotifyUtils.showNotify(context, t.msgImageNameRequired);
                  return;
                }

                try {
                  final prefs = await SharedPreferences.getInstance();
                  final url =
                      prefs.getString('docker_api_url') ??
                      'http://10.0.2.2:8000';
                  final apiKey = prefs.getString('docker_api_key') ?? '';
                  final ignoreSsl = prefs.getString('docker_ignore_ssl') == 'true';
                  final service = DockerService(baseUrl: url, apiKey: apiKey, ignoreSsl: ignoreSsl);
                  final result = await service.pullImage(name, tag);

                  if (!context.mounted) return;

                  final message = result['message']?.toString() ?? t.msgImagePullSuccess;
                  NotifyUtils.showNotify(context, message);
                  // Note: Auto-refresh of the list isn't easily possible here without a key.
                  // The user will see the success message and can pull-to-refresh.
                } catch (e) {
                  if (!context.mounted) return;
                  final errMsg = t.msgImagePullFailed(e.toString());
                  NotifyUtils.showNotify(context, errMsg);
                }
              },
              child: Text(t.buttonPull),
            ),
          ],
        );
      },
    );
  }
}

class _ResourceItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget screen;
  final bool hasFab;

  _ResourceItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.screen,
    this.hasFab = false,
  });
}
