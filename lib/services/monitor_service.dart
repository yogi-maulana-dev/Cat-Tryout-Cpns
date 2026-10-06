import '../core/api_client.dart';

class MonitorParticipant {
  final String attemptId;
  final String userId;
  final String status; // working | finished | expired
  final int answered;
  final int total;
  final int? current;
  final DateTime? updatedAt;

  MonitorParticipant({
    required this.attemptId,
    required this.userId,
    required this.status,
    required this.answered,
    required this.total,
    this.current,
    this.updatedAt,
  });

  factory MonitorParticipant.fromJson(Map<String, dynamic> j) => MonitorParticipant(
        attemptId: j['attempt_id'].toString(),
        userId: (j['user_id'] ?? '').toString(),
        status: j['status'] ?? 'working',
        answered: (j['answered'] ?? 0) as int,
        total: (j['total'] ?? 0) as int,
        current: j['current'] as int?,
        updatedAt: j['updated_at'] != null ? DateTime.tryParse(j['updated_at']) : null,
      );

  /// Dianggap "disconnect" bila tak ada aktivitas > 60 detik saat masih working.
  bool get isStale =>
      status == 'working' &&
      updatedAt != null &&
      DateTime.now().difference(updatedAt!).inSeconds > 60;
}

class MonitorSnapshot {
  final int total;
  final int working;
  final int finished;
  final int expired;
  final List<MonitorParticipant> participants;

  MonitorSnapshot(this.total, this.working, this.finished, this.expired, this.participants);
}

/// Live monitoring (khusus admin). Backend: GET /admin/exams/{id}/monitor.
class MonitorService {
  final ApiClient _api;
  MonitorService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<MonitorSnapshot> snapshot(String examId) async {
    final data = await _api.get('admin/exams/$examId/monitor');
    final m = Map<String, dynamic>.from(data);
    final agg = Map<String, dynamic>.from(m['aggregate'] ?? {});
    final parts = (m['participants'] as List?)
            ?.map((e) => MonitorParticipant.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        <MonitorParticipant>[];

    return MonitorSnapshot(
      (agg['total'] ?? 0) as int,
      (agg['working'] ?? 0) as int,
      (agg['finished'] ?? 0) as int,
      (agg['expired'] ?? 0) as int,
      parts,
    );
  }
}
