import 'package:waste_track_driver_app/entities/vehicle/model/enums/vehicle_type.dart';

class VehicleTypeMapper {
  static VehicleType parse(String? value) {
    return switch (value?.toUpperCase()) {
      'COMPACTOR' => VehicleType.compactor,
      'TRUCK' => VehicleType.truck,
      'MINI_TRUCK' => VehicleType.miniTruck,
      _ => VehicleType.truck,
    };
  }

  static String toDto(VehicleType type) {
    return switch (type) {
      VehicleType.compactor => 'COMPACTOR',
      VehicleType.truck => 'TRUCK',
      VehicleType.miniTruck => 'MINI_TRUCK',
    };
  }
}
