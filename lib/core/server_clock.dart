/// Jam tersinkron dengan server.
///
/// Countdown promo WAJIB mengacu waktu server, bukan jam perangkat yang bisa
/// dimundurkan. [ServerClock] menyimpan waktu server pada saat respons diterima
/// beserta waktu perangkat saat itu, lalu memproyeksikan "now" versi server
/// dengan menambahkan selisih waktu perangkat yang telah berlalu.
///
/// Konsekuensinya:
///  - Memundurkan jam perangkat tidak memperpanjang promo (acuan tetap server).
///  - Setiap refresh/fetch ulang akan menyinkronkan ulang dari waktu server,
///    sehingga sisa waktu selalu dihitung dari batas yang tersimpan di server.
class ServerClock {
  final DateTime _serverAnchor; // UTC
  final DateTime _deviceAnchor; // UTC

  ServerClock(DateTime serverTime, {DateTime? deviceTime})
      : _serverAnchor = serverTime.toUtc(),
        _deviceAnchor = (deviceTime ?? DateTime.now()).toUtc();

  /// Fallback bila server tidak mengirim waktu: pakai jam perangkat.
  factory ServerClock.fromDevice() => ServerClock(DateTime.now().toUtc());

  /// Perkiraan "now" menurut server (UTC).
  DateTime now() =>
      _serverAnchor.add(DateTime.now().toUtc().difference(_deviceAnchor));

  /// Selisih (server - device) saat sinkron; berguna untuk diagnostik.
  Duration get skew => _serverAnchor.difference(_deviceAnchor);
}
