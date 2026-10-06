class Attempt {
  final String id;
  final String examSessionId;
  final int attemptNumber;
  final String status; // ongoing | finished | expired
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final DateTime? expiresAt;
  final int? remainingSeconds;
  final int totalScore;
  final bool isPassed;

  Attempt({
    required this.id,
    required this.examSessionId,
    required this.attemptNumber,
    required this.status,
    this.startedAt,
    this.finishedAt,
    this.expiresAt,
    this.remainingSeconds,
    required this.totalScore,
    required this.isPassed,
  });

  factory Attempt.fromJson(Map<String, dynamic> j) => Attempt(
        id: j['id'].toString(),
        examSessionId: j['exam_session_id'].toString(),
        attemptNumber: (j['attempt_number'] ?? 1) as int,
        status: j['status'] ?? 'ongoing',
        startedAt: j['started_at'] != null ? DateTime.tryParse(j['started_at']) : null,
        finishedAt: j['finished_at'] != null ? DateTime.tryParse(j['finished_at']) : null,
        expiresAt: j['expires_at'] != null ? DateTime.tryParse(j['expires_at']) : null,
        remainingSeconds: j['remaining_seconds'] as int?,
        totalScore: (j['total_score'] ?? 0) as int,
        isPassed: j['is_passed'] == true,
      );

  bool get isOngoing => status == 'ongoing';
  bool get isFinished => status == 'finished' || status == 'expired';
}
