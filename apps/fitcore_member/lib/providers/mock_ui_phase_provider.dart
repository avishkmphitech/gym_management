import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MockUiPhase { loading, empty, filled, error }

final mockUiPhaseProvider =
    NotifierProvider<MockUiPhaseNotifier, MockUiPhase>(MockUiPhaseNotifier.new);

class MockUiPhaseNotifier extends Notifier<MockUiPhase> {
  @override
  MockUiPhase build() => MockUiPhase.filled;

  void setPhase(MockUiPhase phase) => state = phase;
}
