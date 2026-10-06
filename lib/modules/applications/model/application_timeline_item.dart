class ApplicationTimelineItem {
  final String title;
  final bool isCompleted;
  final bool isCurrent;
  final bool isInterviewStage;
  final bool hasInterviewSchedule;
  final DateTime? timestamp;
  final String interviewMode;
  final String interviewAddress;
  final String interviewLink;

  const ApplicationTimelineItem({
    required this.title,
    required this.isCompleted,
    required this.isCurrent,
    required this.isInterviewStage,
    required this.hasInterviewSchedule,
    required this.timestamp,
    required this.interviewMode,
    required this.interviewAddress,
    required this.interviewLink,
  });
}