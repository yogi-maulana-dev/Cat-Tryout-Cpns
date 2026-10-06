# Fix: `ApiException(409): Attempt belum selesai.`

## Penyebab
Saat menekan **Mulai Tryout**, frontend memanggil `POST /exams/{id}/start`.
Kontrak frontend menyebut endpoint ini **"mulai / lanjutkan attempt"** — artinya
bila peserta masih punya attempt yang belum selesai, server seharusnya
**mengembalikan attempt itu (melanjutkan)**, bukan menolak.

Backend saat ini melempar **HTTP 409 "Attempt belum selesai."** sehingga peserta
buntu: tidak bisa mulai baru, dan attempt lama tidak dilanjutkan.

## Perbaikan Frontend (sudah diterapkan di repo ini)
Pada 409 ketika start, aplikasi kini:
1. Membaca id attempt dari payload error (bila backend mengirimkannya), lalu
   langsung membuka layar pengerjaan untuk **melanjutkan**.
2. Jika tidak ada, mencari attempt berstatus `ongoing` untuk sesi tsb dari
   `GET /me/history` dan melanjutkannya.
3. Jika tetap tidak ketemu, menampilkan dialog arahan "Tryout Belum Selesai"
   dengan tombol ke Riwayat.

File: `lib/core/api_exception.dart`, `lib/core/api_client.dart`,
`lib/screens/exam_detail_screen.dart`.

## Perbaikan Backend (DISARANKAN — terapkan di `Try Out Bayog Backend`)
Jadikan endpoint `start` **idempoten**: lanjutkan attempt berjalan alih‑alih 409.
Contoh pola di controller `start` (sesuaikan nama model/kolom dengan proyekmu):

```php
public function start(Request $request, ExamSession $exam)
{
    $user = $request->user();

    // 1) Jika ada attempt yang masih berjalan → LANJUTKAN (jangan 409).
    $ongoing = ExamAttempt::where('user_id', $user->id)
        ->where('exam_session_id', $exam->id)
        ->where('status', 'ongoing')
        ->latest('started_at')
        ->first();

    if ($ongoing) {
        // Bila waktunya sudah habis, tutup otomatis lalu lanjut ke aturan kuota.
        if ($ongoing->expires_at && now()->greaterThan($ongoing->expires_at)) {
            $ongoing->update(['status' => 'expired', 'finished_at' => $ongoing->expires_at]);
            // (opsional) jalankan scoring di sini.
        } else {
            // Masih berjalan → kembalikan attempt yang sama (resume), HTTP 200.
            return $this->ok(new AttemptResource($ongoing));
        }
    }

    // 2) Tidak ada attempt berjalan → cek kuota (paket gratis Bronze = 1x, dst).
    $used = ExamAttempt::where('user_id', $user->id)
        ->where('exam_session_id', $exam->id)
        ->whereIn('status', ['finished', 'expired'])
        ->count();

    $quota = $this->tryoutQuotaFor($user); // dari paket aktif; null = tak terbatas
    if ($quota !== null && $used >= $quota) {
        // Frontend menangani code ini untuk menawarkan upgrade membership.
        return response()->json([
            'success' => false,
            'message' => 'Kesempatan tryout gratismu sudah habis. Jadi member untuk lanjut.',
            'code'    => 'quota_exceeded', // atau 'attempt_limit' / 'need_member'
        ], 403);
    }

    // 3) Buat attempt baru.
    $attempt = ExamAttempt::create([
        'user_id'         => $user->id,
        'exam_session_id' => $exam->id,
        'attempt_number'  => $used + 1,
        'status'          => 'ongoing',
        'started_at'      => now(),
        'expires_at'      => now()->addMinutes($exam->durasi_menit),
    ]);

    return $this->ok(new AttemptResource($attempt));
}
```

Jika kamu ingin tetap menolak dengan 409 (bukan resume), minimal **sertakan id
attempt** di payload agar frontend bisa melanjutkan:

```php
return response()->json([
    'success' => false,
    'message' => 'Attempt belum selesai.',
    'code'    => 'attempt_ongoing',
    'data'    => ['attempt_id' => $ongoing->id],
], 409);
```

## Catatan soal "gratis 1x → jadi member"
Aturan kuota ada di **backend** (langkah 2 di atas). Kembalikan `code`
`quota_exceeded` / `attempt_limit` / `need_member` saat kuota habis; frontend
sudah otomatis menampilkan ajakan menjadi member.
