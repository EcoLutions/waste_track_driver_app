enum ContainerType {
  organic,
  recyclable,
  general;

  String get displayName => switch (this) {
        ContainerType.organic => 'Organic',
        ContainerType.recyclable => 'Recyclable',
        ContainerType.general => 'General',
      };
}
