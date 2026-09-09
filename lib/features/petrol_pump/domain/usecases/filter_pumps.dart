import '../entities/petrol_pump.dart';
import '../entities/pump_filter.dart';
import '../entities/pump_sort_option.dart';

class FilterPumps {
  List<PetrolPump> call(
    List<PetrolPump> pumps, {
    PumpFilter filter = const PumpFilter(),
    PumpSortOption sortOption = PumpSortOption.nearest,
  }) {
    final result = pumps.where((pump) {
      if (filter.maxDistanceKm != null &&
          pump.distanceKm > 0 &&
          pump.distanceKm > filter.maxDistanceKm!) {
        return false;
      }
      if (filter.maxDistanceKm != null && pump.distanceKm == 0) {
        return false;
      }
      if (filter.minimumRating != null && pump.rating < filter.minimumRating!) {
        return false;
      }
      if (filter.openNowOnly && !pump.isOpen) return false;
      if (filter.fuelType != null &&
          !pump.fuelTypes.any(
            (fuel) => fuel.toLowerCase() == filter.fuelType!.toLowerCase(),
          )) {
        return false;
      }
      return true;
    }).toList();

    switch (sortOption) {
      case PumpSortOption.nearest:
        result.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      case PumpSortOption.highestRated:
        result.sort((a, b) => b.rating.compareTo(a.rating));
      case PumpSortOption.mostReviewed:
        result.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    }

    return result;
  }
}
