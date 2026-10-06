/// Satu soal pada halaman pembahasan (dari snapshot attempt).
class ReviewQuestion {
  final int id;
  final int orderNumber;
  final String question;
  final String? questionImage;
  final int tipeSoalId;
  final String? jawabanBenar;
  final String? selectedLabel;
  final String? selectedText;
  final bool? isCorrect; // null untuk tipe weighted (TKP) / belum dijawab
  final int scoreEarned;
  final String? pembahasan;

  ReviewQuestion({
    required this.id,
    required this.orderNumber,
    required this.question,
    this.questionImage,
    required this.tipeSoalId,
    this.jawabanBenar,
    this.selectedLabel,
    this.selectedText,
    this.isCorrect,
    required this.scoreEarned,
    this.pembahasan,
  });

  factory ReviewQuestion.fromJson(Map<String, dynamic> j) => ReviewQuestion(
        id: (j['id']) as int,
        orderNumber: (j['order_number'] ?? 0) as int,
        question: j['question'] ?? '',
        questionImage: j['question_image'],
        tipeSoalId: (j['tipe_soal_id'] ?? 0) as int,
        jawabanBenar: j['jawaban_benar'],
        selectedLabel: j['selected_label'],
        selectedText: j['selected_text'],
        isCorrect: j['is_correct'] as bool?,
        scoreEarned: (j['score_earned'] ?? 0) as int,
        pembahasan: j['pembahasan'],
      );

  bool get dijawab => selectedLabel != null;
}
