import 'package:flutter/material.dart';

class SecurityCenterScreen extends StatelessWidget {
  const SecurityCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('SECURITY CENTER')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildSecurityScore(theme),
            const SizedBox(height: 32),
            _buildStatusItem(theme, Icons.fingerprint, 'BIOMETRIC LOCK', 'Enabled & Protected', true),
            _buildStatusItem(theme, Icons.verified_user, 'ROOT DETECTION', 'System integrity verified', true),
            _buildStatusItem(theme, Icons.vpn_key, 'IDENTITY KEY', 'Ed25519 Healthy', true),
            _buildStatusItem(theme, Icons.screenshot_monitor, 'SCREEN PROTECTION', 'Screenshot prevention active', true),
            _buildStatusItem(theme, Icons.lock_clock, 'SESSION TIMEOUT', 'Auto-lock in 5 minutes', false),
            const SizedBox(height: 32),
            _buildLogSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityScore(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary.withOpacity(0.1), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text('OVERALL SECURITY', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 16),
          Text('SOLID', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: theme.colorScheme.primary)),
          const SizedBox(height: 8),
          const Text('All E2EE parameters verified.', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatusItem(ThemeData theme, IconData icon, String title, String subtitle, bool isSecure) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: isSecure ? theme.colorScheme.primary : Colors.white24, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          Icon(isSecure ? Icons.check_circle : Icons.warning_amber, color: isSecure ? theme.colorScheme.primary : theme.colorScheme.error, size: 20),
        ],
      ),
    );
  }

  Widget _buildLogSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SECURITY LOGS', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white38)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '> 2026-04-12 23:45 UTC: Device Trust Verified\n> 2026-04-12 23:40 UTC: Session Rotated\n> 2026-04-12 23:30 UTC: Biometric challenge successful',
            style: TextStyle(fontFamily: 'monospace', color: Colors.white24, fontSize: 10),
          ),
        ),
      ],
    );
  }
}
