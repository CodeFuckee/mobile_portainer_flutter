// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final file = File('pubspec.yaml');
  if (!file.existsSync()) {
    print('Error: pubspec.yaml not found');
    exit(1);
  }

  final lines = file.readAsLinesSync();
  final newLines = <String>[];
  bool versionUpdated = false;

  for (final line in lines) {
    if (line.trim().startsWith('version:') && !versionUpdated) {
      final parts = line.split(':');
      if (parts.length > 1) {
        final versionString = parts[1].trim();
        // Format: x.y.z+n
        final versionParts = versionString.split('+');
        final versionNumber = versionParts[0];
        final buildNumber = versionParts.length > 1 ? versionParts[1] : '1';
        
        final semver = versionNumber.split('.');
        if (semver.length == 3) {
           try {
             int patch = int.parse(semver[2]);
             patch++;
             semver[2] = patch.toString();
             
             int build = int.tryParse(buildNumber) ?? 1;
             build++;
             
             final newVersion = '${semver.join('.')}+$build';
             newLines.add('version: $newVersion');
             print('Updated version to $newVersion');
             versionUpdated = true;
             continue;
           } catch (e) {
             print('Error parsing version: $e');
           }
        }
      }
    }
    newLines.add(line);
  }

  if (versionUpdated) {
    file.writeAsStringSync('${newLines.join('\n')}\n');
  } else {
    print('Version not found or not updated');
  }
}
