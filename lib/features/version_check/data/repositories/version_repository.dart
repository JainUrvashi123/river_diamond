import '../datasources/version_remote_datasource.dart';
import '../models/version_model.dart';

abstract class VersionRepository {
  Future<VersionModel> checkVersion({
    required String version,
    required String platform,
  });
}

class VersionRepositoryImpl implements VersionRepository {
  final VersionRemoteDataSource remoteDataSource;

  VersionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<VersionModel> checkVersion({
    required String version,
    required String platform,
  }) async {
    return await remoteDataSource.checkVersion(
      version: version,
      platform: platform,
    );
  }
}
