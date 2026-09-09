import 'dart:math' as math;

class AppUtils {
  static double distanceInKm({
    required double latitude1,
    required double longitude1,
    required double latitude2,
    required double longitude2,
  }) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRadians(latitude2 - latitude1);
    final dLon = _toRadians(longitude2 - longitude1);

    final lat1 = _toRadians(latitude1);
    final lat2 = _toRadians(latitude2);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degree) => degree * math.pi / 180;
}
