import 'package:flutter_test/flutter_test.dart';
import 'package:pump_finder/features/petrol_pump/domain/entities/petrol_pump.dart';
import 'package:pump_finder/features/petrol_pump/domain/entities/pump_filter.dart';
import 'package:pump_finder/features/petrol_pump/domain/entities/pump_sort_option.dart';
import 'package:pump_finder/features/petrol_pump/domain/usecases/filter_pumps.dart';

void main() {
  final pumps = [
    const PetrolPump(id: '1', name: 'A', address: 'Dhaka', latitude: 0, longitude: 0, rating: 4.5, distanceKm: 2, isOpen: true),
    const PetrolPump(id: '2', name: 'B', address: 'Dhaka', latitude: 0, longitude: 0, rating: 3.0, distanceKm: 1, isOpen: false),
  ];

  test('filters open pumps by minimum rating', () {
    final result = FilterPumps()(pumps, filter: const PumpFilter(openNowOnly: true, minimumRating: 4));
    expect(result.map((p) => p.id), ['1']);
  });

  test('sorts by nearest', () {
    final result = FilterPumps()(pumps, sortOption: PumpSortOption.nearest);
    expect(result.first.id, '2');
  });
}
