import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import 'api_config.dart';
import 'token_storage.dart';

/// Klien WebSocket Reverb (protokol Pusher) untuk live monitoring realtime.
///
/// Berlangganan channel privat `private-exam.{id}.monitor` dan mendengarkan
/// event `monitor.updated` (di-broadcast backend saat peserta mulai/selesai/
/// kedaluwarsa). Auth channel memakai token Sanctum via /api/v1/broadcasting/auth.
class ReverbMonitorClient {
  final String examId;
  final void Function(Map<String, dynamic> aggregate) onUpdate;
  final void Function(String state)? onState;

  final _pusher = PusherChannelsFlutter.getInstance();
  final _tokenStorage = TokenStorage();
  bool _connected = false;

  ReverbMonitorClient({required this.examId, required this.onUpdate, this.onState});

  String get _channel => 'private-exam.$examId.monitor';

  Future<void> connect() async {
    final token = await _tokenStorage.read();

    // Catatan: pusher_channels_flutter 2.4.0 belum mengekspos host/port kustom,
    // sehingga koneksi ke Reverb self-hosted bersifat best-effort. Bila gagal,
    // MonitorScreen otomatis memakai polling snapshot (fallback).
    await _pusher.init(
      apiKey: ApiConfig.reverbKey,
      cluster: ApiConfig.reverbCluster,
      useTLS: ApiConfig.reverbUseTLS,
      onConnectionStateChange: (currentState, previousState) {
        onState?.call(currentState);
      },
      onError: (message, code, error) {
        onState?.call('error');
      },
      onEvent: _onEvent,
      onAuthorizer: (channelName, socketId, options) async {
        // Reverb private-channel auth: balas { "auth": "key:signature" }.
        final res = await Dio().post(
          ApiConfig.broadcastingAuthUrl,
          data: {'socket_id': socketId, 'channel_name': channelName},
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          ),
        );
        return Map<String, dynamic>.from(res.data as Map);
      },
    );

    await _pusher.connect();
    await _pusher.subscribe(channelName: _channel);
    _connected = true;
  }

  void _onEvent(PusherEvent event) {
    if (event.eventName != 'monitor.updated') return;
    try {
      final data = event.data is String ? jsonDecode(event.data) : event.data;
      final map = Map<String, dynamic>.from(data ?? {});
      final agg = Map<String, dynamic>.from(map['aggregate'] ?? {});
      onUpdate(agg);
    } catch (_) {
      // payload tak terduga → abaikan
    }
  }

  Future<void> disconnect() async {
    if (!_connected) return;
    try {
      await _pusher.unsubscribe(channelName: _channel);
    } catch (_) {}
    try {
      await _pusher.disconnect();
    } catch (_) {}
    _connected = false;
  }
}
