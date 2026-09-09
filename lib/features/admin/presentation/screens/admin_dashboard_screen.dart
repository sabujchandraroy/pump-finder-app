import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/admin_provider.dart';
import 'admin_pumps_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AdminProvider>();
      await provider.checkAccess();
      if (provider.isAdmin) {
        await provider.loadDashboardStats();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final stats = provider.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: provider.isLoading ? null : () => provider.loadDashboardStats(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: !provider.isAdmin
          ? Center(child: Text(provider.errorMessage ?? 'You do not have admin access.'))
          : provider.isLoading && stats == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: provider.loadDashboardStats,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text('Overview', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: MediaQuery.sizeOf(context).width >= 700 ? 4 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.35,
                        children: [
                          _StatCard(title: 'Total Pumps', value: '${stats?.totalPumps ?? 0}', icon: Icons.local_gas_station),
                          _StatCard(title: 'Open Now', value: '${stats?.openPumps ?? 0}', icon: Icons.check_circle_outline),
                          _StatCard(title: 'Closed', value: '${stats?.closedPumps ?? 0}', icon: Icons.cancel_outlined),
                          _StatCard(title: 'Rated Pumps', value: '${stats?.ratedPumps ?? 0}', icon: Icons.star_outline),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.manage_search),
                          title: const Text('Manage Petrol Pumps'),
                          subtitle: const Text('Add, edit and delete pump information.'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPumpsScreen())),
                        ),
                      ),
                      if (provider.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(provider.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ],
                    ],
                  ),
                ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 28),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(title),
        ]),
      ),
    );
  }
}
