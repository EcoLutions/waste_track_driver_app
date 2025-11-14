enum RouteType {
  regular,
  emergency,
  optimized;

  String get displayName => switch (this) {
        RouteType.regular => 'Regular',
        RouteType.emergency => 'Emergency',
        RouteType.optimized => 'Optimized',
      };
}
