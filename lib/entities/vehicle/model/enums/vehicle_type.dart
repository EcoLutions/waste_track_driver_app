enum VehicleType {
  compactor,
  truck,
  miniTruck;

  String get displayName => switch (this) {
        VehicleType.compactor => 'Compactor',
        VehicleType.truck => 'Truck',
        VehicleType.miniTruck => 'Mini Truck',
      };
}
