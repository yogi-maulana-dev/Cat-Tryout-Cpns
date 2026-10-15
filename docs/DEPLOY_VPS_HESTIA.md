# Deploy ke VPS Ubuntu + HestiaCP

Proyek ini punya **2 bagian** yang dideploy terpisah:

| Bagian | Isi | Hasil di VPS |
|---|---|---|
| **Backend** | Laravel (Try Out Bayog) | Aplikasi PHP + MySQL di subdomain `api.domain.com` |
| **Frontend** | Flutter (repo ini) | Web statis hasil `flutter build web` di `app.domain.com` (atau domain utama) |

Contoh domain yang dipakai di panduan ini:
- `api.bisapns.id` → backend Laravel (API + WebSocket)
- `app.bisapns.id` → frontend Flutter web

> Arahkan **A record** kedua domain ke IP VPS lebih dulu (via DNS/registrar atau
> DNS HestiaCP).

---

## 0) Prasyarat
- VPS Ubuntu dengan **HestiaCP** sudah terpasang (nginx + php-fpm + MariaDB/MySQL).
- Akses SSH ke VPS.
- PHP 8.2 tersedia di Hestia (Server Settings → PHP) untuk Laravel.

---

## 1) Backend Laravel di HestiaCP

### 1.1 Buat web domain + database
Di panel Hestia:
1. **WEB → Add Web Domain** → `api.bisapns.id`.
2. **DB → Add Database** → catat `nama_db`, `user`, `password` (host `localhost`).
3. Di web domain `api.bisapns.id` → **Edit** → set **Backend/PHP version = 8.2**.

### 1.2 Upload kode
SSH ke VPS lalu (ganti `useradmin` dengan user Hestia-mu):
```bash
cd /home/useradmin/web/api.bisapns.id
git clone <URL-REPO-BACKEND> laravel
cd laravel
composer install --no-dev --optimize-autoloader
```

### 1.3 Konfigurasi `.env`
```bash
cp .env.example .env
nano .env
```
Isi penting:
```env
APP_NAME="BisaPNS"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.bisapns.id

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=nama_db
DB_USERNAME=user
DB_PASSWORD=password

# Sanctum / CORS — izinkan domain frontend
SANCTUM_STATEFUL_DOMAINS=app.bisapns.id
SESSION_DOMAIN=.bisapns.id
FRONTEND_URL=https://app.bisapns.id

# Reverb (WebSocket) — samakan dengan dart-define frontend
REVERB_APP_ID=...
REVERB_APP_KEY=...
REVERB_APP_SECRET=...
REVERB_HOST=api.bisapns.id
REVERB_PORT=443
REVERB_SCHEME=https
```
Pastikan `config/cors.php` → `allowed_origins` memuat `https://app.bisapns.id`
(atau `FRONTEND_URL`), dan `supports_credentials => true` bila pakai Sanctum cookie.

### 1.4 Migrasi, seed, optimize
```bash
php artisan key:generate
php artisan migrate --force
php artisan db:seed --class=PackageSeeder   # paket Bronze/Gold/Platinum (lihat BACKEND_PAKET_IMPLEMENTASI.md)
php artisan storage:link
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 1.5 Izin folder
```bash
chown -R useradmin:useradmin /home/useradmin/web/api.bisapns.id/laravel
chmod -R 775 storage bootstrap/cache
```

### 1.6 Arahkan document root ke `/public`
HestiaCP menyajikan dari `public_html`. Arahkan ke folder `public` Laravel:
```bash
cd /home/useradmin/web/api.bisapns.id
rm -rf public_html
ln -s laravel/public public_html
```

Lalu tambahkan rewrite Laravel ke nginx. Buat template nginx custom (sekali saja):
`/usr/local/hestia/data/templates/web/nginx/php-fpm/laravel.tpl` dan `laravel.stpl`
(salin dari `default.tpl`/`default.stpl`) lalu ganti blok `location /` menjadi:
```nginx
location / {
    try_files $uri $uri/ /index.php?$query_string;
}
```
Terapkan: web domain `api.bisapns.id` → **Edit → Template = laravel** → Save.
(Alternatif tanpa template custom: gunakan `.htaccess` bawaan Laravel bila domain
memakai Apache.)

### 1.7 HTTPS
Web domain → **Edit** → centang **SSL** + **Let's Encrypt** → Save.

### 1.8 Queue worker + Reverb (opsional, untuk live monitoring)
Buat service systemd (atau pakai Supervisor):
```bash
# /etc/systemd/system/reverb-bisapns.service
[Service]
User=useradmin
WorkingDirectory=/home/useradmin/web/api.bisapns.id/laravel
ExecStart=/usr/bin/php artisan reverb:start --host=127.0.0.1 --port=8080
Restart=always
```
```bash
sudo systemctl enable --now reverb-bisapns
```
Lalu proxy WebSocket di nginx domain `api.bisapns.id` (via template custom) agar
`wss://api.bisapns.id` → `127.0.0.1:8080`:
```nginx
location /app { proxy_pass http://127.0.0.1:8080; proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "Upgrade";
    proxy_set_header Host $host; }
location /apps { proxy_pass http://127.0.0.1:8080; }
```
Jalankan juga queue: `php artisan queue:work` sebagai service serupa.
> Jika belum butuh fitur live monitoring, lewati langkah 1.8.

Cek: buka `https://api.bisapns.id/api/v1/packages` → harus balas JSON paket.

---

## 2) Frontend Flutter web

### 2.1 Build (di komputermu, bukan di VPS)
Arahkan ke API produksi lewat `--dart-define` (lihat `lib/core/api_config.dart`):
```bash
flutter build web --release \
  --dart-define=API_HOST=https://api.bisapns.id \
  --dart-define=REVERB_HOST=api.bisapns.id \
  --dart-define=REVERB_PORT=443 \
  --dart-define=REVERB_TLS=true \
  --dart-define=REVERB_KEY=<REVERB_APP_KEY backend>
```
Hasil ada di folder `build/web/`.

### 2.2 Buat web domain frontend
Hestia → **WEB → Add Web Domain** → `app.bisapns.id` → aktifkan SSL/Let's Encrypt.

### 2.3 Upload isi `build/web/` ke `public_html`
```bash
# dari komputermu
scp -r build/web/* useradmin@IP_VPS:/home/useradmin/web/app.bisapns.id/public_html/
```
(atau pakai File Manager Hestia / rsync / SFTP).

### 2.4 SPA fallback (routing Flutter)
Agar refresh di sub-rute tidak 404, arahkan semua ke `index.html`. Buat template
nginx custom `app.tpl`/`app.stpl` (salin `default`) dengan:
```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```
Terapkan ke web domain `app.bisapns.id`.

Buka `https://app.bisapns.id` → aplikasi tampil dan memanggil `api.bisapns.id`.

---

## 3) Checklist & masalah umum
- **CORS error** → tambahkan `https://app.bisapns.id` ke `config/cors.php`
  (`allowed_origins`) backend, lalu `php artisan config:cache`.
- **Mixed content** → frontend HTTPS harus memanggil API **HTTPS** (bukan http/IP).
  Pastikan `API_HOST=https://...` saat build.
- **419 / CSRF (Sanctum cookie)** → set `SANCTUM_STATEFUL_DOMAINS` & `SESSION_DOMAIN`
  benar; samakan domain induk (`.bisapns.id`).
- **500 di backend** → cek `storage/logs/laravel.log`; biasanya izin folder
  `storage` / `.env` belum diisi / `php artisan key:generate` belum dijalankan.
- **WebSocket gagal (wss)** → pastikan service Reverb jalan + proxy nginx `/app`
  aktif, dan dart-define `REVERB_PORT=443 REVERB_TLS=true`.
- **Halaman paket masih kosong/lama** → jalankan `PackageSeeder` di backend
  (lihat `docs/BACKEND_PAKET_IMPLEMENTASI.md`).

## 4) Update aplikasi nanti
- Backend: `git pull && composer install --no-dev -o && php artisan migrate --force && php artisan config:cache`.
- Frontend: build ulang (`flutter build web ...`) lalu upload ulang isi `build/web/`.
