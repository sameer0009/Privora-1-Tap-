import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('CONFIGURATION')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildToggleTile(theme, Icons.wifi_tethering, 'LOCAL MODE', 'Connect via Wi-Fi Direct / Bluetooth', true),
          _buildToggleTile(theme, Icons.language, 'INTERNET MODE', 'Route via encrypted relay', true),
          _buildToggleTile(theme, Icons.auto_mode, 'AUTO MODE', 'Seamless failover to relay', true),
          const Divider(height: 48, color: Colors.white10),
          _buildActionTile(theme, Icons.notifications_none, 'NOTIFICATIONS', 'Configure alerts'),
          _buildActionTile(theme, Icons.storage_outlined, 'DATA & STORAGE', 'Clear local cache'),
          _buildActionTile(theme, Icons.language_outlined, 'LANGUAGE', 'English (US)'),
          const SizedBox(height: 24),
          _buildActionTile(theme, Icons.info_outline, 'ABOUT PRIVORA', 'Build v1.0.0-PROD'),
        ],
      ),
    );
  }

  Widget _buildToggleTile(ThemeData theme, IconData icon, String title, String subtitle, bool value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: theme.textTheme.bodyMedium),
        value: value,
        onChanged: (val) {},
        activeColor: theme.colorScheme.primary,
        dense: true,
      ),
    );
  }

  Widget _buildActionTile(ThemeData theme, IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: theme.textTheme.bodyMedium),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: () {},
    );
  }
}
