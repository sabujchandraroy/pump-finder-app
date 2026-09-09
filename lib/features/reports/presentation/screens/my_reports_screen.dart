import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadMine();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ReportProvider>();
    Widget body;
    if (p.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (p.reports.isEmpty) {
      body = const Center(child: Text('No reports submitted yet.'));
    } else {
      body = RefreshIndicator(
        onRefresh: p.loadMine,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: p.reports.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final r = p.reports[i];
            return Card(
              child: ListTile(
                leading: Icon(r.status == 'resolved' ? Icons.check_circle_outline : Icons.flag_outlined),
                title: Text(r.pumpName ?? 'Reported content'),
                subtitle: Text('${r.reason}\n${r.details.isEmpty ? 'No additional details.' : r.details}'),
                isThreeLine: true,
                trailing: Chip(label: Text(r.status)),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: body,
    );
  }
}
