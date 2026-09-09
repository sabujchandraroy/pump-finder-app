import 'package:flutter/material.dart';

class SafetyCenterScreen extends StatelessWidget {
  const SafetyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Center')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.shield_outlined, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text('Stay safe with PumpFinder', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          const _SafetyCard(icon: Icons.location_on_outlined, title: 'Verify pump information', text: 'Check the address, map location, opening status, and recent reviews before visiting.'),
          const _SafetyCard(icon: Icons.phone_outlined, title: 'Use trusted contact information', text: 'Use the phone number shown in the pump details and avoid sharing unnecessary personal information.'),
          const _SafetyCard(icon: Icons.flag_outlined, title: 'Report problems', text: 'If you find incorrect information, spam, inappropriate content, or a safety concern, submit a report so it can be reviewed.'),
          const _SafetyCard(icon: Icons.warning_amber_outlined, title: 'Emergency situations', text: 'PumpFinder is not an emergency service. In an emergency, contact your local emergency services.'),
        ],
      ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _SafetyCard({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon),
        title: Text(title),
        subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(text)),
      ),
    );
  }
}
