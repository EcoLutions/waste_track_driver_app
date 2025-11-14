enum ContainerStatus {
  active,
  maintenance,
  decommissioned;

  String get displayName => switch (this) {
        ContainerStatus.active => 'Active',
        ContainerStatus.maintenance => 'Maintenance',
        ContainerStatus.decommissioned => 'Decommissioned',
      };
}
