import '../entities/sample_item.dart';

abstract class SampleApiRepository {
  Future<SampleItem> getSampleItem();
}
