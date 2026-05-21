import 'package:riverpod_boilerplate/core/constants/api_constants.dart';
import 'package:riverpod_boilerplate/core/network/api_map_utils.dart';
import 'package:riverpod_boilerplate/core/network/base_api_service.dart';

import '../models/sample_item_model.dart';

class SampleApiRemoteDataSource {
  const SampleApiRemoteDataSource(this._apiService);

  final BaseApiService _apiService;

  Future<SampleItemModel> getSampleItem() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      ApiConstants.sampleProductDetail,
    );
    return SampleItemModel.fromJson(coerceJsonMap(response.data));
  }
}
