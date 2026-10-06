class AttemptScore {
  final int tipeSoalId;
  final String? tipe;
  final int correctCount;
  final int wrongCount;
  final int unansweredCount;
  final int score;
  final int passingGrade;
  final int maxScore;
  final bool isPassed;

  AttemptScore({
    required this.tipeSoalId,
    this.tipe,
    required this.correctCount,
    required this.wrongCount,
    required this.unansweredCount,
    required this.score,
    required this.passingGrade,
    required this.maxScore,
    required this.isPassed,
  });

  factory AttemptScore.fromJson(Map<String, dynamic> j) => AttemptScore(
        tipeSoalId: (j['tipe_soal_id'] ?? 0) as int,
        tipe: j['tipe'],
        correctCount: (j['correct_count'] ?? 0) as int,
        wrongCount: (j['wrong_count'] ?? 0) as int,
        unansweredCount: (j['unanswered_count'] ?? 0) as int,
        score: (j['score'] ?? 0) as int,
        passingGrade: (j['passing_grade'] ?? 0) as int,
        maxScore: (j['max_score'] ?? 0) as int,
        isPassed: j['is_passed'] == true,
      );
}
