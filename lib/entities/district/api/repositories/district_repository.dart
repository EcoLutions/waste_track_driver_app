import 'package:waste_track_driver_app/entities/district/model/entities/district.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';

abstract class DistrictRepository {
  Future<Resource<District>> getById(String id);

  Future<Resource<List<District>>> getAll();

  Future<Resource<District>> create({
    required District district,
    required String primaryAdminEmail,
    required String primaryAdminUsername,
    required String planId,
  });

  Future<Resource<District>> update(District district);

  Future<Resource<void>> delete(String id);
}
