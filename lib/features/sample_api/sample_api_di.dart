import '../../core/network/base_api_service.dart';
import 'data/datasources/sample_api_remote_datasource.dart';
import 'data/repositories/sample_api_repository_impl.dart';
import 'domain/usecases/get_sample_item.dart';
import 'presentation/cubit/sample_api_cubit.dart';

/// Feature wiring: datasource → repository → use case → cubit.
class SampleApiDi {
  SampleApiDi._();

  static SampleApiCubit createCubit(BaseApiService apiService) {
    final remote = SampleApiRemoteDataSource(apiService);
    final repository = SampleApiRepositoryImpl(remote);
    return SampleApiCubit(GetSampleItem(repository));
  }
}
