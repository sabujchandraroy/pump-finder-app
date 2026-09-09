import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../app/settings/app_settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark mode'),
                  subtitle: const Text('Use a dark theme throughout the app'),
                  value: settings.isDarkMode,
                  onChanged: settings.setDarkMode,
                ),
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.tune),
                  title: const Text('Compact map controls'),
                  subtitle: const Text('Use a smaller control layout on the map'),
                  value: settings.compactMapControls,
                  onChanged: settings.setCompactMapControls,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Reset settings'),
              subtitle: const Text('Restore the default app preferences'),
              onTap: () async {
                await settings.reset();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings reset.')),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '${AppConstants.appName}\nVersion 1.0.0',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
