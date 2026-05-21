import 'package:riverpod_boilerplate/core/errors/error_handler.dart';

import '../../domain/entities/sample_item.dart';
import '../../domain/repositories/sample_api_repository.dart';
import '../datasources/sample_api_remote_datasource.dart';

class SampleApiRepositoryImpl implements SampleApiRepository {
  const SampleApiRepositoryImpl(this._remoteDataSource);

  final SampleApiRemoteDataSource _remoteDataSource;

  @override
  Future<SampleItem> getSampleItem() async {
    try {
      final model = await _remoteDataSource.getSampleItem();
      return model.toEntity();
    } catch (error) {
      throw ErrorHandler.mapToFailure(error);
    }
  }
}
