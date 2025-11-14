import 'package:waste_track_driver_app/entities/container/model/enums/container_status.dart';
import 'package:waste_track_driver_app/entities/container/model/enums/container_type.dart';

class ContainerTypeMapper {
  static ContainerType parse(String? value) {
    return switch (value?.toUpperCase()) {
      'ORGANIC' => ContainerType.organic,
      'RECYCLABLE' => ContainerType.recyclable,
      'GENERAL' => ContainerType.general,
      _ => ContainerType.general,
    };
  }

  static String toDto(ContainerType type) {
    return switch (type) {
      ContainerType.organic => 'ORGANIC',
      ContainerType.recyclable => 'RECYCLABLE',
      ContainerType.general => 'GENERAL',
    };
  }
}

class ContainerStatusMapper {
  static ContainerStatus parse(String? value) {
    return switch (value?.toUpperCase()) {
      'ACTIVE' => ContainerStatus.active,
      'MAINTENANCE' => ContainerStatus.maintenance,
      'DECOMMISSIONED' => ContainerStatus.decommissioned,
      _ => ContainerStatus.active,
    };
  }

  static String toDto(ContainerStatus status) {
    return switch (status) {
      ContainerStatus.active => 'ACTIVE',
      ContainerStatus.maintenance => 'MAINTENANCE',
      ContainerStatus.decommissioned => 'DECOMMISSIONED',
    };
  }
}
