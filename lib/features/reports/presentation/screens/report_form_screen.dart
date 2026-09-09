import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';

class ReportFormScreen extends StatefulWidget {
  final String? pumpId;
  final String? pumpName;
  final String? reviewId;
  const ReportFormScreen({super.key, this.pumpId, this.pumpName, this.reviewId});
  @override State<ReportFormScreen> createState() => _ReportFormScreenState();
}
class _ReportFormScreenState extends State<ReportFormScreen> {
  final _details = TextEditingController();
  String? _reason;
  static const reasons = ['Incorrect pump information', 'Inappropriate content', 'Spam or duplicate', 'Safety concern', 'Other'];
  @override void dispose() { _details.dispose(); super.dispose(); }
  Future<void> _submit() async {
    if (_reason == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a reason.'))); return; }
    final ok = await context.read<ReportProvider>().submit(pumpId: widget.pumpId, reviewId: widget.reviewId, reason: _reason!, details: _details.text);
    if (!mounted) return;
    if (ok) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted. Thank you.'))); Navigator.pop(context); }
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Report')), body: ListView(padding: const EdgeInsets.all(20), children: [
      Text(widget.pumpName == null ? 'Report this content' : 'Report ${widget.pumpName}', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 20),
      DropdownButtonFormField<String>(value: _reason, decoration: const InputDecoration(labelText: 'Reason'), items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(), onChanged: (v) => setState(() => _reason = v)),
      const SizedBox(height: 16),
      TextField(controller: _details, maxLines: 6, maxLength: 1000, decoration: const InputDecoration(labelText: 'Additional details', alignLabelWithHint: true, border: OutlineInputBorder())),
      const SizedBox(height: 16),
      Consumer<ReportProvider>(builder: (_, p, __) => FilledButton.icon(onPressed: p.isSaving ? null : _submit, icon: p.isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.flag_outlined), label: const Text('Submit Report'))),
    ]));
}
