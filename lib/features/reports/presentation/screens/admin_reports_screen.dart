import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';

class AdminReportsScreen extends StatefulWidget { const AdminReportsScreen({super.key}); @override State<AdminReportsScreen> createState() => _AdminReportsScreenState(); }
class _AdminReportsScreenState extends State<AdminReportsScreen> {
  @override void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ReportProvider>().loadAll()); }
  @override Widget build(BuildContext context) { final p = context.watch<ReportProvider>(); return Scaffold(appBar: AppBar(title: const Text('Reports')), body: p.isLoading ? const Center(child: CircularProgressIndicator()) : p.reports.isEmpty ? const Center(child: Text('No reports found.')) : RefreshIndicator(onRefresh: p.loadAll, child: ListView.separated(padding: const EdgeInsets.all(16), itemCount: p.reports.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, i) { final r = p.reports[i]; return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.pumpName ?? 'Reported content', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 6), Text('By: ${r.reporterName}'), Text('Reason: ${r.reason}'), if (r.details.isNotEmpty) Text('Details: ${r.details}'), const SizedBox(height: 10), DropdownButtonFormField<String>(value: r.status, decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()), items: const ['open','reviewing','resolved','dismissed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) { if (v != null) p.setStatus(r.id, v); })]))); }))); }
}
