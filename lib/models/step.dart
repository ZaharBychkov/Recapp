class Step {
  final int stepNumber;
  final String description;
  final int timeInSeconds;
  bool isCompleted;

  Step({required this.stepNumber, required this.description, required this.timeInSeconds, this.isCompleted = false});
}