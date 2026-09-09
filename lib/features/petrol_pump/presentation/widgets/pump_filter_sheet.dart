import 'package:flutter/material.dart';

import '../../domain/entities/pump_filter.dart';
import '../../domain/entities/pump_sort_option.dart';

class PumpFilterSheet extends StatefulWidget {
  final PumpFilter initialFilter;
  final PumpSortOption initialSort;
  final List<String> fuelTypes;
  final void Function(PumpFilter filter, PumpSortOption sort) onApply;

  const PumpFilterSheet({
    super.key,
    required this.initialFilter,
    required this.initialSort,
    required this.fuelTypes,
    required this.onApply,
  });

  @override
  State<PumpFilterSheet> createState() => _PumpFilterSheetState();
}

class _PumpFilterSheetState extends State<PumpFilterSheet> {
  double? _distance;
  double? _rating;
  bool _openOnly = false;
  String? _fuelType;
  late PumpSortOption _sort;

  @override
  void initState() {
    super.initState();
    _distance = widget.initialFilter.maxDistanceKm;
    _rating = widget.initialFilter.minimumRating;
    _openOnly = widget.initialFilter.openNowOnly;
    _fuelType = widget.initialFilter.fuelType;
    _sort = widget.initialSort;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Filter & Sort', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _distance = null;
                      _rating = null;
                      _openOnly = false;
                      _fuelType = null;
                      _sort = PumpSortOption.nearest;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Maximum distance'),
            Wrap(
              spacing: 8,
              children: [5.0, 10.0, 20.0, 50.0].map((value) {
                return ChoiceChip(
                  label: Text('${value.toInt()} km'),
                  selected: _distance == value,
                  onSelected: (_) => setState(() => _distance = value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Minimum rating'),
            Wrap(
              spacing: 8,
              children: [3.0, 4.0, 4.5].map((value) {
                return ChoiceChip(
                  label: Text('${value.toStringAsFixed(1)}+'),
                  selected: _rating == value,
                  onSelected: (_) => setState(() => _rating = value),
                );
              }).toList(),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Open now'),
              value: _openOnly,
              onChanged: (value) => setState(() => _openOnly = value),
            ),
            const SizedBox(height: 8),
            const Text('Fuel type'),
            DropdownButtonFormField<String>(
              value: _fuelType,
              decoration: const InputDecoration(hintText: 'Any fuel type'),
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('Any fuel type')),
                ...widget.fuelTypes.map(
                  (fuel) => DropdownMenuItem(value: fuel, child: Text(fuel)),
                ),
              ],
              onChanged: (value) => setState(() => _fuelType = value),
            ),
            const SizedBox(height: 16),
            const Text('Sort by'),
            DropdownButtonFormField<PumpSortOption>(
              value: _sort,
              items: const [
                DropdownMenuItem(
                  value: PumpSortOption.nearest,
                  child: Text('Nearest'),
                ),
                DropdownMenuItem(
                  value: PumpSortOption.highestRated,
                  child: Text('Highest Rated'),
                ),
                DropdownMenuItem(
                  value: PumpSortOption.mostReviewed,
                  child: Text('Most Reviewed'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _sort = value);
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  widget.onApply(
                    PumpFilter(
                      maxDistanceKm: _distance,
                      minimumRating: _rating,
                      openNowOnly: _openOnly,
                      fuelType: _fuelType,
                    ),
                    _sort,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
