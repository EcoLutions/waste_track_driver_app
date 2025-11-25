import 'package:waste_track_driver_app/entities/container/api/repositories/container_repository.dart';
import 'package:waste_track_driver_app/entities/container/model/entities/container.dart';
import 'package:waste_track_driver_app/shared/lib/utils/resource.dart';
import 'package:waste_track_driver_app/shared/mock/mock_route_repository.dart';

class MockContainerRepository implements ContainerRepository {
  final MockRouteRepository _routeRepository;

  MockContainerRepository(this._routeRepository);

  @override
  Future<Resource<Container>> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Buscar en todos los datos de ruta
    for (final routeData in _routeRepository.getAllRouteData()) {
      try {
        final container = routeData.waypointsWithContainers
            .map((w) => w.container)
            .firstWhere((c) => c.id == id);
        return Success(container);
      } catch (e) {
        continue;
      }
    }

    return const Failure(
      message: 'Container not found',
      statusCode: 404,
    );
  }

  @override
  Future<Resource<List<Container>>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final allContainers = <Container>[];
    for (final routeData in _routeRepository.getAllRouteData()) {
      allContainers.addAll(
        routeData.waypointsWithContainers.map((w) => w.container),
      );
    }

    return Success(allContainers);
  }

  @override
  Future<Resource<List<Container>>> getAllByDistrictId(String districtId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final containers = <Container>[];
    for (final routeData in _routeRepository.getAllRouteData()) {
      containers.addAll(
        routeData.waypointsWithContainers
            .map((w) => w.container)
            .where((c) => c.districtId == districtId),
      );
    }

    return Success(containers);
  }

  @override
  Future<Resource<List<Container>>> getContainersInAlert(String districtId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final containers = <Container>[];
    for (final routeData in _routeRepository.getAllRouteData()) {
      containers.addAll(
        routeData.waypointsWithContainers
            .map((w) => w.container)
            .where((c) => c.districtId == districtId && c.isCritical),
      );
    }

    return Success(containers);
  }

  @override
  Future<Resource<Container>> create(Container container) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Success(container);
  }

  @override
  Future<Resource<Container>> update(Container container) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Success(container);
  }

  @override
  Future<Resource<void>> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const Success(null);
  }
}
