# AUDIT — news_app

Tanggal audit: 2026-09-21
Commit yang diaudit: `4fb2023` (`feat: implement news app with get package architecture`)
Toolchain: Flutter 3.44.8 (stable) • Dart 3.12.2

Dokumen ini adalah hasil Part 1 (audit & definisi target). Tidak ada kode runtime yang
diubah untuk menghasilkan dokumen ini.

**Konvensi pelabelan:**

- **[FAKTA]** — teramati langsung dari file/baris atau dari output perintah yang dijalankan.
- **[INFERENSI]** — kesimpulan logis dari fakta + perilaku API pihak ketiga yang diverifikasi
  pada source package, tetapi belum dieksekusi runtime-nya.
- **[REKOMENDASI]** — usulan, bukan temuan.

---

## 1. Alur aplikasi & arsitektur saat ini

### 1.1 Alur startup

```
main()                                   lib/main.dart:8
  └─ WidgetsFlutterBinding.ensureInitialized()          :9
  └─ await dotenv.load(fileName: '.env')                :12      ← titik gagal (§3.1)
  └─ runApp(MyApp())                                    :14
       └─ GetMaterialApp                                :22
            ├─ initialBinding: AppBindings()            :42
            │     └─ Get.put<NewsController>(permanent: true)   lib/bindings/app_bindings.dart:7
            │           └─ NewsController.onInit() → fetchTopHeadlines()
            │                                          lib/controllers/news_controller.dart:22-26
            ├─ initialRoute: Routes.SPLASH              :40
            └─ getPages: AppPages.routes                :41
```

### 1.2 Peta rute

| Route | Path | Widget | Binding |
|---|---|---|---|
| `SPLASH` | `/splash` | `SplashView` | — |
| `HOME` | `/home` | `HomeView` | `HomeBinding` |
| `NEWS_DETAIL` | `/news-detail` | `NewsDetailView` | — |

Sumber: `lib/routes/app_pages.dart:14-18`, `lib/routes/app_routes.dart:12-17`.

### 1.3 Lapisan

Struktur saat ini adalah *layer-first* klasik gaya tutorial GetX:

```
lib/
  main.dart
  bindings/    app_bindings.dart, home_binding.dart
  controllers/ news_controller.dart
  models/      news_article.dart, news_response.dart
  routes/      app_pages.dart, app_routes.dart
  services/    news_service.dart
  utils/       app_colors.dart, constants.dart
  views/       splash_view.dart, home_view.dart, news_detail_view.dart
  widgets/     news_card.dart, category_chip.dart, loading_shimmer.dart
test/
  widget_test.dart   (template counter test)
```

Aliran dependensi aktual:

```
View ──► NewsController ──► NewsService ──► http.get (global)
  │            │                 │
  │            └── Get.snackbar  └── Constants.apiKey ──► dotenv
  └── Get.arguments (untyped) ──► NewsArticle (DTO nullable, dipakai langsung di UI)
```

**[FAKTA]** Tidak ada lapisan domain. DTO `NewsArticle` (seluruh field nullable,
`lib/models/news_article.dart:2-8`) dikonsumsi langsung oleh widget presentasi
(`lib/widgets/news_card.dart:8`, `lib/views/news_detail_view.dart:12`).

**[FAKTA]** Tidak ada dependency injection pada `NewsController`: `NewsService`
di-instansiasi langsung di dalam field initializer
(`lib/controllers/news_controller.dart:7`). Controller tidak dapat diuji tanpa jaringan.

---

## 2. Inventaris dependensi

Dari `pubspec.yaml:30-54` dan versi terkunci pada `pubspec.lock`.

| Paket | Constraint | Versi terkunci | Dipakai di | Catatan |
|---|---|---|---|---|
| `get` | `^4.7.2` | 4.7.3 | state, DI, routing, snackbar, `capitalize` | Satu paket memegang 4 tanggung jawab. Lihat §8.1 |
| `http` | `^1.4.0` | 1.6.0 | `lib/services/news_service.dart:32,67` | Dipakai lewat fungsi top-level, bukan `Client` yang diinjeksi |
| `url_launcher` | `^6.3.1` | 6.3.2 | `lib/views/news_detail_view.dart:236-237` | Sesuai kebutuhan |
| `share_plus` | `^11.0.0` | 11.1.0 | `lib/views/news_detail_view.dart:214` | API `Share.share` **deprecated** pada v11 |
| `cached_network_image` | `^3.4.1` | 3.4.1 | `news_card.dart:31`, `news_detail_view.dart:24` | Sesuai kebutuhan |
| `timeago` | `^3.7.1` | 3.7.1 | `news_card.dart:79`, `news_detail_view.dart:122` | Locale belum didaftarkan; hanya English |
| `flutter_dotenv` | `^5.2.1` | 5.2.1 | `main.dart:12`, `utils/constants.dart:1,7` | Sumber masalah §3.1; diusulkan dihapus |
| `cupertino_icons` | `^1.0.8` | — | tidak ada referensi di `lib/` | Sisa template |
| `flutter_lints` (dev) | `^6.0.0` | 6.0.0 | `analysis_options.yaml:10` | Set default, tanpa kustomisasi |

**[FAKTA]** `cupertino_icons` tidak direferensikan di mana pun dalam `lib/`
(grep terhadap `CupertinoIcons` tidak menghasilkan hit).

**[FAKTA]** Tidak ada dev-dependency untuk mocking/fake HTTP. `package:http` sendiri
sudah menyediakan `package:http/testing.dart` (`MockClient`), jadi tidak perlu paket baru
untuk memfake transport.

---

## 3. Temuan terverifikasi

### 3.1 CRITICAL

---

#### C-1 — `dotenv.load` mencari asset key yang tidak pernah terdaftar → startup gagal

- **[FAKTA]** `pubspec.yaml:67-68` mendaftarkan asset dengan key `assets/.env`.
- **[FAKTA]** `lib/main.dart:12` memanggil `await dotenv.load(fileName: '.env')`.
- **[FAKTA]** Pada `flutter_dotenv-5.2.1/lib/src/dotenv.dart:166`, pembacaan dilakukan
  lewat `rootBundle.loadString(filename)`; bila gagal, baris `:172` melempar
  `FileNotFoundError`. Pada `load()` (`:116-126`), error tersebut hanya ditelan jika
  parameter `isOptional` bernilai `true`, dan defaultnya `false` (`:120`).
- **[FAKTA]** `main.dart:12` tidak melewatkan `isOptional`.
- **[INFERENSI]** Asset key dalam bundle adalah `assets/.env`, bukan `.env`; maka
  `rootBundle.loadString('.env')` gagal, `FileNotFoundError` naik dari `main()` sebelum
  `runApp()` (`main.dart:14`) sempat dipanggil. Aplikasi tidak pernah menampilkan frame.

> Belum diverifikasi runtime. Verifikasi runtime tertunda karena Android tidak dapat
> diluncurkan (C-2) dan macOS tidak memiliki akses jaringan (H-1). Verifikasi akan
> dilakukan pada Part 2 setelah kedua blocker itu dibereskan.

---

#### C-2 — `AndroidManifest.xml` utama tidak memiliki `MainActivity`, intent-filter launcher, dan metadata Flutter embedding

- **[FAKTA]** `android/app/src/main/AndroidManifest.xml:5-10` berisi elemen
  `<application>` yang seluruh isinya hanyalah komentar
  `<!-- Activity configuration -->`. Tidak ada `<activity>`, tidak ada
  `<intent-filter>` dengan `android.intent.action.MAIN` +
  `android.intent.category.LAUNCHER`, dan tidak ada
  `<meta-data android:name="flutterEmbedding" android:value="2"/>`.
- **[FAKTA]** Kelas `MainActivity` tetap ada dan valid di
  `android/app/src/main/kotlin/com/example/news_app/MainActivity.kt:5`
  (`class MainActivity : FlutterActivity()`), jadi ini murni masalah manifest.
- **[FAKTA]** `android/app/build.gradle.kts:8,19` menetapkan
  `namespace`/`applicationId` = `com.example.news_app`, konsisten dengan package
  `MainActivity.kt:1`.
- **[INFERENSI]** Tanpa activity launcher, APK terpasang tanpa ikon peluncur dan
  `flutter run` tidak dapat menjalankan activity apa pun. Tanpa `flutterEmbedding = 2`,
  engine memilih jalur embedding v1 yang sudah dihapus. Android saat ini tidak dapat
  dijalankan.

> Belum diverifikasi runtime (tidak ada build/launch Android yang dijalankan pada Part 1).

---

#### C-3 — `assets/.env` di-gitignore tetapi tetap dideklarasikan sebagai asset build → clone bersih gagal build

- **[FAKTA]** `.gitignore:47` berisi `assets/.env`, dan
  `git check-ignore -v assets/.env` mengembalikan `.gitignore:47:assets/.env`.
- **[FAKTA]** `git ls-files --error-unmatch assets/.env` mengembalikan
  `error: pathspec 'assets/.env' did not match any file(s) known to git` — file **tidak**
  terlacak Git. (Isi file tidak dibaca, tidak dibuka, dan tidak akan dibuka.)
- **[FAKTA]** `pubspec.yaml:68` tetap mendaftarkan `assets/.env` sebagai asset.
- **[INFERENSI]** Pada clone bersih file tersebut tidak ada, sehingga asset bundling
  Flutter gagal dengan error "no file or variants found for asset". Repositori ini
  tidak dapat di-build oleh developer kedua.

---

#### C-4 — Test suite gagal; masih test counter bawaan template

- **[FAKTA]** `test/widget_test.dart:14-29` adalah test counter default; tidak ada
  hubungan dengan aplikasi ini.
- **[FAKTA]** `flutter test` gagal:
  `Expected: exactly one matching candidate / Actual: _TextWidgetFinder:<Found 0 widgets with text "0": []>`
  pada `test/widget_test.dart:19`. Hasil: `+0 -1`.
- **[INFERENSI]** Tidak ada regression safety net sama sekali sebelum migrasi arsitektur.

---

### 3.2 HIGH

---

#### H-1 — macOS tidak memiliki entitlement `com.apple.security.network.client`

- **[FAKTA]** `macos/Runner/DebugProfile.entitlements:5-10` memuat `app-sandbox`,
  `cs.allow-jit`, dan `network.server` — **tidak** ada `network.client`.
- **[FAKTA]** `macos/Runner/Release.entitlements:5-6` hanya memuat `app-sandbox` —
  tidak ada entitlement jaringan sama sekali.
- **[INFERENSI]** Di bawah App Sandbox, koneksi keluar memerlukan `network.client`.
  Semua request NewsAPI dan semua pemuatan gambar akan gagal pada build macOS,
  debug maupun release.

---

#### H-2 — `AppBindings` dan `HomeBinding` sama-sama mendaftarkan `NewsController`; `HomeBinding` menjadi kode mati

- **[FAKTA]** `lib/bindings/app_bindings.dart:7` —
  `Get.put<NewsController>(NewsController(), permanent: true)`.
- **[FAKTA]** `lib/bindings/home_binding.dart:7` —
  `Get.lazyPut<NewsController>(() => NewsController())`.
- **[FAKTA]** `AppBindings` terpasang sebagai `initialBinding` (`main.dart:42`) sehingga
  berjalan lebih dulu; `HomeBinding` baru berjalan saat route `/home` dibuka
  (`app_pages.dart:16`).
- **[INFERENSI]** GetX mengembalikan instance singleton yang sudah ada saat `Get.find`
  dipanggil, sehingga factory dari `lazyPut` tidak pernah terpakai. `HomeBinding` tidak
  berefek apa pun. Konsekuensi arsitektural: state fitur news dimiliki oleh singleton
  permanen sepanjang umur aplikasi dan tidak pernah dibuang.

---

#### H-3 — Controller permanen memulai request saat splash artifisial masih tampil

- **[FAKTA]** `NewsController.onInit()` memanggil `fetchTopHeadlines()`
  (`lib/controllers/news_controller.dart:22-26`). Karena `AppBindings` adalah
  `initialBinding`, `onInit` berjalan pada t=0.
- **[FAKTA]** `lib/views/splash_view.dart:36-38` menunda navigasi dengan
  `Future.delayed(Duration(seconds: 3), ...)`.
- **[INFERENSI]** Request pertama selesai jauh sebelum user melihat `/home`. Splash
  tidak menunggu inisialisasi apa pun; ia murni delay kosmetik yang menambah 3 detik
  pada waktu startup yang dirasakan.

---

#### H-4 — Kegagalan non-200 dibungkus ganda menjadi "Network error" generik

- **[FAKTA]** `lib/services/news_service.dart:37-39` melempar
  `Exception('Failed to load news: ${response.statusCode}')` **di dalam** blok `try`.
- **[FAKTA]** `lib/services/news_service.dart:40-42` menangkap `catch (e)` dan melempar
  ulang `Exception('Network error: $e')`.
- **[INFERENSI]** Response `401 apiKeyInvalid` berakhir sebagai string
  `Exception: Network error: Exception: Failed to load news: 401`. Pola identik pada
  `searchNews` (`:73-77`). Presentasi tidak dapat membedakan API key salah, kuota habis,
  plan tidak mencukupi, dan koneksi mati.
- **[FAKTA]** String mentah itu ditampilkan apa adanya ke user melalui
  `Get.snackbar('Error', 'Failed to load news: ${e.toString()}')`
  (`lib/controllers/news_controller.dart:40-44` dan `:72-76`).

---

#### H-5 — Body error NewsAPI diabaikan sepenuhnya

- **[FAKTA]** `lib/models/news_response.dart:15-23` hanya membaca `status`,
  `totalResults`, dan `articles`. Field `code` dan `message` yang dikirim NewsAPI pada
  response error tidak pernah diparsing.
- **[FAKTA]** Parsing hanya dilakukan ketika `statusCode == 200`
  (`news_service.dart:34`, `:69`).
- **[INFERENSI]** Kode error spesifik NewsAPI (`apiKeyInvalid`, `rateLimited`,
  `apiKeyExhausted`, `maximumResultsReached`) tidak pernah sampai ke aplikasi.

---

#### H-6 — Feed kategori dan hasil pencarian berbagi satu state ambigu

- **[FAKTA]** `searchNews` menulis ke list yang sama, `_articles.value`
  (`lib/controllers/news_controller.dart:69`), yang juga ditulis oleh
  `fetchTopHeadlines` (`:37`).
- **[FAKTA]** `refreshNews()` (`:50-52`) tanpa syarat memanggil `fetchTopHeadlines()`,
  yang memakai `_selectedCategory.value` (`:34`).
- **[FAKTA]** `RefreshIndicator` pada home terhubung ke `controller.refreshNews`
  (`lib/views/home_view.dart:63`).
- **[INFERENSI]** Pull-to-refresh setelah pencarian membuang hasil pencarian dan
  diam-diam menggantinya dengan feed kategori. Tidak ada field yang menyimpan query
  aktif, sehingga perilaku ini tidak dapat diperbaiki tanpa mengubah bentuk state.

---

#### H-7 — Tidak ada timeout, retry, cancellation, atau HTTP client yang dapat diinjeksi

- **[FAKTA]** `lib/services/news_service.dart:32` dan `:67` memanggil fungsi top-level
  `http.get(uri)`. Tidak ada `.timeout(...)`, tidak ada instance `http.Client`.
- **[FAKTA]** `NewsService` tidak memiliki konstruktor, sehingga tidak ada titik injeksi
  (`news_service.dart:6-9`).
- **[FAKTA]** `NewsController` meng-instansiasi `NewsService()` langsung di field
  (`news_controller.dart:7`).
- **[INFERENSI]** Request dapat menggantung tanpa batas pada jaringan buruk; pergantian
  kategori cepat menimbulkan race (response lama dapat menimpa yang baru karena tidak
  ada pembatalan maupun penjagaan urutan). Tidak ada satu pun bagian dari jalur ini yang
  dapat diuji tanpa jaringan nyata.

---

#### H-8 — `page`/`pageSize` tersedia di service tetapi tidak pernah dipakai; tidak ada paginasi

- **[FAKTA]** `getTopHeadlines` menerima `page` dan `pageSize`
  (`news_service.dart:13-14`), `searchNews` juga (`:47-48`).
- **[FAKTA]** Tidak ada satu pun pemanggil yang melewatkan argumen tersebut
  (`news_controller.dart:33-35`, `:68`).
- **[FAKTA]** `ListView.builder` di `home_view.dart:64-75` tidak memiliki scroll listener
  maupun sentinel untuk memuat halaman berikutnya.
- **[INFERENSI]** Aplikasi terbatas pada 20 artikel pertama per kategori secara permanen.

---

#### H-9 — `DateTime.parse` pada data yang dikontrol API dapat melempar exception di dalam `build()`

- **[FAKTA]** `lib/widgets/news_card.dart:79` —
  `timeago.format(DateTime.parse(article.publishedAt!))`.
- **[FAKTA]** `lib/views/news_detail_view.dart:122` — pola identik.
- **[FAKTA]** `publishedAt` bertipe `String?` dan disalin apa adanya dari JSON
  (`lib/models/news_article.dart:6,26`) tanpa validasi.
- **[INFERENSI]** Timestamp yang tidak sesuai ISO-8601 melempar `FormatException` di
  dalam `build()`, menghasilkan red screen. Tidak ada `tryParse`, tidak ada fallback.

---

#### H-10 — `Get.arguments as NewsArticle` pada field initializer dapat crash

- **[FAKTA]** `lib/views/news_detail_view.dart:12` —
  `final NewsArticle article = Get.arguments as NewsArticle;` dievaluasi saat widget
  dikonstruksi.
- **[FAKTA]** Route `/news-detail` tidak memiliki binding maupun validasi parameter
  (`app_pages.dart:17`).
- **[INFERENSI]** Bila `Get.arguments` bernilai `null` (hot restart pada route detail,
  navigasi langsung, atau deep link di masa depan), cast melempar `TypeError` dan route
  tersebut tidak dapat dirender sama sekali. Ini persis bentuk unchecked route argument
  yang dilarang oleh aturan kerja.

---

#### H-11 — Artefak NewsAPI tidak dinormalisasi

- **[FAKTA]** `NewsArticle.fromJson` (`lib/models/news_article.dart:20-30`) menyalin
  setiap field apa adanya. Tidak ada penyaringan.
- **[INFERENSI]** Akibatnya, hal-hal berikut lolos ke UI:
  - artikel `"[Removed]"` (NewsAPI mengirim `title`, `description`, `url`, dan `content`
    yang seluruhnya bernilai `"[Removed]"`);
  - artikel tanpa `title` atau tanpa `url` — `url` yang null membuat tombol share,
    copy link, dan "Read Full Article" hilang diam-diam
    (`news_detail_view.dart:183`, `:213`, `:222`, `:234`);
  - URL duplikat lintas halaman (belum terlihat sekarang karena paginasi belum ada —
    akan langsung muncul begitu H-8 diperbaiki);
  - `content` yang terpotong dengan sufiks `"… [+1234 chars]"` ditampilkan mentah
    (`news_detail_view.dart:172`).

---

### 3.3 MEDIUM

---

#### M-1 — API key sisi klien dapat diekstraksi, berapa pun mekanisme pemuatannya

- **[FAKTA]** Kunci dibaca dari asset bundle lewat `dotenv.env['API_KEY']`
  (`lib/utils/constants.dart:7`) dan dikirim sebagai query parameter
  (`news_service.dart:18`, `:54`).
- **[FAKTA]** Asset bundle adalah bagian dari artefak aplikasi yang didistribusikan.
- **[INFERENSI]** Siapa pun yang memegang APK/IPA dapat mengekstrak `flutter_assets` dan
  membaca kunci. Detail lebih lanjut pada §4.

---

#### M-2 — Konfigurasi hilang gagal secara senyap, bukan dengan error yang jelas

- **[FAKTA]** `lib/utils/constants.dart:7` — `dotenv.env['API_KEY'] ?? ''`.
- **[INFERENSI]** Jika kunci tidak ada tetapi dotenv berhasil dimuat, aplikasi mengirim
  `apiKey=` kosong, menerima `401`, lalu menampilkan pesan "Network error" generik (H-4).
  Penyebab sebenarnya — konfigurasi belum disetel — tidak pernah dikomunikasikan.

---

#### M-3 — Tidak ada mode mock; pengembangan selalu memakan kuota NewsAPI

- **[FAKTA]** Satu-satunya jalur data adalah `NewsService` yang memanggil NewsAPI
  (`news_service.dart:32`, `:67`). Tidak ada fixture, tidak ada data source alternatif,
  tidak ada saklar.
- **[INFERENSI]** Setiap hot restart selama pengembangan membakar kuota. Ini bertentangan
  langsung dengan kebutuhan produk pada §7.

---

#### M-4 — Tidak ada caching response; tidak ada perilaku offline

- **[FAKTA]** Tidak ada penyimpanan lokal di mana pun di `lib/`. `_articles` hanya ada di
  memori (`news_controller.dart:11`) dan hilang saat proses berakhir.
- **[FAKTA]** `cached_network_image` hanya meng-cache *gambar*, bukan payload JSON.
- **[INFERENSI]** Cold start selalu memerlukan jaringan; offline berarti layar error
  kosong.

---

#### M-5 — Boolean state saling bertabrakan; refresh menghapus daftar

- **[FAKTA]** State terdiri dari tiga primitif independen: `_isLoading`, `_articles`,
  `_error` (`news_controller.dart:10-13`).
- **[FAKTA]** `home_view.dart:49-61` mengevaluasinya berurutan: `isLoading` →
  `LoadingShimmer`, lalu `error` → error widget, lalu `articles.isEmpty` → empty widget.
- **[INFERENSI]** Karena `_isLoading` diperiksa lebih dulu, pull-to-refresh pada daftar
  yang sudah terisi mengganti seluruh daftar dengan shimmer. Kombinasi seperti
  "menampilkan data lama sambil me-refresh", "memuat halaman berikutnya", "offline tetapi
  punya cache basi", dan "kosong karena pencarian tanpa hasil" tidak dapat direpresentasikan.

---

#### M-6 — `TextEditingController` pada dialog pencarian tidak pernah di-dispose

- **[FAKTA]** `lib/views/home_view.dart:140` membuat `TextEditingController` di dalam
  `_showSearchDialog`, dan tidak ada pemanggilan `dispose()` di file tersebut.
- **[INFERENSI]** Kebocoran kecil per pembukaan dialog.

---

#### M-7 — `LoadingShimmer` memiliki `AnimatedBuilder` yang tidak menganimasikan apa pun

- **[FAKTA]** Tiga `AnimatedBuilder` pada `lib/widgets/loading_shimmer.dart:80-92`,
  `:96-122`, dan `:126-152` mendengarkan `_animation`, tetapi subtree yang dibangunnya
  adalah `Container` berwarna solid `AppColors.divider` — nilai `_animation.value` tidak
  pernah dipakai di dalamnya.
- **[FAKTA]** Hanya blok pertama (`:49-72`) yang benar-benar memakai `_animation.value`,
  melalui `GradientRotation` (`:67`).
- **[INFERENSI]** 15 widget di-rebuild pada setiap frame animasi tanpa perubahan visual.

---

#### M-8 — API `Share.share` yang deprecated

- **[FAKTA]** `flutter analyze` melaporkan pada `lib/views/news_detail_view.dart:214`:
  `'Share' is deprecated and shouldn't be used. Use SharePlus instead` dan
  `'share' is deprecated and shouldn't be used. Use SharePlus.instance.share() instead`.
- **[INFERENSI]** Akan menjadi breaking pada share_plus v12.

---

#### M-9 — `Future.delayed` pada splash menavigasi tanpa memeriksa lifecycle

- **[FAKTA]** `lib/views/splash_view.dart:36-38` memanggil `Get.offAllNamed(Routes.HOME)`
  dari dalam callback `Future.delayed`, tanpa pemeriksaan `mounted`.
- **[INFERENSI]** Navigasi tetap dipicu meskipun widget sudah dibuang.

---

### 3.4 LOW

---

- **L-1 [FAKTA]** `dart format --set-exit-if-changed lib test` keluar dengan kode `1`;
  17 dari 18 file berubah. Perbedaan tunggal yang diverifikasi pada sampel
  (`lib/utils/app_colors.dart`) adalah **newline yang hilang di akhir file**
  (`\ No newline at end of file`). Bukan reformat gaya besar-besaran.
- **L-2 [FAKTA]** `flutter analyze` melaporkan **16 issue**, semuanya severity `info`:
  - `constant_identifier_names` ×1 — `app_pages.dart:12`
  - `use_key_in_widget_constructors` ×4 — `home_view.dart:10`, `news_detail_view.dart:11`,
    `splash_view.dart:6`, `loading_shimmer.dart:4`
  - `library_private_types_in_public_api` ×2 — `splash_view.dart:8`,
    `loading_shimmer.dart:6`
  - `deprecated_member_use` ×6 — `withOpacity` pada `news_detail_view.dart:106`,
    `splash_view.dart:70`, `splash_view.dart:97`, `category_chip.dart:25`,
    `loading_shimmer.dart:63`; ditambah `Share`/`share` pada `news_detail_view.dart:214`
  - `use_super_parameters` ×2 — `category_chip.dart:9`, `news_card.dart:11`
- **L-3 [FAKTA]** `README.md:1-17` adalah boilerplate template Flutter
  ("A new Flutter project"). Tidak ada instruksi setup, konfigurasi, maupun menjalankan.
- **L-4 [FAKTA]** `pubspec.yaml:2` — `description: "A new Flutter project."`
- **L-5 [FAKTA]** Metadata platform masih default: `web/index.html:32` `<title>news_app</title>`,
  `web/manifest.json:2-3` `"name"/"short_name": "news_app"`,
  `android/app/src/main/AndroidManifest.xml:6` `android:label="news_app"`.
- **L-6 [FAKTA]** `android/app/build.gradle.kts:19` masih memakai applicationId contoh
  `com.example.news_app` dengan komentar `TODO` pada `:18`.
- **L-7 [FAKTA]** `cupertino_icons` (`pubspec.yaml:36`) tidak dipakai di `lib/`.
- **L-8 [FAKTA]** `analysis_options.yaml:23-25` tidak mengaktifkan satu rule pun;
  seluruh isinya komentar. Tidak ada `language: strict-casts/strict-raw-types`.
- **L-9 [FAKTA]** `timeago` dipakai tanpa parameter `locale`
  (`news_card.dart:79`, `news_detail_view.dart:122`), sehingga selalu English —
  relevan untuk rencana lokalisasi.
- **L-10 [FAKTA]** `Constants.defaultCountry = 'us'` (`lib/utils/constants.dart:25`)
  bersifat hardcoded dan tidak dapat dikonfigurasi dari UI.
- **L-11 [FAKTA]** `Constants.appVersion = '1.0.0'` (`lib/utils/constants.dart:29`)
  menduplikasi `pubspec.yaml:19` secara manual dan akan menjadi basi.
- **L-12 [FAKTA]** `lib/views/home_view.dart:36-42` membungkus setiap chip kategori dalam
  `Obx` terpisah di dalam `itemBuilder`, menghasilkan N langganan reaktif untuk satu
  potong state.

---

## 4. Observasi keamanan & konfigurasi

**[FAKTA]** `assets/.env` ada di disk, tidak dilacak Git, dan di-ignore oleh
`.gitignore:47`. Isinya tidak dibaca dan tidak akan dibaca.

**[FAKTA]** `git log` hanya berisi dua commit (`13a522d`, `4fb2023`). `git ls-files`
tidak memuat `assets/.env` pada tree saat ini. Audit ini **tidak** melakukan pemindaian
riwayat penuh terhadap blob rahasia; lihat §10.

**[FAKTA]** Kunci dikirim sebagai query parameter URL (`news_service.dart:18`, `:54`),
bukan sebagai header `X-Api-Key`. NewsAPI mendukung keduanya.

**[INFERENSI]** Implikasi query parameter: kunci muncul pada log akses proxy,
crash report yang memuat URL, dan output debug jaringan apa pun. Header adalah pilihan
yang lebih aman.

### Batas dari rahasia sisi klien — penting

Aplikasi klien yang memanggil NewsAPI secara langsung **tidak dapat** menyembunyikan
API key-nya. Ini bukan masalah kualitas implementasi, melainkan sifat dari arsitekturnya:

| Mekanisme | Melindungi dari commit ke Git? | Membuat kunci rahasia di perangkat? |
|---|---|---|
| `assets/.env` (saat ini) | Ya, lewat `.gitignore` | **Tidak** — dapat diekstrak dari bundle |
| `--dart-define` / `String.fromEnvironment` | Ya | **Tidak** — tertanam sebagai string dalam binary |
| Backend proxy | Ya | **Ya** — kunci tidak pernah meninggalkan server |

**[REKOMENDASI]** Gunakan `--dart-define` pada Part 2 sebagai perbaikan *higiene
repositori*, dan dokumentasikan secara eksplisit bahwa hal itu **bukan** kontrol keamanan.
Proxy backend adalah perlindungan sesungguhnya dan berada di luar cakupan prompt ini.
Kebutuhan tersebut harus dicatat sebagai item backlog eksplisit, bukan dianggap selesai.

**[FAKTA]** NewsAPI pada plan Developer memblokir request dari aplikasi yang
di-deploy ke produksi dan membatasi kuota harian — batasan ini menguatkan argumen
untuk mode mock (M-3) maupun untuk proxy.

---

## 5. Kesiapan platform

| Platform | Status | Bukti |
|---|---|---|
| **Android** | **Rusak** | Manifest tanpa activity/launcher/embedding — C-2 |
| **iOS** | Kemungkinan OK, belum diverifikasi | Tidak ada masalah jaringan; ATS tidak memblokir HTTPS. Tidak ada build yang dijalankan |
| **macOS** | **Rusak (jaringan)** | `network.client` tidak ada pada kedua entitlement — H-1 |
| **Web** | Kemungkinan OK, belum diverifikasi | Metadata masih default (L-5). CORS NewsAPI di browser adalah risiko terbuka |
| **Windows / Linux** | Belum diverifikasi | Scaffolding default; tidak ada build yang dijalankan |

**[FAKTA]** `INTERNET` permission ada pada ketiga manifest Android
(`main:3`, `debug:6`, `profile:6`).

**[FAKTA]** Blok `<queries>` untuk `PROCESS_TEXT` ada pada `main:13-18`, dibutuhkan oleh
share_plus. Namun **tidak ada** `<queries>` untuk `android.intent.action.VIEW` dengan
scheme `https`, yang dibutuhkan `url_launcher` pada Android 11+ agar `canLaunchUrl`
mengembalikan `true`.

**[INFERENSI]** `news_detail_view.dart:236` — `if (await canLaunchUrl(url))` —
kemungkinan besar mengembalikan `false` pada Android 11+, sehingga "Read Full Article"
dan "Open in Browser" gagal senyap dan hanya menampilkan snackbar
"Could not open the link" (`:239-243`). Ini temuan tambahan di luar daftar hipotesis awal.
Tidak dapat diverifikasi runtime selama C-2 belum dibereskan.

**[FAKTA]** Tidak ada build atau peluncuran platform apa pun yang dijalankan pada Part 1.
Seluruh pernyataan runtime di atas ditandai sebagai belum diverifikasi.

---

## 6. Baseline test & analyzer

| Perintah | Hasil |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | **Exit 1** — 17 dari 18 file berubah; penyebab terverifikasi: newline akhir file hilang |
| `flutter analyze` | **16 issue**, semuanya `info`, 0 error, 0 warning (rincian di L-2) |
| `flutter test` | **GAGAL** — 1 test, `+0 -1`, `test/widget_test.dart:19` |

Cakupan test: nol test yang bermakna. Tidak ada test unit, tidak ada fake, tidak ada fixture.

---

## 7. Kapabilitas yang belum ada dan dibutuhkan produk ke depan

| Kapabilitas | Status saat ini | Yang menghalangi |
|---|---|---|
| Feed kategori | Ada, halaman pertama saja | H-8 |
| Paginasi | Tidak ada | H-8, M-5 (state tak mampu merepresentasikan "memuat halaman berikutnya") |
| Pencarian | Ada, tetapi state-nya bertabrakan dengan feed | H-6 |
| Bookmark | Tidak ada | Tidak ada persistence (M-4), tidak ada entitas domain stabil |
| Riwayat baca | Tidak ada | Sama dengan di atas |
| Data offline | Tidak ada | M-4 |
| Settings | Tidak ada | Tidak ada key-value store, tidak ada scope DI |
| Lokalisasi | Tidak ada | String UI hardcoded di seluruh view; `timeago` tanpa locale (L-9) |
| Pemilihan sumber data (mock/real) | Tidak ada | M-3 |
| Failure bertipe | Tidak ada | H-4, H-5 |
| Testability | Tidak ada | H-7 (tidak ada injeksi), C-4 |
| Deep linking | Tidak ada | H-10 (argumen rute untyped) |

---

## 8. Keputusan arsitektur — perbandingan dan rekomendasi

### 8.1 State management & navigasi: pertahankan GetX vs migrasi

**Konteks:** codebase saat ini berukuran 17 file dan ~1.100 baris. Target state ke depan
mencakup paginasi, pencarian, cache offline, bookmark, riwayat, settings, dan lokalisasi.

| Opsi | Keuntungan | Kerugian | Biaya migrasi |
|---|---|---|---|
| **A. Pertahankan GetX, disiplinkan** | Perubahan nol pada dependensi; tim sudah familiar; routing + DI + snackbar sudah ada | Service locator global berbasis tipe (`Get.find<T>()`) tanpa keamanan compile-time; `Get.arguments` untyped (H-10); scoping controller bergantung konvensi (H-2 membuktikan mudah salah); state reaktif mendorong boolean terpisah, bukan state union (M-5); `Get.snackbar` memungkinkan lapisan data menyentuh UI; komunitas mempertanyakan laju maintenance paket | Rendah |
| **B. Riverpod + go_router** ★ | DI dengan aman tipe dan resolusi compile-time; scoping otomatis lewat `autoDispose`; `AsyncValue` + sealed class memodelkan seluruh kondisi tanpa boolean bertabrakan; provider di-override dalam test (persis kebutuhan sumber data mock); go_router memberi parsing rute bertipe + deep link (memperbaiki H-10 secara struktural); keduanya aktif di-maintain | Konsep baru untuk tim; go_router adalah dependensi tambahan; perlu penulisan ulang ketiga view | Sedang — dan **paling murah sekarang**, karena permukaan kode masih 17 file |
| **C. flutter_bloc + go_router** | Alur event/state paling eksplisit; tooling matang | Boilerplate paling banyak untuk aplikasi seukuran ini; tetap perlu get_it untuk DI | Sedang-tinggi |

**[REKOMENDASI] Opsi B.** Alasannya adalah soal waktu: biaya migrasi berbanding lurus
dengan ukuran codebase, dan codebase ini tidak akan pernah sekecil ini lagi. Empat dari
enam temuan HIGH yang bersifat arsitektural (H-2, H-6, H-7, H-10) adalah kegagalan pada
scoping, injeksi, pemodelan state, dan keamanan tipe rute — tepat pada empat sumbu yang
dipaksa benar oleh Riverpod + go_router secara struktural, dan yang dengan GetX hanya
dapat dijaga lewat konvensi.

> Opsi A tetap dapat dipertahankan. Jika Anda memilih A, H-2/H-6/H-7/H-10 tetap harus
> diperbaiki secara manual dan aturan "controller tidak boleh permanen kecuali X" perlu
> ditegakkan lewat review. Ini adalah keputusan Anda pada Approval Gate 1.

### 8.2 Persistence lokal

Kebutuhan: cache feed (dengan TTL + dedup berdasarkan URL), bookmark, riwayat baca,
pencarian terakhir, settings kecil.

| Opsi | Keuntungan | Kerugian |
|---|---|---|
| **Drift (SQLite)** ★ | Query bertipe, migrasi skema first-class, indeks unik pada URL kanonik menyelesaikan dedup di lapisan penyimpanan, cocok untuk bookmark + riwayat + TTL, semua platform | Membutuhkan `build_runner`; kurva belajar |
| `sqflite` mentah | Tanpa codegen | SQL sebagai string tanpa pengecekan, migrasi manual, butuh `sqflite_common_ffi` untuk desktop |
| `hive_ce` | API paling sederhana, cepat | Query lemah (bukan relasional), tidak cocok untuk riwayat dan dedup |
| `shared_preferences` saja | Trivial | Tidak layak untuk daftar artikel |
| `isar` | Cepat, query bagus | Status maintenance upstream tidak pasti — risiko untuk fondasi jangka panjang |

**[REKOMENDASI]** **Drift** untuk data terstruktur (cache feed, bookmark, riwayat,
pencarian terakhir) + **`shared_preferences`** untuk settings skalar (mode sumber data,
negara, tema, locale). Memisahkan keduanya menghindari migrasi skema untuk setiap
penambahan toggle.

### 8.3 Model: tulis tangan vs code generation

| Opsi | Keuntungan | Kerugian |
|---|---|---|
| **Tulis tangan + sealed class Dart 3** ★ | Dart 3 sudah punya `sealed`/`final` class dan pattern matching exhaustive — persis yang dibutuhkan untuk hierarki failure dan state union; jumlah DTO hanya ~4; nol dependensi baru; parsing defensif (`tryParse`, filter `"[Removed]"`) memang perlu ditulis tangan | `fromJson` manual; `copyWith`/`==` manual |
| `freezed` + `json_serializable` | `copyWith`, equality, union gratis | Menambah 2 dep + langkah codegen; serialisasi yang dihasilkan tetap harus di-override untuk parsing defensif |

**[REKOMENDASI]** **Tulis tangan.** `build_runner` tetap akan hadir untuk Drift, tetapi
menjaga jumlah konsumennya tetap satu akan membuat waktu build tetap pendek. `freezed`
dapat ditambahkan belakangan tanpa perlu merombak; ia tidak mengubah bentuk API publik.

### 8.4 Strategi HTTP client

**[REKOMENDASI]** Pertahankan `package:http`. Tambahkan:

- `http.Client` yang diinjeksi ke konstruktor `NewsApiDataSource` (memperbaiki H-7,
  memungkinkan `MockClient` dari `package:http/testing.dart` tanpa dependensi baru);
- `.timeout(Duration(seconds: 15))` per request dengan `TimeoutFailure` eksplisit;
- kunci dikirim lewat header `X-Api-Key`, bukan query parameter (§4);
- pemetaan terpusat status → failure: `401`→`UnauthorizedFailure`,
  `426`→`UpgradeRequiredFailure`, `429`→`RateLimitedFailure`, `5xx`→`ServerFailure`,
  `SocketException`/`ClientException`→`NoConnectionFailure`;
- pembatalan lewat generasi request (`int` yang bertambah) pada repository, sehingga
  response usang dibuang. Full `CancelToken` membutuhkan Dio; ini belum sepadan.

**Alternatif yang ditolak:** `dio` — menyediakan interceptor, retry, dan `CancelToken`
bawaan, tetapi merupakan dependensi besar untuk dua endpoint. Tinjau ulang jika
autentikasi, refresh token, atau retry berlapis benar-benar dibutuhkan.

**Deteksi offline:** **[REKOMENDASI]** turunkan dari kegagalan request nyata
(`SocketException`), **bukan** dari `connectivity_plus`. `connectivity_plus` melaporkan
status link, bukan keterjangkauan — Wi-Fi tanpa internet akan salah dilaporkan sebagai
online. Tidak ada dependensi baru.

### 8.5 Dependency injection & scoping rute

**[REKOMENDASI]** (dengan asumsi §8.1 Opsi B disetujui)

- `ProviderScope` tunggal di root; seluruh konstruksi objek berada pada
  `lib/app/bootstrap.dart`.
- Database, `http.Client`, konfigurasi, dan repository adalah provider **keep-alive**
  (mahal, bersifat aplikasi).
- State per fitur memakai `autoDispose`, dengan kunci berupa parameter fitur
  (kategori, query) melalui provider berfamili — ini memperbaiki H-2 dan H-6 secara
  struktural: feed kategori dan hasil pencarian menjadi state yang berbeda secara tipe
  dan tidak akan pernah dapat saling menimpa.
- go_router dengan rute bertipe; halaman detail menerima **URL artikel** sebagai parameter
  path, bukan objek — memperbaiki H-10 dan membuat deep link menjadi mungkin. Artikelnya
  diambil dari cache berdasarkan URL tersebut, dengan fallback bila tidak ada.

### 8.6 Usulan perubahan dependensi

**Ditambah:**

| Paket | Justifikasi satu baris | Biaya migrasi |
|---|---|---|
| `flutter_riverpod` | State + DI dengan aman tipe, scoped, dan dapat di-override dalam test | Sedang — penulisan ulang ketiga view |
| `go_router` | Rute bertipe + deep link; menghapus cast `Get.arguments` (H-10) | Rendah — hanya tiga rute |
| `drift` | Cache/bookmark/riwayat relasional dengan query bertipe dan migrasi | Sedang |
| `sqlite3_flutter_libs` | Binary SQLite yang dibutuhkan Drift di perangkat | Rendah |
| `path_provider`, `path` | Menentukan lokasi file database | Rendah |
| `shared_preferences` | Settings skalar tanpa migrasi skema | Rendah |
| `clock` (dev + runtime) | `Clock` yang dapat diinjeksi untuk test TTL deterministik tanpa delay nyata | Rendah |
| `drift_dev`, `build_runner` (dev) | Codegen Drift | Rendah |

**Dihapus:**

| Paket | Alasan |
|---|---|
| `flutter_dotenv` | Digantikan `String.fromEnvironment`; sumber langsung dari C-1 dan C-3 |
| `get` | Hanya jika §8.1 Opsi B disetujui |
| `cupertino_icons` | Tidak direferensikan (L-7) — opsional, sangat murah untuk dipertahankan |

**Sengaja tidak ditambahkan:** `dio`, `connectivity_plus`, `freezed`, `mockito`
(`package:http/testing.dart` + fake tulis tangan sudah cukup), `get_it` (Riverpod sudah
menangani DI).

---

## 9. Usulan migrasi bertahap

Setiap fase adalah satu commit terpisah, dijalankan hanya setelah approval gate-nya.

### Fase 1 — Stabilisasi (Part 2)

Perubahan terkecil untuk mendapatkan baseline yang dapat dipercaya.

1. Perbaiki `AndroidManifest.xml` utama: `<activity>` `MainActivity`, intent-filter
   launcher, `flutterEmbedding` v2, `<queries>` untuk `VIEW`/https.
2. Tambah `com.apple.security.network.client` pada kedua entitlement macOS.
3. Hapus `assets/.env` dari asset `pubspec.yaml`; hapus `flutter_dotenv`; hapus
   `dotenv.load` dari `main.dart`.
4. Ganti dengan `String.fromEnvironment('NEWS_API_KEY')` +
   `String.fromEnvironment('NEWS_DATA_SOURCE', defaultValue: 'mock')`.
5. Hapus delay 3 detik pada splash.
6. Ganti test counter dengan smoke test deterministik tanpa jaringan.
7. Selesaikan 16 issue analyzer + newline akhir file.
8. Tulis ulang `README.md`.

**Risiko:** rendah. Perubahan Android/macOS bersifat aditif dan mengembalikan file ke
bentuk template Flutter standar. **Rollback:** `git revert` pada commit fase.
**Belum terverifikasi setelah fase ini:** peluncuran Android dan iOS nyata, kecuali build
benar-benar dijalankan.

### Fase 2 — Fondasi arsitektur (Part 3)

Struktur feature-first, `bootstrap.dart`, `ProviderScope`, go_router, state immutable.
Migrasi vertikal satu irisan: news feed dulu, lalu detail, lalu search.

**Risiko:** sedang — semua view disentuh. **Mitigasi:** tulis characterization test
sebelum tiap irisan; pertahankan rute lama tetap dapat dijangkau sampai penggantinya
lulus test. **Rollback:** revert per irisan; tiap irisan adalah commit.

### Fase 3 — Fondasi data & domain (Part 4)

Entitas, DTO, mapper, `NewsApiDataSource` + `MockNewsDataSource`, cache Drift,
`NewsRepository`, hierarki failure, dan seluruh test unit pada daftar wajib.

**Risiko:** sedang — permukaan baru paling besar, tetapi seluruhnya di belakang
antarmuka repository yang sudah stabil sejak Fase 2. **Rollback:** repository memiliki
kontrak tunggal; implementasi dapat ditukar kembali.

---

## 10. Asumsi & pertanyaan terbuka

### Asumsi

1. `assets/.env` memuat `API_KEY=<kunci NewsAPI>`. Disimpulkan dari
   `lib/utils/constants.dart:7`, bukan dari membaca file.
2. Plan NewsAPI adalah Developer (kuota terbatas, diblokir di produksi). Belum
   dikonfirmasi oleh Anda.
3. Target platform utama adalah Android dan iOS; macOS/web/desktop bersifat sekunder.
   Belum dinyatakan.
4. Direktori tak terlacak `Claude outputs/` adalah milik Anda dan di luar cakupan.
   Tidak disentuh, tidak dibaca, tidak akan di-stage.
5. Tidak ada backend milik sendiri yang tersedia saat ini, sehingga NewsAPI dipanggil
   langsung dari klien.

### Pertanyaan terbuka — **butuh keputusan Anda pada Approval Gate 1**

1. **Pertahankan GetX, atau migrasi ke Riverpod + go_router?** Ini keputusan tunggal
   paling berdampak pada dokumen ini dan menentukan seluruh bentuk Part 3. Rekomendasi:
   migrasi (§8.1).
2. **Drift disetujui?** Ia membawa `build_runner` ke dalam proyek. Alternatif yang lebih
   ringan adalah `sqflite` mentah dengan biaya keamanan tipe dan migrasi (§8.2).
3. **Apakah `assets/.env` boleh tetap ada di disk Anda?** Rencananya hanya menghapus
   deklarasinya dari `pubspec.yaml`. File di disk **tidak** akan dihapus tanpa izin
   eksplisit Anda.
4. **Apakah riwayat Git perlu dipindai untuk kebocoran rahasia?** Audit ini hanya memeriksa
   tree saat ini. Ada dua commit; pemeriksaan penuh itu murah tetapi bersifat read-only
   dan belum dijalankan karena berada di luar deliverable Part 1.
5. **Negara dan kategori default** — pertahankan `us` (`constants.dart:25`), atau jadikan
   dapat dikonfigurasi sejak Part 4? Ini memengaruhi bentuk cache key.
6. **Apakah dukungan web tetap dalam cakupan?** NewsAPI memblokir request browser
   lintas-origin pada plan gratis, sehingga web praktis memerlukan mode mock atau proxy.

---

## 11. Ringkasan bukti untuk daftar risiko awal

| Hipotesis dalam prompt | Putusan | Bukti |
|---|---|---|
| `pubspec` membundel `assets/.env` sementara `main.dart` memuat `.env` | **Terkonfirmasi** | C-1 |
| Kunci sisi klien dapat diekstraksi | **Terkonfirmasi** | M-1, §4 |
| `AppBindings` dan `HomeBinding` sama-sama mendaftarkan `NewsController` | **Terkonfirmasi** | H-2 |
| Controller permanen memulai request saat splash tampil | **Terkonfirmasi** | H-3 |
| Manifest Android kehilangan MainActivity/launcher/embedding | **Terkonfirmasi** | C-2 |
| Entitlement macOS tidak mengizinkan network client | **Terkonfirmasi** | H-1 |
| Search dan kategori berbagi satu state ambigu | **Terkonfirmasi** | H-6 |
| `page`/`pageSize` tersedia tetapi tidak dipaginasi | **Terkonfirmasi** | H-8 |
| Kegagalan non-200 dibungkus ganda | **Terkonfirmasi** | H-4 |
| Tidak ada timeout, retry, cancellation, client yang dapat diinjeksi | **Terkonfirmasi** | H-7 |
| Artefak NewsAPI tidak dinormalisasi | **Terkonfirmasi** | H-11 |
| `DateTime.parse` dan cast argumen rute dapat crash | **Terkonfirmasi** | H-9, H-10 |
| Splash delay tidak melakukan inisialisasi apa pun | **Terkonfirmasi** | H-3 |
| Ada API deprecated dan style lint | **Terkonfirmasi** | L-2 (16 issue, 6 di antaranya deprecated) |
| Widget test masih counter test bawaan | **Terkonfirmasi** | C-4 |
| README dan metadata platform masih default template | **Terkonfirmasi** | L-3, L-4, L-5 |

**Temuan tambahan di luar daftar hipotesis:** C-3 (clone bersih tidak dapat di-build),
H-5 (body error NewsAPI diabaikan), M-6 (kebocoran `TextEditingController`),
M-7 (`AnimatedBuilder` yang tidak menganimasikan apa pun), M-9 (navigasi splash tanpa
pemeriksaan lifecycle), dan `<queries>` `url_launcher` yang hilang pada Android 11+ (§5).
