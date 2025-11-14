import 'package:waste_track_driver_app/entities/vehicle/model/entities/vehicle.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class VehicleRepository {
  Future<Resource<Vehicle>> getById(String id);
  Future<Resource<List<Vehicle>>> getAll();
  Future<Resource<List<Vehicle>>> getAllByDistrictId(String districtId);
  Future<Resource<Vehicle>> create(Vehicle vehicle);
  Future<Resource<Vehicle>> update(Vehicle vehicle);
  Future<Resource<void>> delete(String id);
}
