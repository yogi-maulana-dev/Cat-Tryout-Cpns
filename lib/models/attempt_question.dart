class OptionItem {
  final int id;
  final String optionLabel;
  final String optionText;
  final String? gambarJawaban;

  OptionItem({
    required this.id,
    required this.optionLabel,
    required this.optionText,
    this.gambarJawaban,
  });

  factory OptionItem.fromJson(Map<String, dynamic> j) => OptionItem(
        id: (j['id']) as int,
        optionLabel: j['option_label'] ?? '',
        optionText: j['option_text'] ?? '',
        gambarJawaban: j['gambar_jawaban'],
      );
}

/// Soal dalam sebuah attempt (dari snapshot — TANPA kunci jawaban).
class AttemptQuestion {
  final int id; // exam_attempt_question_id
  final int orderNumber;
  final String question;
  final String? questionImage;
  final int tipeSoalId;
  final List<OptionItem> options;
  int? selectedOptionId; // mutable: pilihan peserta saat ini

  AttemptQuestion({
    required this.id,
    required this.orderNumber,
    required this.question,
    this.questionImage,
    required this.tipeSoalId,
    required this.options,
    this.selectedOptionId,
  });

  factory AttemptQuestion.fromJson(Map<String, dynamic> j) => AttemptQuestion(
        id: (j['id']) as int,
        orderNumber: (j['order_number'] ?? 0) as int,
        question: j['question'] ?? '',
        questionImage: j['question_image'],
        tipeSoalId: (j['tipe_soal_id'] ?? 0) as int,
        options: (j['options'] as List?)
                ?.map((e) => OptionItem.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            const [],
        selectedOptionId: j['selected_option_id'] as int?,
      );

  bool get isAnswered => selectedOptionId != null;
}
