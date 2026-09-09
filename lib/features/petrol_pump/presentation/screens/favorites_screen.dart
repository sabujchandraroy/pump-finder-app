import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/petrol_pump.dart';
import '../providers/petrol_pump_provider.dart';
import '../widgets/pump_card.dart';
import 'pump_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<PetrolPumpProvider>().loadPumps();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PetrolPumpProvider>();
    final List<PetrolPump> favorites = provider.favoritePumps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: _buildBody(context, provider, favorites),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PetrolPumpProvider provider,
    List<PetrolPump> favorites,
  ) {
    if (provider.isLoading && favorites.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (favorites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 56,
            ),
            SizedBox(height: 12),
            Text('No favorite petrol pumps yet.'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadPumps,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: favorites.length,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          final pump = favorites[index];

          return PumpCard(
            pump: pump,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PumpDetailsScreen(pump: pump),
                ),
              );
            },
            onFavorite: () {
              provider.toggleFavorite(pump);
            },
          );
        },
      ),
    );
  }
}
