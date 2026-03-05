import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/schedule.dart';
import 'domain_providers.dart';

class HistoryState {
  final List<Schedule> history;
  final bool isLoading;
  final String? error;

  HistoryState({this.history = const [], this.isLoading = false, this.error});

  HistoryState copyWith({
    List<Schedule>? history,
    bool? isLoading,
    String? error,
  }) {
    return HistoryState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final Ref ref;

  HistoryNotifier(this.ref) : super(HistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    final usecase = ref.read(getHistoryProvider);
    final result = await usecase.execute();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (history) {
        history.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
        state = state.copyWith(isLoading: false, history: history, error: null);
      },
    );
  }

  Future<void> clearHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    final usecase = ref.read(clearHistoryProvider);
    final result = await usecase.execute();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) => loadHistory(),
    );
  }
}

final historyNotifierProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
      return HistoryNotifier(ref);
    });
