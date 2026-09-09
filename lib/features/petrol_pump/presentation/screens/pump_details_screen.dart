import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/external_action_service.dart';
import '../../domain/entities/petrol_pump.dart';
import '../providers/petrol_pump_provider.dart';
import '../../../reviews/presentation/screens/reviews_screen.dart';

class PumpDetailsScreen extends StatelessWidget {
  final PetrolPump pump;

  const PumpDetailsScreen({super.key, required this.pump});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PetrolPumpProvider>();
    const actions = ExternalActionService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pump Details'),
        actions: [
            IconButton(
              tooltip: 'Report',
              onPressed: () => Navigator.pushNamed(context, '/report', arguments: {
                'pumpId': pump.id,
                'pumpName': pump.name,
              }),
              icon: const Icon(Icons.flag_outlined),
            ),
          IconButton(
            tooltip: pump.isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: () => provider.toggleFavorite(pump),
            icon: Icon(
              pump.isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildQuickActions(context, actions),
          const SizedBox(height: 20),
          _buildInfoCard(context),
          const SizedBox(height: 20),
          _buildFuelCard(context),
          const SizedBox(height: 20),
          _buildReviewsButton(context),
          const SizedBox(height: 20),
          _buildLocationCard(context, actions),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage: pump.logoUrl != null && pump.logoUrl!.isNotEmpty
              ? NetworkImage(pump.logoUrl!)
              : null,
          child: pump.logoUrl == null || pump.logoUrl!.isEmpty
              ? const Icon(Icons.local_gas_station, size: 48)
              : null,
        ),
        const SizedBox(height: 14),
        Text(
          pump.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          pump.address,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          children: [
            Chip(
              avatar: const Icon(Icons.star, size: 18),
              label: Text(
                '${pump.rating.toStringAsFixed(1)} (${pump.reviewCount})',
              ),
            ),
            Chip(
              avatar: Icon(
                pump.isOpen ? Icons.circle : Icons.circle_outlined,
                size: 12,
              ),
              label: Text(pump.isOpen ? 'Open' : 'Closed'),
            ),
            if (pump.distanceKm > 0)
              Chip(
                avatar: const Icon(Icons.near_me, size: 18),
                label: Text('${pump.distanceKm.toStringAsFixed(1)} km'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    ExternalActionService actions,
  ) {
    return Row(
      children: [
        if (pump.phone != null && pump.phone!.trim().isNotEmpty)
          Expanded(
            child: FilledButton.icon(
              onPressed: () async {
                final ok = await actions.callPhone(pump.phone!.trim());
                if (!context.mounted) return;
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unable to open phone app.')),
                  );
                }
              },
              icon: const Icon(Icons.phone),
              label: const Text('Call'),
            ),
          ),
        if (pump.phone != null && pump.phone!.trim().isNotEmpty)
          const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final ok = await actions.openDirections(
                latitude: pump.latitude,
                longitude: pump.longitude,
              );
              if (!context.mounted) return;
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unable to open directions.')),
                );
              }
            },
            icon: const Icon(Icons.directions),
            label: const Text('Directions'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Opening Hours'),
            subtitle: Text(pump.openingHours ?? 'Not available'),
          ),
          if (pump.phone != null && pump.phone!.trim().isNotEmpty)
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone'),
              subtitle: Text(pump.phone!),
            ),
        ],
      ),
    );
  }

  Widget _buildFuelCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Fuel',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            if (pump.fuelTypes.isEmpty && pump.fuelPrices.isEmpty)
              const Text('Fuel information is not available.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pump.fuelTypes
                    .map((fuel) => Chip(label: Text(fuel)))
                    .toList(),
              ),
            if (pump.fuelPrices.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...pump.fuelPrices.entries.map((entry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.local_offer_outlined),
                    title: Text(entry.key),
                    trailing: Text(
                      entry.value.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsButton(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.rate_review_outlined),
        title: const Text('Reviews'),
        subtitle: Text('${pump.reviewCount} review${pump.reviewCount == 1 ? '' : 's'}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReviewsScreen(pumpId: pump.id, pumpName: pump.name),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard(
    BuildContext context,
    ExternalActionService actions,
  ) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Address'),
            subtitle: Text(pump.address),
            trailing: IconButton(
              tooltip: 'Copy address',
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: pump.address));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Address copied.')),
                );
              },
              icon: const Icon(Icons.copy),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Coordinates'),
            subtitle: Text(
              '${pump.latitude.toStringAsFixed(6)}, ${pump.longitude.toStringAsFixed(6)}',
            ),
            trailing: IconButton(
              tooltip: 'Open directions',
              onPressed: () => actions.openDirections(
                latitude: pump.latitude,
                longitude: pump.longitude,
              ),
              icon: const Icon(Icons.directions),
            ),
          ),
        ],
      ),
    );
  }
}
