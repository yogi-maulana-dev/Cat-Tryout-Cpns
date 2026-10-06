import '../core/api_client.dart';
import '../models/exam.dart';
import '../models/history_item.dart';
import '../models/paginated.dart';

class RankingEntry {
  final int rank;
  final String userId;
  final String? name;
  final int bestScore;
  RankingEntry(this.rank, this.userId, this.name, this.bestScore);

  factory RankingEntry.fromJson(Map<String, dynamic> j) => RankingEntry(
        (j['rank'] ?? 0) as int,
        j['user_id'].toString(),
        j['name'],
        (j['best_score'] ?? 0) as int,
      );
}

class RankingResult {
  final int totalPeserta;
  final int? myRank;
  final int myBestScore;
  final List<RankingEntry> ranking;
  RankingResult(this.totalPeserta, this.myRank, this.myBestScore, this.ranking);
}

class ExamService {
  final ApiClient _api;
  ExamService({ApiClient? api}) : _api = api ?? ApiClient();

  /// GET /exams — daftar tryout aktif (paginated).
  Future<Paginated<Exam>> list({int page = 1}) async {
    final data = await _api.get('exams', query: {'page': page});
    return Paginated.fromJson(
      Map<String, dynamic>.from(data),
      (m) => Exam.fromJson(m),
    );
  }

  /// GET /exams/{id} — detail + komposisi soal.
  Future<Exam> detail(String examId) async {
    final data = await _api.get('exams/$examId');
    return Exam.fromJson(Map<String, dynamic>.from(data));
  }

  /// GET /me/history — riwayat pengerjaan.
  Future<Paginated<HistoryItem>> history({int page = 1}) async {
    final data = await _api.get('me/history', query: {'page': page});
    return Paginated.fromJson(
      Map<String, dynamic>.from(data),
      (m) => HistoryItem.fromJson(m),
    );
  }

  /// GET /exams/{id}/ranking
  Future<RankingResult> ranking(String examId) async {
    final data = await _api.get('exams/$examId/ranking');
    final m = Map<String, dynamic>.from(data);
    return RankingResult(
      (m['total_peserta'] ?? 0) as int,
      m['my_rank'] as int?,
      (m['my_best_score'] ?? 0) as int,
      (m['ranking'] as List?)
              ?.map((e) => RankingEntry.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
    );
  }
}
