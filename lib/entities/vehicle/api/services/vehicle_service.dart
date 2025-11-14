import 'package:waste_track_driver_app/entities/vehicle/api/dto/create_vehicle_request.dart';
import 'package:waste_track_driver_app/entities/vehicle/api/dto/update_vehicle_request.dart';
import 'package:waste_track_driver_app/entities/vehicle/api/dto/vehicle_response.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class VehicleService {
  Future<Resource<VehicleResponse>> getById(String id);
  Future<Resource<List<VehicleResponse>>> getAll();
  Future<Resource<List<VehicleResponse>>> getAllByDistrictId(String districtId);
  Future<Resource<VehicleResponse>> create(CreateVehicleRequest request);
  Future<Resource<VehicleResponse>> update(UpdateVehicleRequest request);
  Future<Resource<void>> delete(String id);
}
