import 'package:waste_track_driver_app/entities/district/model/enums/operational_status.dart';

class OperationalStatusMapper {
  static OperationalStatus parse(String? status) {
    if (status == null || status.isEmpty) {
      return OperationalStatus.active;
    }

    try {
      return OperationalStatusExtension.fromString(status);
    } catch (e) {
      return OperationalStatus.active;
    }
  }
}
