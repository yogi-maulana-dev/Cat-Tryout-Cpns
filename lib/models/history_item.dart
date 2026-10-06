class HistoryItem {
  final String attemptId;
  final String examSessionId;
  final String? namaSesi;
  final int attemptNumber;
  final String status;
  final int totalScore;
  final bool isPassed;
  final DateTime? finishedAt;

  HistoryItem({
    required this.attemptId,
    required this.examSessionId,
    this.namaSesi,
    required this.attemptNumber,
    required this.status,
    required this.totalScore,
    required this.isPassed,
    this.finishedAt,
  });

  bool get isOngoing => status == 'ongoing';
  bool get isFinished => status == 'finished' || status == 'expired';

  factory HistoryItem.fromJson(Map<String, dynamic> j) => HistoryItem(
        attemptId: j['attempt_id'].toString(),
        examSessionId: j['exam_session_id'].toString(),
        namaSesi: j['nama_sesi'],
        attemptNumber: (j['attempt_number'] ?? 1) as int,
        status: j['status'] ?? '',
        totalScore: (j['total_score'] ?? 0) as int,
        isPassed: j['is_passed'] == true,
        finishedAt: j['finished_at'] != null ? DateTime.tryParse(j['finished_at']) : null,
      );
}
