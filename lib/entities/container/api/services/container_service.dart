import 'package:waste_track_driver_app/entities/container/api/dto/container_response.dart';
import 'package:waste_track_driver_app/entities/container/api/dto/create_container_request.dart';
import 'package:waste_track_driver_app/entities/container/api/dto/update_container_request.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class ContainerService {
  Future<Resource<ContainerResponse>> getById(String id);
  Future<Resource<List<ContainerResponse>>> getAll();
  Future<Resource<List<ContainerResponse>>> getAllByDistrictId(String districtId);
  Future<Resource<List<ContainerResponse>>> getContainersInAlert(String districtId);
  Future<Resource<ContainerResponse>> create(CreateContainerRequest request);
  Future<Resource<ContainerResponse>> update(String id, UpdateContainerRequest request);
  Future<Resource<void>> delete(String id);
}
