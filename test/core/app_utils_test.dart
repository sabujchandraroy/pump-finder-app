import 'package:flutter_test/flutter_test.dart';
import 'package:pump_finder/core/utils/app_utils.dart';

void main() {
  test('distance between identical coordinates is zero', () {
    expect(
      AppUtils.distanceInKm(latitude1: 23.8, longitude1: 90.4, latitude2: 23.8, longitude2: 90.4),
      closeTo(0, 0.000001),
    );
  });
}
