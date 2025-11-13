import 'package:waste_track_driver_app/entities/district/api/dto/create_district_request.dart';
import 'package:waste_track_driver_app/entities/district/api/dto/district_response.dart';
import 'package:waste_track_driver_app/entities/district/api/dto/update_district_request.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class DistrictService {
  Future<Resource<DistrictResponse>> getById(String id);

  Future<Resource<List<DistrictResponse>>> getAll();

  Future<Resource<DistrictResponse>> create(CreateDistrictRequest request);

  Future<Resource<DistrictResponse>> update(UpdateDistrictRequest request);

  Future<Resource<void>> delete(String id);
}
