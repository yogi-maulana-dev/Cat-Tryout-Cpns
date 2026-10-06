class User {
  final String id;
  final String name;
  final String email;
  final String akses;
  final String? nomorHp;
  final String? jenisKelamin;
  final String statusAkun;
  final bool isMember;
  final bool memberAktif;
  final DateTime? memberExpiredAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.akses,
    this.nomorHp,
    this.jenisKelamin,
    required this.statusAkun,
    required this.isMember,
    required this.memberAktif,
    this.memberExpiredAt,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'].toString(),
        name: j['name'] ?? '',
        email: j['email'] ?? '',
        akses: j['akses'] ?? 'peserta',
        nomorHp: j['nomor_hp'],
        jenisKelamin: j['jenis_kelamin'],
        statusAkun: j['status_akun'] ?? 'aktif',
        isMember: j['is_member'] == true,
        memberAktif: j['member_aktif'] == true,
        memberExpiredAt: j['member_expired_at'] != null
            ? DateTime.tryParse(j['member_expired_at'])
            : null,
      );

  bool get isAdmin => akses == 'admin';
}
