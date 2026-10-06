import '../core/api_client.dart';
import '../models/attempt.dart';
import '../models/attempt_question.dart';
import '../models/attempt_score.dart';
import '../models/review_question.dart';

class ResultBundle {
  final Attempt attempt;
  final List<AttemptScore> scores;
  ResultBundle(this.attempt, this.scores);
}

class HeartbeatResult {
  final String status; // ongoing | finished | expired
  final int? remainingSeconds;
  HeartbeatResult(this.status, this.remainingSeconds);

  bool get isOngoing => status == 'ongoing';
}

class AttemptService {
  final ApiClient _api;
  AttemptService({ApiClient? api}) : _api = api ?? ApiClient();

  /// POST /exams/{id}/start — mulai / lanjutkan attempt.
  /// [token] diperlukan bila sesi "ujian di tempat" mengaktifkan token.
  Future<Attempt> start(String examId, {String? token}) async {
    final data = await _api.post('exams/$examId/start', body: {
      if (token != null && token.isNotEmpty) 'token': token,
    });
    return Attempt.fromJson(Map<String, dynamic>.from(data));
  }

  /// GET /attempts/{id} — status + sisa waktu.
  Future<Attempt> show(String attemptId) async {
    final data = await _api.get('attempts/$attemptId');
    return Attempt.fromJson(Map<String, dynamic>.from(data));
  }

  /// GET /attempts/{id}/questions — daftar soal (snapshot, tanpa kunci).
  Future<List<AttemptQuestion>> questions(String attemptId) async {
    final data = await _api.get('attempts/$attemptId/questions');
    return (data as List)
        .map((e) => AttemptQuestion.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// PUT /attempts/{id}/answers — autosave 1 jawaban (idempoten).
  /// [optionId] null = kosongkan jawaban.
  Future<void> saveAnswer(String attemptId, int examAttemptQuestionId, int? optionId) async {
    await _api.put('attempts/$attemptId/answers', body: {
      'exam_attempt_question_id': examAttemptQuestionId,
      'question_option_id': optionId,
    });
  }

  /// POST /attempts/{id}/heartbeat — presence + progress + sinkron timer server.
  Future<HeartbeatResult> heartbeat(String attemptId, {int? current}) async {
    final data = await _api.post('attempts/$attemptId/heartbeat', body: {
      if (current != null) 'current': current,
    });
    final m = Map<String, dynamic>.from(data);
    return HeartbeatResult(m['status'] ?? 'ongoing', m['remaining_seconds'] as int?);
  }

  /// POST /attempts/{id}/finish — submit + scoring.
  Future<ResultBundle> finish(String attemptId) async {
    final data = await _api.post('attempts/$attemptId/finish');
    return _bundle(data);
  }

  /// GET /attempts/{id}/result — hasil per tipe.
  Future<ResultBundle> result(String attemptId) async {
    final data = await _api.get('attempts/$attemptId/result');
    return _bundle(data);
  }

  /// GET /attempts/{id}/review — pembahasan (403 bila sesi tak mengizinkan).
  Future<List<ReviewQuestion>> review(String attemptId) async {
    final data = await _api.get('attempts/$attemptId/review');
    return (data as List)
        .map((e) => ReviewQuestion.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  ResultBundle _bundle(dynamic data) {
    final m = Map<String, dynamic>.from(data);
    return ResultBundle(
      Attempt.fromJson(Map<String, dynamic>.from(m['attempt'])),
      (m['scores'] as List?)
              ?.map((e) => AttemptScore.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
    );
  }
}
