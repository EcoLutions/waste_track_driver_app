import 'package:waste_track_driver_app/entities/container/model/entities/container.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class ContainerRepository {
  Future<Resource<Container>> getById(String id);
  Future<Resource<List<Container>>> getAll();
  Future<Resource<List<Container>>> getAllByDistrictId(String districtId);
  Future<Resource<List<Container>>> getContainersInAlert(String districtId);
  Future<Resource<Container>> create(Container container);
  Future<Resource<Container>> update(Container container);
  Future<Resource<void>> delete(String id);
}