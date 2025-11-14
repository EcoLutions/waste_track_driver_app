enum RouteStatus {
  assigned,
  inProgress,
  completed,
  cancelled;

  String get displayName => switch (this) {
        RouteStatus.assigned => 'Assigned',
        RouteStatus.inProgress => 'In Progress',
        RouteStatus.completed => 'Completed',
        RouteStatus.cancelled => 'Cancelled',
      };
}
