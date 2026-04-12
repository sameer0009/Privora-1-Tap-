import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/presentation/providers/auth_provider.dart';
import 'package:mobile/presentation/providers/contacts_provider.dart';
import 'package:mobile/domain/models/user_model.dart';
import 'package:mobile/presentation/providers/base_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contactsState = ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PRIVORA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4)),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.logout), 
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildSecurityStatus(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text('SECURE SESSIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 2)),
            ),
          ),
          if (contactsState.isLoading)
            const SliverToBoxAdapter(child: Center(child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            )))
          else if (contactsState.contacts.isEmpty)
             const SliverToBoxAdapter(child: Center(child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No secure contacts added yet.', style: TextStyle(color: Colors.white24)),
            )))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final contact = contactsState.contacts[index];
                  return _buildContactTile(contact);
                },
                childCount: contactsState.contacts.length,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(),
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _showAddContactDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Secure Contact'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter username'),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              final user = await ref.read(contactsProvider.notifier).searchUser(controller.text);
              if (user != null) {
                await ref.read(contactsProvider.notifier).addContact(user.id);
                if (mounted) context.pop();
              }
            }, 
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user, color: Colors.green),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Device Trusted', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('End-to-end encryption active', style: TextStyle(fontSize: 12, color: Colors.white54)),
              ],
            ),
          ),
          TextButton(onPressed: () {}, child: const Text('MANAGE')),
        ],
      ),
    );
  }

  Widget _buildContactTile(UserModel contact) {
    if (contact.devices.isEmpty) return Container();
    final device = contact.devices.first;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: const Icon(Icons.person_outline, color: Colors.white),
      ),
      title: Text(contact.username, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Secure device: ${device.deviceId.substring(0,8)}...'),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: () {
        context.push('/chat/${device.deviceId}/${device.publicKey}');
      },
    );
  }
}
