class DriverStats {

  DriverStats({
    required this.totalRoutesCompleted,
    required this.totalContainersCollected,
    required this.totalDistanceKm,
  });
  final int totalRoutesCompleted;
  final int totalContainersCollected;
  final double totalDistanceKm;

  String get formattedDistance {
    return '${totalDistanceKm.toStringAsFixed(1)} km';
  }
}