# Backend: buat `/packages` mengembalikan Bronze / Gold / Platinum + promo

Video "MASIH BUG" menampilkan build LAMA (masih ada toggle Bulanan/Tahunan,
harga Rp29.000, paket Basic/Premium/Bundle). Dua hal yang perlu dilakukan:

1. **Frontend**: jalankan branch `claude/magical-lamport-8em5gz` (lihat bagian
   akhir). Ini menghapus toggle & memakai desain 3 paket + promo.
2. **Backend** (`D:\project\Try Out Bayog Backend`): layar "Paket Tryout"
   mengambil data dari `GET /packages`. Selama backend masih berisi paket lama,
   layar itu menampilkan paket lama. Terapkan migration + seeder + resource di
   bawah agar backend mengirim Bronze/Gold/Platinum + field promo + `server_time`.

Zona waktu: set `config/app.php` → `'timezone' => 'Asia/Jakarta'` (atau pakai
Carbon dengan offset WIB eksplisit).

## 1) Migration — kolom paket & snapshot transaksi

```php
// database/migrations/xxxx_add_promo_to_packages.php
Schema::table('packages', function (Blueprint $t) {
    $t->string('slug')->nullable()->index();
    $t->unsignedBigInteger('normal_price')->default(0);
    $t->unsignedBigInteger('promo_price')->nullable();
    $t->boolean('promo_enabled')->default(true);
    $t->unsignedTinyInteger('discount_percent')->nullable();
    $t->timestamp('promo_starts_at')->nullable();
    $t->timestamp('promo_ends_at')->nullable();
    $t->unsignedInteger('tryout_quota')->nullable(); // null = tak terbatas
    $t->unsignedInteger('duration_days')->default(30);
    $t->json('features')->nullable();
    $t->boolean('is_popular')->default(false);
});

// snapshot harga pada transaksi
Schema::table('transactions', function (Blueprint $t) {
    $t->unsignedBigInteger('normal_price')->nullable();
    $t->boolean('promo_applied')->default(false);
    $t->timestamp('price_locked_at')->nullable();
});
```

## 2) Model `Package` — casts

```php
protected $casts = [
    'features'        => 'array',
    'promo_enabled'   => 'boolean',
    'is_popular'      => 'boolean',
    'promo_starts_at' => 'datetime',
    'promo_ends_at'   => 'datetime',
];

// Harga berlaku menurut waktu server (sumber kebenaran).
public function effectivePrice(): int
{
    return $this->isPromoActive() ? (int) $this->promo_price : (int) $this->normal_price;
}

public function isPromoActive(): bool
{
    if (!$this->promo_enabled || $this->promo_price === null) return false;
    if (!$this->promo_starts_at || !$this->promo_ends_at) return false;
    $now = now();
    return $now->betweenIncluded($this->promo_starts_at, $this->promo_ends_at);
}
```

## 3) Seeder — Bronze / Gold / Platinum

```php
// database/seeders/PackageSeeder.php
use Carbon\Carbon;

$wib = 'Asia/Jakarta';

Package::updateOrCreate(['slug' => 'bronze'], [
    'name' => 'Bronze', 'description' => 'Coba gratis dulu',
    'normal_price' => 0, 'promo_price' => null, 'promo_enabled' => false,
    'tryout_quota' => 1, 'duration_days' => 7, 'is_popular' => false,
    'features' => ['1x try out gratis','Soal TWK, TIU, dan TKP','Timer ujian & skor otomatis','Pembahasan dasar'],
]);

Package::updateOrCreate(['slug' => 'gold'], [
    'name' => 'Gold', 'description' => 'Paling banyak dipilih',
    'normal_price' => 10000, 'promo_price' => null, 'promo_enabled' => false,
    'tryout_quota' => 10, 'duration_days' => 30, 'is_popular' => true,
    'features' => ['10x try out','Pembahasan soal lengkap','Analisis nilai','Riwayat hasil','Leaderboard peserta'],
]);

Package::updateOrCreate(['slug' => 'platinum'], [
    'name' => 'Platinum', 'description' => 'Persiapan paling lengkap',
    'normal_price' => 30000, 'promo_price' => 15000, 'promo_enabled' => true,
    'discount_percent' => 50,
    'promo_starts_at' => Carbon::create(2026, 10, 6, 0, 0, 0, $wib),
    'promo_ends_at'   => Carbon::create(2026, 11, 6, 23, 59, 59, $wib),
    'tryout_quota' => 30, 'duration_days' => 60, 'is_popular' => false,
    'features' => ['30x try out','Pembahasan lengkap + strategi','Analisis kelemahan per kategori','Grafik perkembangan nilai','Leaderboard peserta'],
]);
```

Jalankan: `php artisan migrate && php artisan db:seed --class=PackageSeeder`
(hapus/nonaktifkan dulu seeder paket lama Basic/Premium/Bundle bila ada).

## 4) Controller `index` — kirim `server_time` + paket

```php
public function index()
{
    $packages = Package::orderBy('normal_price')->get();
    return response()->json([
        'success' => true,
        'data' => [
            'server_time' => now()->toIso8601String(), // untuk countdown
            'packages'    => PackageResource::collection($packages),
        ],
    ]);
}
```

## 5) `PackageResource`

```php
public function toArray($request)
{
    return [
        'id'              => $this->id,
        'name'            => $this->name,
        'slug'            => $this->slug,
        'description'     => $this->description,
        'normal_price'    => (int) $this->normal_price,
        'promo_price'     => $this->promo_price !== null ? (int) $this->promo_price : null,
        'promo_enabled'   => (bool) $this->promo_enabled,
        'discount_percent'=> $this->discount_percent,
        'promo_starts_at' => optional($this->promo_starts_at)->toIso8601String(),
        'promo_ends_at'   => optional($this->promo_ends_at)->toIso8601String(),
        'tryout_quota'    => $this->tryout_quota,
        'duration_days'   => (int) $this->duration_days,
        'features'        => $this->features ?? [],
        'is_popular'      => (bool) $this->is_popular,
    ];
}
```

## 6) Buat transaksi — harga dari server (JANGAN percaya browser)

```php
public function store(Request $request)
{
    $data = $request->validate([
        'package_id'        => ['required','exists:packages,id'],
        'payment_method_id' => ['required','exists:payment_methods,id'],
        'period'            => ['nullable','string'],
    ]);

    $package = Package::findOrFail($data['package_id']);
    $amount  = $package->effectivePrice();      // dihitung server
    $promo   = $package->isPromoActive();

    $trx = Transaction::create([
        'user_id'           => $request->user()->id,
        'package_id'        => $package->id,
        'package_name'      => $package->name,
        'amount'            => $amount,          // otoritatif
        'normal_price'      => $package->normal_price,
        'promo_applied'     => $promo,
        'price_locked_at'   => now(),
        'payment_method_id' => $data['payment_method_id'],
        'status'            => 'pending',
        'invoice_no'        => 'INV-'.now()->format('YmdHis').'-'.Str::random(4),
        'expires_at'        => now()->addHours(24),
    ]);

    return response()->json(['success' => true, 'data' => new TransactionResource($trx)]);
}
```

## 7) Jalankan frontend terbaru

```bash
git fetch origin
git checkout claude/magical-lamport-8em5gz
git pull
flutter clean && flutter pub get
flutter run -d chrome    # lalu hard refresh: Ctrl+Shift+R
```

Setelah backend di-seed & frontend branch ini dijalankan: layar Paket akan
menampilkan Bronze/Gold/Platinum, badge PROMO 50%, harga Rp30.000 dicoret →
Rp15.000, dan countdown; checkout memakai harga dari server.
