class Exam {
  final String id;
  final String nomorSesi;
  final String namaSesi;
  final String? keterangan;
  final int durasiMenit;
  final DateTime? tanggalMulai;
  final DateTime? tanggalBerakhir;
  final String urutanSoal; // 'urut' | 'acak'
  final bool isPublished;
  final String? mode; // 'tryout' | 'onsite'
  final bool isPremium;
  final bool requiresToken;
  final int? maxAttempt;
  final List<KomposisiItem> komposisi;

  Exam({
    required this.id,
    required this.nomorSesi,
    required this.namaSesi,
    this.keterangan,
    required this.durasiMenit,
    this.tanggalMulai,
    this.tanggalBerakhir,
    required this.urutanSoal,
    required this.isPublished,
    this.mode,
    this.isPremium = false,
    this.requiresToken = false,
    this.maxAttempt,
    this.komposisi = const [],
  });

  bool get isOnsite => mode == 'onsite';

  factory Exam.fromJson(Map<String, dynamic> j) => Exam(
        id: j['id'].toString(),
        nomorSesi: j['nomor_sesi'] ?? '',
        namaSesi: j['nama_sesi'] ?? '',
        keterangan: j['keterangan'],
        durasiMenit: (j['durasi_menit'] ?? 0) as int,
        tanggalMulai: j['tanggal_mulai'] != null ? DateTime.tryParse(j['tanggal_mulai']) : null,
        tanggalBerakhir: j['tanggal_berakhir'] != null ? DateTime.tryParse(j['tanggal_berakhir']) : null,
        urutanSoal: j['urutan_soal'] ?? 'urut',
        isPublished: j['is_published'] == true,
        mode: j['mode'] as String?,
        isPremium: j['is_premium'] == true,
        requiresToken: j['requires_token'] == true,
        maxAttempt: j['max_attempt'] as int?,
        komposisi: (j['komposisi'] as List?)
                ?.map((e) => KomposisiItem.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            const [],
      );

  int get totalSoal => komposisi.fold(0, (a, b) => a + b.jumlahSoal);
}

class KomposisiItem {
  final int tipeSoalId;
  final String? tipe;
  final int jumlahSoal;
  final int? passingGrade;

  KomposisiItem({
    required this.tipeSoalId,
    this.tipe,
    required this.jumlahSoal,
    this.passingGrade,
  });

  factory KomposisiItem.fromJson(Map<String, dynamic> j) => KomposisiItem(
        tipeSoalId: (j['tipe_soal_id'] ?? 0) as int,
        tipe: j['tipe'],
        jumlahSoal: (j['jumlah_soal'] ?? 0) as int,
        passingGrade: j['passing_grade'] as int?,
      );
}
