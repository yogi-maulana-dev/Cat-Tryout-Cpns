# Paket Berlangganan & Promo Platinum — BisaPNS.id

Dokumen ini menjelaskan fitur paket try out (Bronze / Gold / Platinum) dan promo
Platinum yang diimplementasikan pada aplikasi **Flutter** ini, serta **kontrak API
backend Laravel** yang diperlukan agar fitur bekerja end‑to‑end.

> Repo ini adalah **frontend Flutter** yang mengonsumsi REST API Laravel
> (`/api/v1`). Perubahan database, panel admin, dan validasi harga **wajib
> diimplementasikan di backend** sesuai kontrak di bawah. Frontend sudah siap
> menampilkan promo begitu backend mengirim field yang diminta.

---

## 1. Paket

| Paket     | Harga            | Try out | Fitur utama |
|-----------|------------------|---------|-------------|
| Bronze    | Gratis           | 1x      | TWK/TIU/TKP, timer, skor, pembahasan dasar |
| Gold      | Rp10.000         | 10x     | Pembahasan, analisis nilai, riwayat, leaderboard |
| Platinum  | Rp30.000 (promo Rp15.000) | 30x | Pembahasan lengkap, analisis kelemahan, grafik perkembangan, leaderboard |

Nilai default ada di `lib/core/promo_config.dart` (`kPackageCatalog`). Ini
dipakai landing page dan sebagai acuan; **harga tagihan tetap dari server**.

## 2. Promo Platinum

- Periode: **6 Oktober 2026 00:00 WIB** s/d **6 November 2026 23:59 WIB** (inklusif).
- Zona waktu **Asia/Jakarta (UTC+7, tanpa DST)** — lihat `lib/core/wib.dart`.
- Diskon 50%: Rp30.000 → Rp15.000.
- UI menampilkan: harga normal dicoret, harga promo, badge `PROMO 50%`, dan
  countdown hari/jam/menit/detik.
- **Countdown memakai waktu server** (`ServerClock`, lihat §4), bukan timer yang
  bisa direset dengan refresh.
- Setelah promo berakhir: harga otomatis kembali Rp30.000, badge & countdown
  hilang, dan harga checkout divalidasi server.
- Status promo: **belum mulai / berlangsung / berakhir** (`PromoState`).

Logika promo murni-Dart & teruji: `lib/core/promo.dart`,
`lib/models/package.dart`. Uji batas waktu: `test/core/promo_test.dart`.

## 3. Kontrak API Backend (WAJIB diimplementasikan di Laravel)

### 3.1 `GET /api/v1/packages`

Kembalikan **server_time** + daftar paket. Dua bentuk didukung frontend; gunakan
bentuk baru (dengan `server_time`) agar countdown akurat:

```jsonc
// Envelope: { "success": true, "data": <di bawah> }
{
  "server_time": "2026-10-06T09:00:00Z",   // ISO‑8601, UTC (atau +07:00)
  "packages": [
    {
      "id": 3,
      "name": "Platinum",
      "slug": "platinum",
      "description": "Persiapan paling lengkap",
      "normal_price": 30000,                // harga normal (Rupiah)
      "promo_price": 15000,                 // null jika tak ada promo
      "promo_enabled": true,                // admin bisa matikan promo
      "discount_percent": 50,               // opsional; dihitung bila null
      "promo_starts_at": "2026-10-05T17:00:00Z", // 6 Okt 00:00 WIB
      "promo_ends_at":   "2026-11-06T16:59:59Z", // 6 Nov 23:59 WIB
      "tryout_quota": 30,                   // null = tak terbatas
      "duration_days": 60,                  // masa aktif
      "features": ["30x try out", "..."],
      "is_popular": false
    }
    // ... Bronze (normal_price 0), Gold (10000)
  ]
}
```

Field lama `price_monthly` / `price_yearly` masih diterima sebagai fallback.

### 3.2 `POST /api/v1/transactions`

Body dari frontend **hanya**: `{ package_id, period, payment_method_id }`.
**Tidak pernah** mengirim harga.

Backend wajib:
1. Ambil harga dari **DB**, bukan dari request.
2. Tentukan promo aktif memakai **waktu server** vs `promo_starts_at/ends_at`
   (zona Asia/Jakarta), hormati `promo_enabled`.
3. Hitung `amount` final = harga promo bila aktif, selain itu harga normal.
4. **Snapshot** harga ke pesanan (`amount`, `normal_price`, `promo_applied`,
   `price_locked_at`) agar invoice & riwayat konsisten dengan kebijakan saat order.
5. Tangani konkurensi (transaction DB / lock) & kegagalan pembayaran (status
   `pending → waiting_verification → paid/rejected/expired`).

Respons mengembalikan transaksi dengan `amount` otoritatif — frontend
menampilkan nilai ini (lihat `checkout_screen.dart`, layar "Pembayaran").

### 3.3 Kuota try out & paket gratis

- Bronze gratis = **1x** attempt. Saat kuota habis / butuh member, backend
  mengembalikan error envelope dengan `code` salah satu:
  `need_member` | `quota_exceeded` | `attempt_limit`.
- Frontend menangkap ini (`ApiException.needsUpgrade`) dan menampilkan ajakan
  menjadi member (`exam_detail_screen._showUpgradePrompt`, serta CTA di
  `result_screen`).

### 3.4 Panel Admin (backend)

Sediakan pengaturan untuk:
- Mengaktifkan/menonaktifkan promo (`promo_enabled`).
- Mengubah `normal_price`, `promo_price`, `promo_starts_at`, `promo_ends_at`.
- Mengatur `tryout_quota` & `duration_days` tiap paket.

### 3.5 Saran Migration (Laravel)

Tambah kolom pada tabel `packages`:

```php
$table->string('slug')->nullable()->index();
$table->unsignedBigInteger('normal_price')->default(0);
$table->unsignedBigInteger('promo_price')->nullable();
$table->boolean('promo_enabled')->default(true);
$table->unsignedTinyInteger('discount_percent')->nullable();
$table->timestamp('promo_starts_at')->nullable();
$table->timestamp('promo_ends_at')->nullable();
$table->unsignedInteger('tryout_quota')->nullable(); // null = unlimited
$table->unsignedInteger('duration_days')->default(30);
```

Pada tabel `transactions` (snapshot harga per pesanan):

```php
$table->unsignedBigInteger('normal_price')->nullable();
$table->boolean('promo_applied')->default(false);
$table->timestamp('price_locked_at')->nullable();
```

Simpan `promo_ends_at` di DB/konfigurasi (bukan hardcode) agar admin dapat
mengubah tanpa deploy. Gunakan `Config::set('app.timezone', 'Asia/Jakarta')`
atau Carbon dengan zona eksplisit saat membandingkan waktu promo.

## 4. Waktu server untuk countdown (frontend)

`lib/core/server_clock.dart` menyimpan waktu server saat respons diterima +
waktu perangkat saat itu, lalu memproyeksikan "now" server. Akibatnya:
- Memundurkan jam perangkat **tidak** memperpanjang promo.
- Refresh/fetch ulang menyinkronkan ulang dari waktu server.

Landing page (publik) memakai jam perangkat sebagai fallback; alur berbayar
(login) memakai `server_time` dari `GET /packages`.

## 5. Berkas Frontend Terkait

- `lib/core/money.dart` — format Rupiah terpusat.
- `lib/core/wib.dart` — util zona waktu WIB.
- `lib/core/promo.dart` — `PromoWindow`, `PromoState`, countdown, diskon.
- `lib/core/promo_config.dart` — katalog default 3 paket + jendela promo.
- `lib/core/server_clock.dart` — jam tersinkron server.
- `lib/core/ui/promo_countdown.dart` — widget countdown.
- `lib/models/package.dart` — model paket + logika harga promo.
- `lib/services/commerce_service.dart` — parsing katalog + server_time.
- `lib/screens/packages_screen.dart` — 3 kartu paket + promo.
- `lib/screens/checkout_screen.dart` — ringkasan promo, harga server-otoritatif.
- `lib/features/landing/.../pricing_section.dart` — section harga landing.
- `lib/screens/result_screen.dart` — CTA jadi member setelah tryout.
- Uji: `test/core/promo_test.dart`, `test/core/promo_countdown_test.dart`,
  `test/features/landing/landing_page_test.dart`.
