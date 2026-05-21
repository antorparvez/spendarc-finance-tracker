import 'package:flutter_bloc/flutter_bloc.dart';

class HomeNavState {
  const HomeNavState({required this.currentIndex, required this.history});

  final int currentIndex;
  final List<int> history;

  bool get canGoBack => history.isNotEmpty;

  HomeNavState copyWith({int? currentIndex, List<int>? history}) {
    return HomeNavState(
      currentIndex: currentIndex ?? this.currentIndex,
      history: history ?? this.history,
    );
  }
}

class HomeNavCubit extends Cubit<HomeNavState> {
  HomeNavCubit() : super(const HomeNavState(currentIndex: 0, history: []));

  void setIndex(int index) {
    if (index == state.currentIndex) return;
    final nextHistory = [...state.history, state.currentIndex];
    emit(
      state.copyWith(currentIndex: index, history: _trim(nextHistory)),
    );
  }

  bool goBack() {
    if (!state.canGoBack) return false;
    final nextHistory = [...state.history]..removeLast();
    final previousIndex = state.history.last;
    emit(
      state.copyWith(currentIndex: previousIndex, history: nextHistory),
    );
    return true;
  }

  List<int> _trim(List<int> items) {
    const maxEntries = 20;
    if (items.length <= maxEntries) return items;
    return items.sublist(items.length - maxEntries);
  }
}
