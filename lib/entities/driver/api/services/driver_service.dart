import 'package:waste_track_driver_app/entities/driver/api/dto/create_driver_request.dart';
import 'package:waste_track_driver_app/entities/driver/api/dto/driver_response.dart';
import 'package:waste_track_driver_app/entities/driver/api/dto/update_driver_request.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class DriverService {
  Future<Resource<DriverResponse>> getById(String id);
  Future<Resource<List<DriverResponse>>> getAll();
  Future<Resource<List<DriverResponse>>> getAllByDistrictId(String districtId);
  Future<Resource<DriverResponse>> create(CreateDriverRequest request);
  Future<Resource<DriverResponse>> update(UpdateDriverRequest request);
  Future<Resource<void>> delete(String id);
}
