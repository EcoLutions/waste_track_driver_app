import 'package:waste_track_driver_app/entities/driver/model/enums/driver_status.dart';

class DriverStatusMapper {
  static DriverStatus parse(String? status) {
    if (status == null || status.isEmpty) {
      return DriverStatus.available;
    }

    try {
      return DriverStatusExtension.fromString(status);
    } catch (e) {
      return DriverStatus.available;
    }
  }

  static String parseToString(DriverStatus status) {
    return status.toString();
  }
}
