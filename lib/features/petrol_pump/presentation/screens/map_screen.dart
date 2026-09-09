import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_error.dart';
import '../../domain/entities/petrol_pump.dart';
import '../../presentation/providers/petrol_pump_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../widgets/pump_card.dart';
import '../widgets/pump_filter_sheet.dart';
import 'pump_details_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
  });

  @override
  State<MapScreen> createState() =>
      _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  final TextEditingController
      _searchController =
      TextEditingController();

  static const LatLng _defaultLocation =
      LatLng(
    23.8103,
    90.4125,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) return;

      final provider =
          context.read<PetrolPumpProvider>();

      provider.loadPumps();

      provider.loadCurrentLocation();

      provider.startLocationTracking();

      final notificationProvider =
          context.read<NotificationProvider>();

      notificationProvider
          .loadNotifications();

      notificationProvider
          .startRealtime();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();

    _mapController?.dispose();

    super.dispose();
  }

  // ============================================================
  // Petrol Pump Markers + User Direction Marker
  // ============================================================

  Set<Marker> _markers(
    List<PetrolPump> pumps,
    PetrolPumpProvider provider,
  ) {
    final Set<Marker> markers =
        pumps.map((pump) {
      return Marker(
        markerId: MarkerId(
          pump.id,
        ),
        position: LatLng(
          pump.latitude,
          pump.longitude,
        ),
        infoWindow: InfoWindow(
          title: pump.name,
          snippet: pump.address,
        ),
        onTap: () {
          provider.selectPump(
            pump,
          );
        },
      );
    }).toSet();

    // ----------------------------------------------------------
    // User Location Marker
    // ----------------------------------------------------------

    if (provider.hasCurrentLocation) {
      markers.add(
        Marker(
          markerId:
              const MarkerId(
            'my_location',
          ),
          position: LatLng(
            provider.latitude!,
            provider.longitude!,
          ),

          // Device direction.
          rotation:
              provider.heading,

          // Keep marker centered.
          anchor:
              const Offset(
            0.5,
            0.5,
          ),

          // Marker rotates naturally.
          flat: true,

          zIndex: 100,

          icon:
              BitmapDescriptor
                  .defaultMarkerWithHue(
            BitmapDescriptor
                .hueAzure,
          ),
        ),
      );
    }

    return markers;
  }

  // ============================================================
  // Go To Current Location
  // ============================================================

  Future<void> _goToCurrentLocation(
    PetrolPumpProvider provider,
  ) async {
    await provider
        .moveToCurrentLocation();

    if (!mounted) return;

    if (!provider.hasCurrentLocation) {
      return;
    }

    final LatLng location =
        LatLng(
      provider.latitude!,
      provider.longitude!,
    );

    await _mapController
        ?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 16,
          bearing:
              provider.heading,
        ),
      ),
    );
  }

  // ============================================================
  // Filters
  // ============================================================

  Future<void> _showFilters(
    PetrolPumpProvider provider,
  ) async {
    final fuelTypes =
        provider.pumps
            .expand(
              (pump) =>
                  pump.fuelTypes,
            )
            .where(
              (fuel) =>
                  fuel.trim().isNotEmpty,
            )
            .toSet()
            .toList()
          ..sort();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return PumpFilterSheet(
          initialFilter:
              provider.filter,
          initialSort:
              provider.sortOption,
          fuelTypes: fuelTypes,
          onApply:
              (filter, sort) {
            provider.setFilter(
              filter,
            );

            provider
                .setSortOption(
              sort,
            );
          },
        );
      },
    );
  }

  // ============================================================
  // Top Right Menu
  // ============================================================

  Widget _buildMenuButton(
    BuildContext context,
  ) {
    return MouseRegion(
      cursor:
          SystemMouseCursors.click,
      child: Material(
        elevation: 4,
        color: Colors.white,
        shape:
            const CircleBorder(),
        child:
            PopupMenuButton<String>(
          tooltip:
              'More options',
          icon: const Icon(
            Icons.more_vert,
            color:
                Colors.black87,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
          elevation: 8,
          onSelected:
              (value) {
            switch (value) {
              case 'profile':
                Navigator.pushNamed(
                  context,
                  '/profile',
                );
                break;

              case 'favorites':
                Navigator.pushNamed(
                  context,
                  '/favorites',
                );
                break;

              case 'notifications':
                Navigator.pushNamed(
                  context,
                  '/notifications',
                );
                break;

              case 'admin':
                Navigator.pushNamed(
                  context,
                  '/admin-dashboard',
                );
                break;

              case 'settings':
                Navigator.pushNamed(
                  context,
                  '/settings',
                );
                break;
            }
          },
          itemBuilder:
              (context) {
            return [
              const PopupMenuItem<
                  String>(
                value: 'profile',
                child: ListTile(
                  leading: Icon(
                    Icons
                        .person_outline,
                  ),
                  title:
                      Text('Profile'),
                  contentPadding:
                      EdgeInsets
                          .zero,
                ),
              ),
              const PopupMenuItem<
                  String>(
                value: 'favorites',
                child: ListTile(
                  leading: Icon(
                    Icons
                        .favorite_border,
                  ),
                  title:
                      Text('Favorites'),
                  contentPadding:
                      EdgeInsets
                          .zero,
                ),
              ),
              PopupMenuItem<String>(
                value:
                    'notifications',
                child:
                    Consumer<
                        NotificationProvider>(
                  builder: (
                    context,
                    notificationProvider,
                    _,
                  ) {
                    return ListTile(
                      contentPadding:
                          EdgeInsets
                              .zero,
                      leading:
                          Badge(
                        isLabelVisible:
                            notificationProvider
                                    .unreadCount >
                                0,
                        label:
                            Text(
                          notificationProvider
                                      .unreadCount >
                                  99
                              ? '99+'
                              : notificationProvider
                                  .unreadCount
                                  .toString(),
                        ),
                        child:
                            const Icon(
                          Icons
                              .notifications_none,
                        ),
                      ),
                      title:
                          const Text(
                        'Notifications',
                      ),
                    );
                  },
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<
                  String>(
                value: 'admin',
                child: ListTile(
                  leading: Icon(
                    Icons
                        .admin_panel_settings_outlined,
                  ),
                  title:
                      Text('Admin'),
                  contentPadding:
                      EdgeInsets
                          .zero,
                ),
              ),
              const PopupMenuItem<
                  String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(
                    Icons
                        .settings_outlined,
                  ),
                  title:
                      Text('Settings'),
                  contentPadding:
                      EdgeInsets
                          .zero,
                ),
              ),
            ];
          },
        ),
      ),
    );
  }

  // ============================================================
  // Search Bar
  // ============================================================

  Widget _buildSearchBar(
    BuildContext context,
    PetrolPumpProvider provider,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: MouseRegion(
            cursor:
                SystemMouseCursors.text,
            child: Material(
              elevation: 4,
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
              child: TextField(
                controller:
                    _searchController,
                textInputAction:
                    TextInputAction.search,
                onSubmitted:
                    provider.search,
                decoration:
                    InputDecoration(
                  hintText:
                      'Search petrol pumps',
                  prefixIcon:
                      const Icon(
                    Icons.search,
                  ),
                  suffixIcon:
                      provider.searchQuery
                              .isNotEmpty
                          ? IconButton(
                              onPressed:
                                  () {
                                _searchController
                                    .clear();

                                provider
                                    .clearSearch();
                              },
                              icon:
                                  const Icon(
                                Icons.clear,
                              ),
                            )
                          : null,
                  filled: true,
                  fillColor:
                      Theme.of(
                    context,
                  ).colorScheme.surface,
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),
                ),
                onChanged:
                    (_) {
                  // No setState().
                  //
                  // Search state belongs
                  // to Provider.
                },
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        _buildMenuButton(
          context,
        ),
      ],
    );
  }

  // ============================================================
  // Filter Section
  // ============================================================

  Widget _buildFilterSection(
    BuildContext context,
    PetrolPumpProvider provider,
  ) {
    return Row(
      children: [
        MouseRegion(
          cursor:
              SystemMouseCursors.click,
          child: ChoiceChip(
            label:
                const Text('All'),
            selected:
                !provider.nearbyOnly,
            onSelected:
                (selected) async {
              if (!selected) {
                return;
              }

              await provider
                  .loadPumps();
            },
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        MouseRegion(
          cursor:
              SystemMouseCursors.click,
          child: ChoiceChip(
            label:
                const Text('Nearby'),
            selected:
                provider.nearbyOnly,
            onSelected:
                (selected) async {
              if (!selected) {
                return;
              }

              await provider
                  .loadNearbyPumps();
            },
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: MouseRegion(
            cursor:
                SystemMouseCursors.click,
            child: Material(
              elevation: 2,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              color:
                  Theme.of(
                context,
              ).colorScheme.surface,
              child:
                  OutlinedButton.icon(
                onPressed:
                    () {
                  _showFilters(
                    provider,
                  );
                },
                icon: Icon(
                  Icons.tune,
                  size: 18,
                  color: provider
                          .hasActiveFilters
                      ? Theme.of(
                          context,
                        )
                          .colorScheme
                          .primary
                      : null,
                ),
                label: Text(
                  provider
                          .hasActiveFilters
                      ? 'Filter applied'
                      : 'Filter',
                ),
                style:
                    OutlinedButton.styleFrom(
                  backgroundColor:
                      provider
                              .hasActiveFilters
                          ? Theme.of(
                              context,
                            )
                              .colorScheme
                              .primaryContainer
                          : Theme.of(
                              context,
                            )
                              .colorScheme
                              .surface,
                  foregroundColor:
                      provider
                              .hasActiveFilters
                          ? Theme.of(
                              context,
                            )
                              .colorScheme
                              .onPrimaryContainer
                          : Theme.of(
                              context,
                            )
                              .colorScheme
                              .onSurface,
                  side:
                      BorderSide(
                    color: provider
                            .hasActiveFilters
                        ? Theme.of(
                            context,
                          )
                            .colorScheme
                            .primary
                        : Theme.of(
                            context,
                          )
                            .colorScheme
                            .outline,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Horizontal Pump Cards
  // ============================================================

  Widget _buildPumpCards(
    BuildContext context,
    PetrolPumpProvider provider,
  ) {
    if (provider.pumps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: SizedBox(
        height: 118,
        child: ScrollConfiguration(
          behavior:
              const MaterialScrollBehavior()
                  .copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child:
              ListView.separated(
            scrollDirection:
                Axis.horizontal,
            physics:
                const BouncingScrollPhysics(),
            itemCount:
                provider.pumps.length,
            separatorBuilder:
                (_, __) {
              return const SizedBox(
                width: 10,
              );
            },
            itemBuilder:
                (context, index) {
              final pump =
                  provider.pumps[
                      index];

              return MouseRegion(
                cursor:
                    SystemMouseCursors.click,
                child: SizedBox(
                  width:
                      MediaQuery.sizeOf(
                            context,
                          ).width *
                          .82,
                  child: PumpCard(
                    pump: pump,
                    onTap: () {
                      provider
                          .selectPump(
                        pump,
                      );

                      _mapController
                          ?.animateCamera(
                        CameraUpdate
                            .newLatLngZoom(
                          LatLng(
                            pump.latitude,
                            pump.longitude,
                          ),
                          15,
                        ),
                      );
                    },
                    onFavorite:
                        () {
                      provider
                          .toggleFavorite(
                        pump,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body:
          Consumer<PetrolPumpProvider>(
        builder: (
          context,
          provider,
          _,
        ) {
          final selected =
              provider.selectedPump;

          return Stack(
            children: [
              // ==================================================
              // Google Map
              // ==================================================

              GoogleMap(
                initialCameraPosition:
                    const CameraPosition(
                  target:
                      _defaultLocation,
                  zoom: 12,
                ),

                markers: _markers(
                  provider.pumps,
                  provider,
                ),

                myLocationEnabled:
                    false,

                myLocationButtonEnabled:
                    false,

                zoomControlsEnabled:
                    false,

                compassEnabled: true,

                onMapCreated:
                    (controller) {
                  _mapController =
                      controller;
                },

                onTap: (_) {
                  provider
                      .clearSelection();
                },
              ),

              // ==================================================
              // Top Controls
              // ==================================================

              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    16,
                    12,
                    16,
                    0,
                  ),
                  child: Column(
                    children: [
                      _buildSearchBar(
                        context,
                        provider,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _buildFilterSection(
                        context,
                        provider,
                      ),
                      if (provider
                          .isLoading)
                        const Padding(
                          padding:
                              EdgeInsets
                                  .only(
                            top: 12,
                          ),
                          child:
                              LinearProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // Pump Cards
              // ==================================================

              if (selected == null)
                _buildPumpCards(
                  context,
                  provider,
                ),

              // ==================================================
              // Map Controls
              // ==================================================

              Positioned(
                right: 16,
                bottom:
                    selected == null
                        ? 150
                        : 180,
                child: MouseRegion(
                  cursor:
                      SystemMouseCursors.click,
                  child: Column(
                    children: [
                      FloatingActionButton
                          .small(
                        heroTag:
                            'zoom_in',
                        onPressed: () {
                          _mapController
                              ?.animateCamera(
                            CameraUpdate
                                .zoomIn(),
                          );
                        },
                        child:
                            const Icon(
                          Icons.add,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      FloatingActionButton
                          .small(
                        heroTag:
                            'zoom_out',
                        onPressed: () {
                          _mapController
                              ?.animateCamera(
                            CameraUpdate
                                .zoomOut(),
                          );
                        },
                        child:
                            const Icon(
                          Icons.remove,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      FloatingActionButton
                          .small(
                        heroTag:
                            'my_location',
                        onPressed:
                            provider
                                    .isLocationLoading
                                ? null
                                : () =>
                                    _goToCurrentLocation(
                                      provider,
                                    ),
                        child: provider
                                .isLocationLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .my_location,
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // Error State
              // ==================================================

              if (provider.errorMessage !=
                      null &&
                  provider.pumps.isEmpty)
                Positioned.fill(
                  child:
                      IgnorePointer(
                    child:
                        Container(
                      alignment:
                          Alignment.center,
                      padding:
                          const EdgeInsets
                              .all(
                        32,
                      ),
                      child: AppError(
                        message:
                            provider
                                .errorMessage!,
                      ),
                    ),
                  ),
                ),

              // ==================================================
              // Selected Pump
              // ==================================================

              if (selected != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: MouseRegion(
                    cursor:
                        SystemMouseCursors.click,
                    child: PumpCard(
                      pump: selected,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PumpDetailsScreen(
                              pump:
                                  selected,
                            ),
                          ),
                        );
                      },
                      onFavorite:
                          () {
                        provider
                            .toggleFavorite(
                          selected,
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}