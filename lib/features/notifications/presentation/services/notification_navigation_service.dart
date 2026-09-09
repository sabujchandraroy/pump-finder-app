import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../petrol_pump/presentation/providers/petrol_pump_provider.dart';
import '../../../reviews/presentation/screens/reviews_screen.dart';
import '../../domain/entities/app_notification.dart';

class NotificationNavigationService {
  const NotificationNavigationService();

  Future<void> open(
    BuildContext context,
    AppNotification notification,
  ) async {
    switch (notification.type) {
      case 'new_pump':
      case 'favorite':
        await _openPump(context, notification.relatedId);
        return;

      case 'review':
        await _openReviews(context, notification.relatedId);
        return;

      case 'report_status':
        Navigator.pushNamed(context, '/my-reports');
        return;

      default:
        return;
    }
  }

  Future<void> _openPump(
    BuildContext context,
    String? pumpId,
  ) async {
    if (pumpId == null || pumpId.isEmpty) {
      _showMessage(
        context,
        'Pump information is unavailable.',
      );
      return;
    }

    final provider = context.read<PetrolPumpProvider>();

    var pump = _findPump(provider, pumpId);

    if (pump == null) {
      await provider.loadPumps();

      if (!context.mounted) return;

      pump = _findPump(provider, pumpId);
    }

    if (!context.mounted) return;

    if (pump == null) {
      _showMessage(
        context,
        'This petrol pump is no longer available.',
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/pump-details',
      arguments: pump,
    );
  }

  Future<void> _openReviews(
    BuildContext context,
    String? pumpId,
  ) async {
    if (pumpId == null || pumpId.isEmpty) {
      _showMessage(
        context,
        'Review information is unavailable.',
      );
      return;
    }

    final provider = context.read<PetrolPumpProvider>();

    var pump = _findPump(provider, pumpId);

    if (pump == null) {
      await provider.loadPumps();

      if (!context.mounted) return;

      pump = _findPump(provider, pumpId);
    }

    if (!context.mounted) return;

    if (pump == null) {
      _showMessage(
        context,
        'This petrol pump is no longer available.',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewsScreen(
          pumpId: pump.id,
          pumpName: pump.name,
        ),
      ),
    );
  }

  dynamic _findPump(
    PetrolPumpProvider provider,
    String pumpId,
  ) {
    for (final pump in provider.pumps) {
      if (pump.id == pumpId) {
        return pump;
      }
    }

    return null;
  }

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }
}