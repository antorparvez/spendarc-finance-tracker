import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_sample_item.dart';
import '../providers/sample_api_state.dart';

class SampleApiCubit extends Cubit<SampleApiState> {
  SampleApiCubit(this._getSampleItem)
      : super(const SampleApiState(isLoading: false));

  final GetSampleItem _getSampleItem;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearFailure: true));
    try {
      final item = await _getSampleItem();
      emit(
        state.copyWith(isLoading: false, item: item, clearFailure: true),
      );
    } catch (error) {
      final failure = error is Failure
          ? error
          : const UnknownFailure('Failed to load sample');
      emit(
        state.copyWith(
          isLoading: false,
          failure: failure,
          clearItem: true,
        ),
      );
    }
  }
}
