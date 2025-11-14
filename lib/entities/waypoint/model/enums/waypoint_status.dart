enum WayPointStatus {
  pending,
  visited,
  skipped;

  String get displayName => switch (this) {
        WayPointStatus.pending => 'Pending',
        WayPointStatus.visited => 'Visited',
        WayPointStatus.skipped => 'Skipped',
      };
}
