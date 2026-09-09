import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ProfileProvider>();
      await provider.loadProfile();
      if (!mounted || provider.profile == null) return;
      _nameController.text = provider.profile!.displayName;
      _phoneController.text = provider.profile!.phone;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<ProfileProvider>();
    final success = await provider.saveProfile(
      displayName: _nameController.text,
      phone: _phoneController.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Profile updated.' : provider.errorMessage ?? 'Update failed.')),
    );
  }

  Future<void> _logout() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to use PumpFinder.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign Out')),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final profile = provider.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: provider.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 42,
                    child: Text(
                      (profile?.displayName.isNotEmpty == true ? profile!.displayName[0] : '?').toUpperCase(),
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(child: Text(profile?.email ?? '', style: Theme.of(context).textTheme.bodyMedium)),
                const SizedBox(height: 20),
                if (profile?.isAdmin == true)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.admin_panel_settings_outlined),
                      title: const Text('Administrator'),
                      subtitle: const Text('You have access to pump management.'),
                    ),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Display name', prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone number', prefixIcon: Icon(Icons.phone_outlined)),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: provider.isSaving ? null : _save,
                  icon: provider.isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_outlined),
                  label: const Text('Save Changes'),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.shield_outlined),
                        title: const Text('Safety Center'),
                        subtitle: const Text('Safety tips and reporting guidance'),
                        onTap: () => Navigator.pushNamed(context, '/safety-center'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.flag_outlined),
                        title: const Text('My Reports'),
                        subtitle: const Text('Track reports you submitted'),
                        onTap: () => Navigator.pushNamed(context, '/my-reports'),
                      ),
                      if (profile?.isAdmin == true)
                        ListTile(
                          leading: const Icon(Icons.report_outlined),
                          title: const Text('Manage Reports'),
                          subtitle: const Text('Review and update user reports'),
                          onTap: () => Navigator.pushNamed(context, '/admin-reports'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                ),
                if (provider.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
    );
  }
}
