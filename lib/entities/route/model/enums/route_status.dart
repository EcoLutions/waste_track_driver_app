enum RouteStatus {
  planned,
  active,
  inProgress,
  completed,
  cancelled;

  String get displayName => switch (this) {
        RouteStatus.planned => 'Planificado',
        RouteStatus.active => 'Activado',
        RouteStatus.inProgress => 'En progreso',
        RouteStatus.completed => 'Completado',
        RouteStatus.cancelled => 'Cancelado',
      };
}
