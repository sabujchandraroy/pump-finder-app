import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import 'admin_pump_form_screen.dart';

class AdminPumpsScreen extends StatefulWidget {
  const AdminPumpsScreen({super.key});
  @override State<AdminPumpsScreen> createState() => _AdminPumpsScreenState();
}

class _AdminPumpsScreenState extends State<AdminPumpsScreen> {
  @override
  void initState() { super.initState(); Future.microtask(() => context.read<AdminProvider>().checkAccess()); }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Petrol Pumps'), actions: [IconButton(onPressed: p.loadPumps, icon: const Icon(Icons.refresh))]),
      floatingActionButton: p.isAdmin ? FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPumpFormScreen(provider: p))),
        icon: const Icon(Icons.add), label: const Text('Add Pump'),
      ) : null,
      body: !p.isAdmin
          ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(p.errorMessage ?? 'You do not have admin access.', textAlign: TextAlign.center)))
          : p.isLoading && p.pumps.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : p.errorMessage != null && p.pumps.isEmpty
                  ? Center(child: Text(p.errorMessage!))
                  : RefreshIndicator(
                      onRefresh: p.loadPumps,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16), itemCount: p.pumps.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final pump = p.pumps[i];
                          return Card(child: ListTile(
                            title: Text(pump.name),
                            subtitle: Text('${pump.address}\n${pump.isOpen ? 'Open' : 'Closed'} • ${pump.fuelTypes.join(', ')}'),
                            isThreeLine: true,
                            leading: CircleAvatar(child: Icon(pump.isOpen ? Icons.local_gas_station : Icons.gas_meter)),
                            trailing: Wrap(children: [
                              IconButton(tooltip: 'Edit', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPumpFormScreen(provider: p, pump: pump))), icon: const Icon(Icons.edit)),
                              IconButton(tooltip: 'Delete', onPressed: () => _delete(p, pump.id, pump.name), icon: const Icon(Icons.delete_outline)),
                            ]),
                          ));
                        },
                      ),
                    ),
    );
  }

  Future<void> _delete(AdminProvider p, String id, String name) async {
    final yes = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Delete pump?'), content: Text('Delete "$name"?'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))],
    ));
    if (yes == true) await p.remove(id);
  }
}
