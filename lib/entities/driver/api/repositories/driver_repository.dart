import 'package:waste_track_driver_app/entities/driver/model/entities/driver.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class DriverRepository {
  Future<Resource<Driver>> getById(String id);

  Future<Resource<List<Driver>>> getAll();

  Future<Resource<List<Driver>>> getAllByDistrictId(String districtId);

  Future<Resource<Driver>> create(Driver driver);

  Future<Resource<Driver>> update(Driver driver);

  Future<Resource<void>> delete(String id);
}
