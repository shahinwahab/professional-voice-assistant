enum AssistantState {
  idle,
  listening,
  processing,
  speaking,
  paused,
  completed,
}

// Helper extension to get a display string for each state
extension AssistantStateExtension on AssistantState {
  String get displayText {
    switch (this) {
      case AssistantState.idle:
        return 'Tap the mic button to start';
      case AssistantState.listening:
        return 'Listening...';
      case AssistantState.processing:
        return 'Processing...';
      case AssistantState.speaking:
        return 'Speaking...';
      case AssistantState.paused:
        return 'Paused - Tap play to resume';
      case AssistantState.completed:
        return 'Ready for a new question';
    }
  }
}
