import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/petrol_pump.dart';

class PetrolPumpModel extends PetrolPump {
  const PetrolPumpModel({
    required super.id,
    required super.name,
    required super.address,
    required super.latitude,
    required super.longitude,
    super.phone,
    super.rating,
    super.reviewCount,
    super.isOpen,
    super.openingHours,
    super.logoUrl,
    super.fuelTypes,
    super.fuelPrices,
    super.distanceKm,
    super.isFavorite,
  });

  factory PetrolPumpModel.fromMap(Map<String, dynamic> map) {
    return PetrolPumpModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      phone: map['phone']?.toString(),
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (map['review_count'] as num?)?.toInt() ?? 0,
      isOpen: map['is_open'] as bool? ?? true,
      openingHours: map['opening_hours']?.toString(),
      logoUrl: map['logo_url']?.toString(),
      fuelTypes: List<String>.from(map['fuel_types'] ?? const []),
      fuelPrices: Map<String, double>.fromEntries(
        (map['fuel_prices'] is Map ? Map<String, dynamic>.from(map['fuel_prices']) : const <String, dynamic>{})
            .entries
            .map((entry) => MapEntry(entry.key, (entry.value as num).toDouble())),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'rating': rating,
      'review_count': reviewCount,
      'is_open': isOpen,
      'opening_hours': openingHours,
      'logo_url': logoUrl,
      'fuel_types': fuelTypes,
      'fuel_prices': fuelPrices,
    };
  }
}

/// Manual Hive adapter so build_runner is not required.
class PetrolPumpModelAdapter extends TypeAdapter<PetrolPumpModel> {
  @override
  final int typeId = 1;

  @override
  PetrolPumpModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };

    return PetrolPumpModel(
      id: fields[0] as String? ?? '',
      name: fields[1] as String? ?? '',
      address: fields[2] as String? ?? '',
      latitude: (fields[3] as num?)?.toDouble() ?? 0,
      longitude: (fields[4] as num?)?.toDouble() ?? 0,
      phone: fields[5] as String?,
      rating: (fields[6] as num?)?.toDouble() ?? 0,
      reviewCount: fields[7] as int? ?? 0,
      isOpen: fields[8] as bool? ?? true,
      openingHours: fields[9] as String?,
      logoUrl: fields[10] as String?,
      fuelTypes: List<String>.from(fields[11] as List? ?? const []),
      distanceKm: (fields[12] as num?)?.toDouble() ?? 0,
      isFavorite: fields[13] as bool? ?? false,
      fuelPrices: Map<String, double>.fromEntries(
        (fields[14] as Map? ?? const {}).entries.map((e) => MapEntry(e.key.toString(), (e.value as num).toDouble())),
      ),
    );
  }

  @override
  void write(BinaryWriter writer, PetrolPumpModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.rating)
      ..writeByte(7)
      ..write(obj.reviewCount)
      ..writeByte(8)
      ..write(obj.isOpen)
      ..writeByte(9)
      ..write(obj.openingHours)
      ..writeByte(10)
      ..write(obj.logoUrl)
      ..writeByte(11)
      ..write(obj.fuelTypes)
      ..writeByte(12)
      ..write(obj.distanceKm)
      ..writeByte(13)
      ..write(obj.isFavorite)
      ..writeByte(14)
      ..write(obj.fuelPrices);
  }
}
