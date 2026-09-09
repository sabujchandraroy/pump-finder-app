class PetrolPump {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phone;
  final double rating;
  final int reviewCount;
  final bool isOpen;
  final String? openingHours;
  final String? logoUrl;
  final List<String> fuelTypes;
  final Map<String, double> fuelPrices;
  final double distanceKm;
  final bool isFavorite;

  const PetrolPump({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.rating = 0,
    this.reviewCount = 0,
    this.isOpen = true,
    this.openingHours,
    this.logoUrl,
    this.fuelTypes = const [],
    this.fuelPrices = const {},
    this.distanceKm = 0,
    this.isFavorite = false,
  });

  PetrolPump copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    double? rating,
    int? reviewCount,
    bool? isOpen,
    String? openingHours,
    String? logoUrl,
    List<String>? fuelTypes,
    Map<String, double>? fuelPrices,
    double? distanceKm,
    bool? isFavorite,
  }) {
    return PetrolPump(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isOpen: isOpen ?? this.isOpen,
      openingHours: openingHours ?? this.openingHours,
      logoUrl: logoUrl ?? this.logoUrl,
      fuelTypes: fuelTypes ?? this.fuelTypes,
      fuelPrices: fuelPrices ?? this.fuelPrices,
      distanceKm: distanceKm ?? this.distanceKm,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
