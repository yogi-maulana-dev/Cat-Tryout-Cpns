import 'dart:async';

import 'package:flutter/material.dart';

import '../core/reverb_client.dart';
import '../services/monitor_service.dart';

/// Live monitoring admin — REALTIME via WebSocket Reverb (event `monitor.updated`
/// untuk agregat) + snapshot HTTP untuk daftar peserta. Polling lambat (30 dtk)
/// sebagai fallback bila WebSocket terputus.
class MonitorScreen extends StatefulWidget {
  final String examId;
  final String? examTitle;
  const MonitorScreen({super.key, required this.examId, this.examTitle});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  final _service = MonitorService();
  ReverbMonitorClient? _realtime;
  Timer? _poll;

  MonitorSnapshot? _snap;
  String? _error;
  String _connState = 'connecting';

  @override
  void initState() {
    super.initState();
    _fetch();
    _connectRealtime();
    // Fallback: kalau WebSocket putus, tetap perbarui tiap 30 dtk.
    _poll = Timer.periodic(const Duration(seconds: 30), (_) => _fetch());
  }

  @override
  void dispose() {
    _poll?.cancel();
    _realtime?.disconnect();
    super.dispose();
  }

  Future<void> _connectRealtime() async {
    _realtime = ReverbMonitorClient(
      examId: widget.examId,
      onUpdate: (agg) {
        // Update agregat seketika dari event, lalu segarkan daftar peserta.
        if (_snap != null && mounted) {
          setState(() {
            _snap = MonitorSnapshot(
              (agg['total'] ?? _snap!.total) as int,
              (agg['working'] ?? _snap!.working) as int,
              (agg['finished'] ?? _snap!.finished) as int,
              (agg['expired'] ?? _snap!.expired) as int,
              _snap!.participants,
            );
          });
        }
        _fetch();
      },
      onState: (s) {
        if (mounted) setState(() => _connState = s);
      },
    );
    try {
      await _realtime!.connect();
    } catch (_) {
      if (mounted) setState(() => _connState = 'polling');
    }
  }

  Future<void> _fetch() async {
    try {
      final s = await _service.snapshot(widget.examId);
      if (mounted) setState(() { _snap = s; _error = null; });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  bool get _isLive => _connState.toLowerCase() == 'connected';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examTitle ?? 'Live Monitoring'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                visualDensity: VisualDensity.compact,
                avatar: Icon(
                  _isLive ? Icons.wifi : Icons.wifi_off,
                  size: 16,
                  color: _isLive ? Colors.green : Colors.grey,
                ),
                label: Text(_isLive ? 'Realtime' : 'Polling'),
              ),
            ),
          ),
        ],
      ),
      body: _snap == null
          ? Center(child: _error != null ? Text(_error!) : const CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _stat('Peserta', _snap!.total, Colors.blue),
                      _stat('Mengerjakan', _snap!.working, Colors.orange),
                      _stat('Selesai', _snap!.finished, Colors.green),
                      _stat('Kedaluwarsa', _snap!.expired, Colors.red),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _snap!.participants.isEmpty
                      ? const Center(child: Text('Belum ada peserta.'))
                      : ListView.separated(
                          itemCount: _snap!.participants.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final p = _snap!.participants[i];
                            return ListTile(
                              leading: Icon(
                                _statusIcon(p.status),
                                color: _statusColor(p.status, p.isStale),
                              ),
                              title: Text('Peserta ${p.userId.length > 8 ? p.userId.substring(0, 8) : p.userId}'),
                              subtitle: Text('${p.answered}/${p.total} terjawab'
                                  '${p.current != null ? " • soal ${p.current}" : ""}'
                                  '${p.isStale ? " • ⚠ tidak aktif" : ""}'),
                              trailing: Text(p.status),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _stat(String label, int value, Color color) => Column(
        children: [
          Text('$value', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      );

  IconData _statusIcon(String s) => switch (s) {
        'finished' => Icons.check_circle,
        'expired' => Icons.timer_off,
        _ => Icons.edit,
      };

  Color _statusColor(String s, bool stale) {
    if (stale) return Colors.grey;
    return switch (s) {
      'finished' => Colors.green,
      'expired' => Colors.red,
      _ => Colors.orange,
    };
  }
}
