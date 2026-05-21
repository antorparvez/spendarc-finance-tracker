import '../entities/sample_item.dart';
import '../repositories/sample_api_repository.dart';

class GetSampleItem {
  const GetSampleItem(this._repository);

  final SampleApiRepository _repository;

  Future<SampleItem> call() {
    return _repository.getSampleItem();
  }
}
