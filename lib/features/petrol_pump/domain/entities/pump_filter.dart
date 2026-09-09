class PumpFilter {
  final double? maxDistanceKm;
  final double? minimumRating;
  final bool openNowOnly;
  final String? fuelType;

  const PumpFilter({
    this.maxDistanceKm,
    this.minimumRating,
    this.openNowOnly = false,
    this.fuelType,
  });

  bool get hasFilters =>
      maxDistanceKm != null ||
      minimumRating != null ||
      openNowOnly ||
      fuelType != null;
}
