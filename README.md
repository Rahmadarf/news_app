# news_app

Aplikasi berita Flutter berbasis NewsAPI. Repositori ini sedang dalam proses
pengerasan dari prototipe tutorial menjadi fondasi yang dapat dirawat.

- Audit dan temuan: [`docs/AUDIT.md`](docs/AUDIT.md)
- Arsitektur yang berlaku: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)

Stack: Flutter + Riverpod (state & DI) + go_router (navigasi) + `package:http`.
Struktur feature-first; lihat dokumen arsitektur untuk aliran dependensinya.

## Prasyarat

- Flutter 3.44.x (stable) / Dart 3.12.x
- Untuk Android: Android SDK + JDK 17
- Untuk iOS/macOS: Xcode

```bash
flutter pub get
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

Simpan di konfigurasi launch IDE Anda, atau gunakan file define yang tidak
di-commit:

```bash
flutter run --dart-define-from-file=dart_defines.local.json
```

Tambahkan `dart_defines.local.json` ke `.gitignore` Anda jika memakai cara ini.

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

## Test

```bash
flutter test
```

Test tidak pernah menyentuh jaringan. Mode mock adalah default, sehingga
`flutter test` berjalan tanpa konfigurasi apa pun.

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
