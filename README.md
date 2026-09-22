# news_app

Aplikasi berita Flutter berbasis NewsAPI. Repositori ini sedang dalam proses
pengerasan dari prototipe tutorial menjadi fondasi yang dapat dirawat.

- Audit dan temuan: [`docs/AUDIT.md`](docs/AUDIT.md)
- Arsitektur yang berlaku: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)

Stack: Flutter + Riverpod (state & DI) + go_router (navigasi) + `package:http`
+ Drift (cache lokal). Struktur feature-first; lihat dokumen arsitektur untuk
aliran dependensi dan kebijakan cache.

## Prasyarat

- Flutter 3.44.x (stable) / Dart 3.12.x
- Untuk Android: Android SDK + JDK 17
- Untuk iOS/macOS: Xcode

```bash
flutter pub get
```

Kode Drift sudah di-commit, jadi clone bersih tidak perlu menjalankan codegen.
Jalankan ini hanya setelah mengubah tabel di `lib/core/persistence/`:

```bash
flutter pub run build_runner build
```

## Menjalankan aplikasi

Aplikasi memilih sumber datanya satu kali saat startup, lewat konfigurasi
compile-time. Tidak ada file `.env` yang dibaca dan tidak ada rahasia yang
dibundel sebagai asset Flutter.

| `--dart-define` | Nilai | Default | Keterangan |
|---|---|---|---|
| `NEWS_DATA_SOURCE` | `mock` \| `live` | `mock` | Memilih sumber data |
| `NEWS_API_KEY` | string | *(kosong)* | Wajib hanya jika `NEWS_DATA_SOURCE=live` |

### Mode mock — default, tanpa API key

Clone bersih langsung dapat dijalankan. Tidak memerlukan kunci dan tidak
menghabiskan kuota NewsAPI:

```bash
flutter run
```

Setara dengan bentuk eksplisitnya:

```bash
flutter run --dart-define=NEWS_DATA_SOURCE=mock
```

### Mode live — NewsAPI sungguhan

Butuh kunci dari <https://newsapi.org>:

```bash
flutter run --dart-define=NEWS_DATA_SOURCE=live --dart-define=NEWS_API_KEY=your_key_here
```

Jika `NEWS_DATA_SOURCE=live` dijalankan tanpa `NEWS_API_KEY`, aplikasi menampilkan
layar "Configuration error" berisi perintah perbaikannya — bukan crash saat
startup, dan bukan HTTP 401 yang menyamar sebagai kegagalan jaringan.

### Menyimpan flag agar tidak perlu diketik ulang

Salin templatnya, isi kunci Anda, lalu jalankan dengan file itu:

```bash
cp dart_defines.example.json dart_defines.local.json
```

Ganti `GANTI_DENGAN_KUNCI_ANDA` di file tersebut dengan kunci NewsAPI Anda,
kemudian:

```bash
flutter run --dart-define-from-file=dart_defines.local.json
```

`dart_defines.local.json` sudah ada di `.gitignore`, jadi kunci Anda nol
kemungkinan ikut ter-commit. Isi file itu tidak pernah dibaca oleh proses
pengembangan ini.

### Batasan plan NewsAPI yang memengaruhi perilaku aplikasi

| Batas | Perilaku aplikasi |
|---|---|
| 100 hasil per query (plan Developer) | Paginasi berhenti di hasil ke-100 meskipun `totalResults` melaporkan ribuan. Melanjutkan akan dijawab HTTP 426. Diatur lewat `maxResultWindow` pada `NewsRepositoryImpl` — naikkan jika plan Anda mengizinkan |
| Kuota harian | Cache TTL 15 menit menahan permintaan berulang. `429` di-retry dengan backoff, lalu muncul sebagai "Terlalu banyak permintaan" |
| Diblokir di produksi | Mode mock ada untuk pengembangan dan demo; proxy backend adalah jalan untuk produksi |
| CORS di browser | Web praktis memerlukan mode mock atau proxy |

### Ketahanan permintaan

Satu deadline 15 detik per percobaan. `429`, `5xx`, dan kegagalan transport
di-retry paling banyak tiga percobaan dengan backoff eksponensial, menghormati
`Retry-After` bila layanan mengirimnya dan meng-clamp-nya di 8 detik. Kunci
yang ditolak, batas plan, dan permintaan cacat **tidak** di-retry — mengulangi
itu hanya membakar kuota dan menunda error yang perlu dilihat pembaca.

Pada build debug ada jejak permintaan yang mencatat path dan **nama** parameter
saja, bukan nilainya dan bukan header — jadi kunci nol kemungkinan masuk ke
baris log. Senyap di release.

## Keamanan API key — baca ini

`--dart-define` menjaga kunci agar tidak ikut ter-commit ke Git. **Itu tidak
membuat kunci menjadi rahasia di perangkat.** Nilainya tertanam sebagai string
biasa di dalam binary hasil kompilasi dan dapat dibaca kembali dari APK, IPA,
atau bundle web mana pun yang didistribusikan.

Satu-satunya perlindungan sungguhan adalah backend proxy yang memegang kunci di
sisi server dan dipanggil oleh aplikasi sebagai pengganti newsapi.org. Proxy itu
berada di luar cakupan pekerjaan saat ini dan tercatat sebagai item backlog.

Batasan lain yang perlu diketahui: plan Developer NewsAPI membatasi kuota harian
dan memblokir request dari aplikasi produksi. Mode mock ada justru supaya
pengembangan dan demo sehari-hari tidak menghabiskan kuota tersebut.

## Cache lokal

Headline di-cache di SQLite per `country:category` dan per halaman, dengan TTL
15 menit. Saat offline, halaman tersimpan tetap ditampilkan dan ditandai basi.
Hasil pencarian **tidak** di-cache — alasannya ada di
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

Pull-to-refresh mengabaikan TTL dan meminta ulang halaman pertama.

## Test

```bash
flutter test
```

Test tidak pernah menyentuh jaringan: sumber live diuji lewat `MockClient` dari
`package:http/testing.dart`, database memakai SQLite in-memory, dan perilaku TTL
diuji dengan `Clock` yang dimajukan manual — nol delay nyata.

## Pemeriksaan kualitas

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Catatan platform

- **Android** — memerlukan manifest launcher yang valid; sudah diperbaiki. Blok
  `<queries>` untuk `android.intent.action.VIEW`/https dibutuhkan agar
  `url_launcher` dapat membuka artikel pada Android 11+.
- **macOS** — memerlukan entitlement `com.apple.security.network.client` pada
  build debug maupun release; tanpa itu seluruh request dan pemuatan gambar
  gagal di bawah App Sandbox.
- **Web** — NewsAPI memblokir request browser lintas-origin pada plan gratis.
  Gunakan mode mock di web, atau sediakan proxy.
