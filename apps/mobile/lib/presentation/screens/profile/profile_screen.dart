import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // In a real app, this would be a user variable from a provider
    const username = "CyberGhost_2026";
    const email = "ghost@privora.io";
    const fingerprint = "ED25:519:A3B9:00FF:6677:8899:CCDD:EEFF";

    return Scaffold(
      appBar: AppBar(title: const Text('IDENTITY VAULT')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.shield, size: 60, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 24),
              Text(username, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(email, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 40),
              _buildInfoSection(theme, 'PUBLIC FINGERPRINT', fingerprint, isMonospaced: true),
              const SizedBox(height: 24),
              _buildActionTile(theme, Icons.devices, 'TRUSTED DEVICES', 'Manage 3 active devices'),
              _buildActionTile(theme, Icons.security, 'EXPORT RECOVERY PHRASE', 'Keep your vault accessible'),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => ref.read(authProvider.notifier).logout(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error.withOpacity(0.1),
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error, width: 1),
                  ),
                  child: const Text('TERMINATE SESSION'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, String label, String value, {bool isMonospaced = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: 8),
          Text(
            value,
            style: isMonospaced 
                ? const TextStyle(fontFamily: 'monospace', color: Colors.white70, fontSize: 13)
                : theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(ThemeData theme, IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: theme.textTheme.bodyMedium),
        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
        onTap: () {},
      ),
    );
  }
}
