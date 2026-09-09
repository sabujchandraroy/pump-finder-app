import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/entities/petrol_pump.dart';
import '../../domain/entities/pump_filter.dart';
import '../../domain/entities/pump_sort_option.dart';
import '../../domain/usecases/add_favorite_pump.dart';
import '../../domain/usecases/filter_pumps.dart';
import '../../domain/usecases/get_favorite_pumps.dart';
import '../../domain/usecases/get_nearby_pumps.dart';
import '../../domain/usecases/get_petrol_pumps.dart';
import '../../domain/usecases/remove_favorite_pump.dart';
import '../../domain/usecases/search_pumps.dart';

class PetrolPumpProvider extends ChangeNotifier {
  // ============================================================
  // Dependencies
  // ============================================================

  final GetPetrolPumps getPetrolPumps;
  final GetNearbyPumps getNearbyPumps;
  final SearchPumps searchPumps;
  final GetFavoritePumps _getFavoritePumps;
  final AddFavoritePump addFavoritePump;
  final RemoveFavoritePump removeFavoritePump;
  final FilterPumps filterPumps;
  final LocationService locationService;

  PetrolPumpProvider({
    required this.getPetrolPumps,
    required this.getNearbyPumps,
    required this.searchPumps,
    required GetFavoritePumps getFavoritePumps,
    required this.addFavoritePump,
    required this.removeFavoritePump,
    required this.filterPumps,
    required this.locationService,
  }) : _getFavoritePumps = getFavoritePumps;

  // ============================================================
  // Pump State
  // ============================================================

  List<PetrolPump> _pumps = <PetrolPump>[];

  PetrolPump? _selectedPump;

  Set<String> _favoriteIds = <String>{};

  bool _isLoading = false;

  String? _errorMessage;

  PumpFilter _filter = const PumpFilter();

  PumpSortOption _sortOption =
      PumpSortOption.nearest;

  String _searchQuery = '';

  // ============================================================
  // Nearby / All State
  // ============================================================

  bool _nearbyOnly = false;

  // ============================================================
  // Location State
  // ============================================================

  StreamSubscription<Position>? _positionSubscription;

  LocationData? _currentLocation;

  double? _latitude;
  double? _longitude;

  double _accuracy = 50.0;

  /// Device direction in degrees.
  ///
  /// 0   = North
  /// 90  = East
  /// 180 = South
  /// 270 = West
  double _heading = 0.0;

  bool _isLocationLoading = false;

  bool _isLocationTracking = false;

  String? _locationError;

  // ============================================================
  // Getters - Pump
  // ============================================================

  List<PetrolPump> get pumps =>
      List.unmodifiable(_pumps);

  List<PetrolPump> get favoritePumps =>
      List.unmodifiable(
        _pumps.where(
          (pump) =>
              _favoriteIds.contains(pump.id),
        ),
      );

  PetrolPump? get selectedPump =>
      _selectedPump;

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  PumpFilter get filter => _filter;

  PumpSortOption get sortOption =>
      _sortOption;

  String get searchQuery =>
      _searchQuery;

  bool get hasActiveFilters =>
      _filter.hasFilters;

  // ============================================================
  // Getters - Nearby
  // ============================================================

  bool get nearbyOnly => _nearbyOnly;

  // ============================================================
  // Getters - Location
  // ============================================================

  LocationData? get currentLocation =>
      _currentLocation;

  double? get latitude =>
      _latitude;

  double? get longitude =>
      _longitude;

  double get accuracy =>
      _accuracy;

  double get heading =>
      _heading;

  bool get isLocationLoading =>
      _isLocationLoading;

  bool get isLocationTracking =>
      _isLocationTracking;

  String? get locationError =>
      _locationError;

  bool get hasCurrentLocation =>
      _latitude != null &&
      _longitude != null;

  // ============================================================
  // Load Petrol Pumps
  // ============================================================

  Future<void> loadPumps() async {
    _nearbyOnly = false;

    await _run(() async {
      _pumps = await getPetrolPumps();

      _updateDistancesIfPossible();

      _applyCurrentFilterAndSort();
    });
  }

  // ============================================================
  // Load Nearby Petrol Pumps
  // ============================================================

  Future<void> loadNearbyPumps({
    double radiusKm = 10,
  }) async {
    if (_currentLocation == null) {
      await loadCurrentLocation();
    }

    final location = _currentLocation;

    if (location == null) {
      return;
    }

    _nearbyOnly = true;

    await _run(() async {
      _pumps = await getNearbyPumps(
        latitude: location.latitude,
        longitude: location.longitude,
        radiusKm: radiusKm,
      );

      _updateDistancesIfPossible();

      _applyCurrentFilterAndSort();
    });
  }

  // ============================================================
  // Search
  // ============================================================

  Future<void> search(
    String query,
  ) async {
    _searchQuery = query.trim();

    await _run(() async {
      _pumps = await searchPumps(
        _searchQuery,
      );

      _updateDistancesIfPossible();

      _applyCurrentFilterAndSort();
    });
  }

  // ============================================================
  // Clear Search
  // ============================================================

  Future<void> clearSearch() async {
    _searchQuery = '';

    await loadPumps();
  }

  // ============================================================
  // Favorites
  // ============================================================

  Future<void> loadFavorites() async {
    try {
      final ids = await _getFavoritePumps();

      _favoriteIds = Set<String>.from(ids);

      _syncPumpFavoriteFlags();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    }
  }

  Future<void> toggleFavorite(
    PetrolPump pump,
  ) async {
    final wasFavorite =
        _favoriteIds.contains(pump.id);

    if (wasFavorite) {
      _favoriteIds.remove(pump.id);
    } else {
      _favoriteIds.add(pump.id);
    }

    _syncPumpFavoriteFlags();

    notifyListeners();

    try {
      if (wasFavorite) {
        await removeFavoritePump(
          pump.id,
        );
      } else {
        await addFavoritePump(
          pump.id,
        );
      }
    } catch (e) {
      if (wasFavorite) {
        _favoriteIds.add(pump.id);
      } else {
        _favoriteIds.remove(pump.id);
      }

      _syncPumpFavoriteFlags();

      _errorMessage = e.toString();

      notifyListeners();
    }
  }

  // ============================================================
  // Filters
  // ============================================================

  void setFilter(
    PumpFilter filter,
  ) {
    _filter = filter;

    _updateDistancesIfPossible();

    _applyCurrentFilterAndSort();

    notifyListeners();
  }

  void clearFilters() {
    _filter = const PumpFilter();

    _applyCurrentFilterAndSort();

    notifyListeners();
  }

  void setSortOption(
    PumpSortOption option,
  ) {
    _sortOption = option;

    _applyCurrentFilterAndSort();

    notifyListeners();
  }

  // ============================================================
  // Distance Calculation
  // ============================================================

  void _updateDistancesIfPossible() {
    final location = _currentLocation;

    if (location == null) {
      return;
    }

    _pumps = _pumps.map((pump) {
      return pump.copyWith(
        distanceKm: AppUtils.distanceInKm(
          latitude1:
              location.latitude,
          longitude1:
              location.longitude,
          latitude2:
              pump.latitude,
          longitude2:
              pump.longitude,
        ),
      );
    }).toList();
  }

  // ============================================================
  // Current Location
  // ============================================================

  Future<void> loadCurrentLocation() async {
    _isLocationLoading = true;

    _errorMessage = null;

    notifyListeners();

    try {
      _currentLocation =
          await locationService.getCurrentLocation();

      if (_currentLocation != null) {
        _latitude =
            _currentLocation!.latitude;

        _longitude =
            _currentLocation!.longitude;
      }

      _updateDistancesIfPossible();

      _applyCurrentFilterAndSort();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLocationLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // Start Location Tracking
  // ============================================================

  Future<void> startLocationTracking() async {
    _locationError = null;

    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      _locationError =
          'Location service is disabled.';

      notifyListeners();

      return;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission ==
        LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission ==
        LocationPermission.denied) {
      _locationError =
          'Location permission denied.';

      notifyListeners();

      return;
    }

    if (permission ==
        LocationPermission.deniedForever) {
      _locationError =
          'Location permission permanently denied.';

      notifyListeners();

      return;
    }

    await _positionSubscription?.cancel();

    const locationSettings =
        LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _isLocationTracking = true;

    notifyListeners();

    _positionSubscription =
        Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      _handlePositionUpdate,
      onError: (_) {
        _locationError =
            'Unable to track current location.';

        _isLocationTracking = false;

        notifyListeners();
      },
    );
  }

  // ============================================================
  // Position Update
  // ============================================================

  void _handlePositionUpdate(
    Position position,
  ) {
    _latitude = position.latitude;

    _longitude = position.longitude;

    _currentLocation = LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    if (position.accuracy.isFinite &&
        position.accuracy > 0) {
      _accuracy = position.accuracy;
    }

    if (position.heading.isFinite &&
        position.heading >= 0) {
      _heading = position.heading;
    }

    _locationError = null;

    _updateDistancesIfPossible();

    if (_nearbyOnly) {
      _applyCurrentFilterAndSort();
    }

    notifyListeners();
  }

  // ============================================================
  // Get Current Position
  // ============================================================

  Future<void> moveToCurrentLocation() async {
    _isLocationLoading = true;

    _locationError = null;

    notifyListeners();

    try {
      final position =
          await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(
          accuracy:
              LocationAccuracy.high,
        ),
      );

      _handlePositionUpdate(
        position,
      );
    } catch (e) {
      _locationError =
          'Unable to get current location.';

      _isLocationLoading = false;

      notifyListeners();

      return;
    }

    _isLocationLoading = false;

    notifyListeners();
  }

  // ============================================================
  // Stop Location Tracking
  // ============================================================

  Future<void> stopLocationTracking() async {
    await _positionSubscription?.cancel();

    _positionSubscription = null;

    _isLocationTracking = false;

    notifyListeners();
  }

  // ============================================================
  // Pump Selection
  // ============================================================

  void selectPump(
    PetrolPump pump,
  ) {
    _selectedPump = pump;

    notifyListeners();
  }

  void clearSelection() {
    _selectedPump = null;

    notifyListeners();
  }

  // ============================================================
  // Apply Filter + Sort
  // ============================================================

  void _applyCurrentFilterAndSort() {
    _pumps = filterPumps(
      _pumps,
      filter: _filter,
      sortOption: _sortOption,
    );
  }

  // ============================================================
  // Sync Favorite Flags
  // ============================================================

  void _syncPumpFavoriteFlags() {
    _pumps = _pumps.map((pump) {
      return pump.copyWith(
        isFavorite:
            _favoriteIds.contains(
          pump.id,
        ),
      );
    }).toList();
  }

  // ============================================================
  // Common Runner
  // ============================================================

  Future<void> _run(
    Future<void> Function() action,
  ) async {
    _isLoading = true;

    _errorMessage = null;

    notifyListeners();

    try {
      await loadFavorites();

      await action();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    _positionSubscription?.cancel();

    super.dispose();
  }
}