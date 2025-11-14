enum PriorityLevel {
  low,
  medium,
  high,
  critical;

  String get displayName => switch (this) {
        PriorityLevel.low => 'Low',
        PriorityLevel.medium => 'Medium',
        PriorityLevel.high => 'High',
        PriorityLevel.critical => 'Critical',
      };

  int get numericValue => switch (this) {
        PriorityLevel.low => 1,
        PriorityLevel.medium => 2,
        PriorityLevel.high => 3,
        PriorityLevel.critical => 4,
      };
}
