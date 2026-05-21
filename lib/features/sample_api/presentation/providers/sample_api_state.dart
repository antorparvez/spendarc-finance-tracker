import '../../../../core/errors/failures.dart';
import '../../domain/entities/sample_item.dart';

class SampleApiState {
  const SampleApiState({this.isLoading = false, this.item, this.failure});

  final bool isLoading;
  final SampleItem? item;
  final Failure? failure;

  SampleApiState copyWith({
    bool? isLoading,
    SampleItem? item,
    Failure? failure,
    bool clearFailure = false,
    bool clearItem = false,
  }) {
    return SampleApiState(
      isLoading: isLoading ?? this.isLoading,
      item: clearItem ? null : (item ?? this.item),
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}
