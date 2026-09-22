# ARCHITECTURE — news_app

Status: berlaku sejak implementasi desain Newsline tahap 1–4.
Pendamping: [`AUDIT.md`](AUDIT.md) memuat temuan yang memotivasi setiap keputusan
di sini.

---

## 1. Keputusan yang dipakai

| Bidang | Pilihan | Alasan ringkas |
|---|---|---|
| State management | **Riverpod 3** (`flutter_riverpod`) | DI aman tipe, scoping `autoDispose` otomatis, provider dapat di-override dalam test |
| Navigasi | **go_router 17** | Rute bertipe, deep link, argumen rute dapat diperiksa tanpa cast |
| Model | **Tulis tangan** + `sealed class` Dart 3 | Hanya ~4 DTO; sealed class native sudah cukup untuk failure dan state union |
| HTTP | **`package:http`** + `Client` yang diinjeksi | Timeout eksplisit, `MockClient` untuk test, nol dependensi baru |
| Persistence | **Drift** (SQLite) | Query bertipe, migrasi first-class, dedup lewat primary key URL |
| Settings skalar | **`shared_preferences`** | Toggle tidak perlu migrasi skema |
| Waktu | **`clock`** | `Clock` yang diinjeksi membuat TTL dapat diuji tanpa delay nyata |
| Codegen | `build_runner` + `drift_dev` | Satu-satunya konsumen codegen adalah Drift |
| Tipografi | Playfair Display + DM Sans, dibundel | Nol ketergantungan jaringan; OFL 1.1 di-commit bersamanya |
| Lokalisasi | `flutter_localizations` + gen-l10n | Indonesia default, Inggris tersedia |
| Token desain | `ThemeExtension` (`NewslineTokens`) | Peran yang tidak dimodelkan `ColorScheme` |

Dependensi yang dihapus: `get` (GetX), `flutter_dotenv`.
Dependensi yang ditambah: `flutter_riverpod`, `go_router`, `drift`, `sqlite3`,
`path_provider`, `path`, `shared_preferences`, `clock`; dev: `drift_dev`,
`build_runner`, `fake_async`.

Catatan: `sqlite3_flutter_libs` **tidak** dipakai — paket itu sudah EOL
("Not used anymore, update to version 3.x of package:sqlite3 instead") dan
`sqlite3` 3.x mengirimkan native library-nya sendiri lewat build hook.

---

## 2. Struktur direktori

```text
lib/
  main.dart                     # hanya: bootstrap lalu runApp
  app/
    app.dart                    # NewsApp + ConfigurationErrorApp
    bootstrap.dart              # satu-satunya tempat inisialisasi
    di/providers.dart           # graf dependensi + preferensi
    routing/                    # GoRouter, StatefulShellRoute, path
    widgets/home_shell.dart     # bottom navigation
  core/
    config/                     # String.fromEnvironment + validasi
    errors/failure.dart         # hierarki Failure bertipe
    persistence/                # AppDatabase (Drift), koneksi, SettingsStore
    theme/                      # AppPalette, NewslineTokens, tipografi, tema
    utils/                      # waktu relatif dan absolut
    widgets/                    # StatusView, OfflineBanner, dialog konfirmasi
  l10n/                         # app_en.arb, app_id.arb + hasil gen-l10n
  features/
    news/                       # data + domain + presentation (Home)
    search/                     # Discover: debounce, recent, sort
    article_detail/             # layar baca, ukuran teks, aksi artikel
    bookmarks/                  # simpanan + koleksi
    history/                    # riwayat baca
    settings/                   # preferensi
assets/
  fonts/                        # Playfair Display, DM Sans + OFL
  fixtures/                     # top_headlines.json, search.json (mode mock)
test/
  support/                      # fake, database in-memory, harness pumpApp
  core/, features/              # mengikuti struktur lib/
```

`search` belum memiliki `data/` atau `domain/` sendiri karena ia memakai
`NewsRepository` milik fitur news. Direktori kosong sengaja tidak dibuat;
struktur yang belum dibutuhkan didokumentasikan di §7, bukan di-scaffold.

---

## 3. Aliran dependensi

```
                    ┌──────────────────┐
                    │ appConfigProvider│  (di-override oleh bootstrap)
                    └────────┬─────────┘
                             │
           ┌─────────────────┴──────────────────┐
           ▼                                    ▼
  ┌──────────────────┐            ┌──────────────────────────────┐
  │ httpClientProvider│──────────►│ newsRemoteDataSourceProvider │
  └──────────────────┘            │  mock  → MockNewsDataSource  │
                                  │  live  → NewsApiDataSource   │
                                  └───────────────┬──────────────┘
                                                  ▼
                                      ┌───────────────────────┐
                                      │ newsRepositoryProvider│
                                      │   NewsRepositoryImpl  │
                                      └───────────┬───────────┘
                          ┌───────────────────────┴───────────────────────┐
                          ▼                                               ▼
        ┌──────────────────────────────────┐        ┌──────────────────────────────┐
        │ newsFeedControllerProvider       │        │ searchControllerProvider     │
        │  .autoDispose.family(NewsCategory)│        │  .autoDispose.family(String) │
        └──────────────┬───────────────────┘        └───────────────┬──────────────┘
                       ▼                                            ▼
                  NewsFeedPage                              SearchResultsPage
```

Aturan yang ditegakkan:

- Ketergantungan hanya mengarah ke dalam: `presentation → domain ← data`.
- `domain/` tidak mengimpor Flutter, `http`, persistence, maupun DTO. Diverifikasi
  dengan membaca daftar impor di setiap file `domain/`.
- Tidak ada kelas yang meng-instansiasi kolaboratornya sendiri; semuanya lewat
  konstruktor atau provider.

---

## 4. Bootstrap dan konfigurasi

`main()` tidak melakukan apa pun selain memanggil `bootstrap()` lalu `runApp`.

`bootstrap()` mengembalikan `sealed BootstrapResult`:

- `BootstrapSuccess(overrides)` — konfigurasi valid; `overrides` menjadi benih
  `ProviderScope` root.
- `BootstrapFailure(error)` — konfigurasi tidak terpakai; `ConfigurationErrorApp`
  ditampilkan dengan pesan dan perintah perbaikannya.

`bootstrap()` membuka database Drift dan `SharedPreferences` sebelum frame
pertama. Itulah alasan ia asinkron, dan itulah satu-satunya tempat kedua sumber
daya tersebut dikonstruksi.

Sumber data dipilih **satu kali** di `newsRemoteDataSourceProvider`, dari
`AppConfig.dataSourceMode`. Tidak ada kode lain yang boleh memilih sumber data.

---

## 5. Pemodelan state

`NewsFeedState` adalah sealed union, bukan kumpulan boolean:

| Kondisi | Representasi |
|---|---|
| loading | `NewsFeedLoading` |
| error (tanpa data) | `NewsFeedError(failure)` |
| data | `NewsFeedReady` dengan `articles` tidak kosong |
| empty | `NewsFeedReady` dengan `articles` kosong |
| refreshing | `NewsFeedReady(activity: refreshing)` |
| paginating | `NewsFeedReady(activity: loadingMore)` |
| offline / basi | `NewsFeedReady(origin: staleCache)` |
| halaman gagal, data tetap tampil | `NewsFeedReady(pageFailure: ...)` |

`FeedActivity` adalah enum, sehingga "refreshing" dan "loadingMore" tidak mungkin
benar bersamaan. `NewsFeedError` berarti tidak ada apa pun untuk ditampilkan;
kegagalan yang terjadi saat data sudah ada masuk ke `pageFailure` dan daftar tetap
di layar.

`SearchState` adalah union terpisah dengan bentuk serupa. Pemisahan ini bersifat
struktural: `NewsFeedController` dan `SearchResultsController` tidak berbagi state
apa pun, sehingga refresh di satu sisi tidak mungkin menimpa sisi lain.

Setiap `state = ...` setelah `await` didahului `if (!ref.mounted) return;`.
Tanpa itu, controller `autoDispose` yang sudah dibuang akan menulis ke provider
mati dan melempar.

---

## 6. Routing

| Route | Path | Argumen |
|---|---|---|
| feed | `/` | — |
| search | `/search?q=<query>` | query string |
| article | `/article?url=<canonical>` | query string + `extra` opsional |

Halaman artikel menerima `Article` lewat `extra` sebagai jalur cepat, dan URL
kanonik lewat query parameter sebagai kontrak. Builder **memeriksa**, tidak
meng-cast:

```dart
final Object? extra = state.extra;
final Article? article = extra is Article ? extra : null;
```

`extra` kosong setelah deep link, hot restart, atau reload browser. Dalam kondisi
itu halaman menampilkan status "Article not loaded" dengan aksi buka di browser,
bukan melempar `TypeError`. Part 4 mengganti cabang itu dengan pencarian di cache
berdasarkan URL.

---

## 7. Persistence dan kebijakan cache

### Skema (schemaVersion 1)

| Tabel | Isi | Dipakai sekarang |
|---|---|---|
| `cached_articles` | satu baris per artikel, PK = URL kanonik | ya |
| `feed_entries` | keanggotaan berurutan artikel pada satu halaman feed | ya |
| `feed_page_metadata` | `fetchedAt`, `totalResults`, `hasMore` per halaman | ya |
| `bookmarks` | groundwork, belum ada UI | tidak |
| `reading_history_entries` | groundwork, belum ada UI | tidak |
| `recent_searches` | groundwork, belum ada UI | tidak |

Tiga tabel terakhir sengaja dibuat sekarang supaya fitur bookmark, riwayat, dan
pencarian terakhir dapat ditambahkan tanpa migrasi skema. Nol kode menulis ke
sana.

`cached_articles` ber-PK URL kanonik, sehingga deduplikasi menjadi jaminan
penyimpanan, bukan konvensi.

### Cache key

`headlines:<country>:<category>`, satu entri per halaman. Kategori dan negara
adalah identitas feed; halaman adalah unit TTL.

### Kebijakan

| Perilaku | Aturan |
|---|---|
| TTL | 15 menit (`kFeedCacheTtl`). Halaman yang lebih muda disajikan dari storage, **nol request** |
| Refresh | `forceRefresh: true` mengabaikan TTL, menghapus seluruh halaman feed itu, lalu meminta halaman 1 |
| Offline | Hanya `NoConnectionFailure` dan `TimeoutFailure` jatuh ke cache basi, dilaporkan `DataOrigin.staleCache`. Nol cache + offline = failure dilempar |
| Kegagalan lain | `401`, `429`, body rusak — **tidak** disembunyikan di balik data lama |
| Dedup antar halaman | Halaman N membuang URL kanonik yang sudah tersimpan di halaman 1..N-1 feed yang sama |
| `hasMore` | Diturunkan dari `totalResults` mentah, bukan dari daftar hasil filter, agar pembuangan record rusak tidak menghentikan paginasi lebih awal |
| Clear | `NewsRepository.clearCache()` mengosongkan feed; artikel yang di-bookmark dipertahankan |

**Search tidak di-cache.** Cache pencarian tumbuh tanpa batas melintasi query
yang berbeda, dan hasil pencarian basi lebih menyesatkan daripada headline basi
karena user baru saja menyatakan niat yang segar.

### Kegagalan storage

Baca yang gagal diperlakukan sebagai "tidak ada cache"; tulis bersifat
best-effort. Masalah penyimpanan tidak boleh mengubah request jaringan yang
berhasil menjadi error. Satu-satunya `CacheFailure` yang sampai ke pemanggil
berasal dari `clearCache()`.

### Kanonikalisasi URL

`ArticleMapper.canonicalizeUrl` menurunkan scheme dan host ke huruf kecil,
membuang fragment, membuang parameter pelacak (`utm_*`, `fbclid`, `gclid`,
`mc_cid`, `mc_eid`), dan memotong trailing slash. Nilai non-http(s) ditolak.
Hasilnya adalah kunci identitas untuk entitas, dedup, dan lookup cache.

### Filter di lapisan mapping

Record dibuang bila: tombstone `"[Removed]"` NewsAPI (judul/konten, atau host
`removed.com`), tidak ada URL, tidak ada judul. `publishedAt` diparsing dengan
`tryParse`; timestamp rusak menjadi `null`, bukan exception.

---

## 8. Yang belum ada

Perilaku yang sengaja belum ada:

- Pembatalan request saat kategori berganti cepat. Discover sudah memakai
  penolakan hasil basi berbasis generasi; feed kategori belum.
- Penghapusan cache berbasis usia atau ukuran. Hanya `clearCache()` manual dari
  Settings.
- Notifikasi. Desain referensi menampilkan tombol bel dan preferensi
  notifikasi; nol layanan notifikasi dipasang, jadi bel hanya menyatakan bahwa
  fiturnya belum ada dan toggle-nya tidak dibuat.
- Akun, login, OTP, komentar, dan penerbitan oleh penulis. Ada di contact
  sheet, tetapi di luar cakupan yang disepakati.
- Nomor versi di layar About. Menduplikasi `pubspec.yaml` secara manual akan
  menjadi basi; `package_info_plus` belum sepadan untuk satu baris teks.

Verifikasi yang belum dilakukan:

- **Screenshot perangkat light dan dark belum pernah diambil.** Nol klaim atas
  kesetiaan piksel hasil render. Verifikasi visual yang ada baru widget test
  dan pembacaan prototipe.
- Peluncuran Android nyata masih terblokir lisensi NDK pada mesin lokal.
- iOS, web, Windows, Linux: nol build dijalankan.
- Mode `live` terhadap NewsAPI: nol request nyata dilakukan.

---

## 9. Kontrak untuk pekerjaan berikutnya

Yang boleh diandalkan oleh Part 4 dan prompt desain:

**Repository** — `NewsRepository`

```dart
Future<ArticleFeed> getTopHeadlines({
  required NewsCategory category,
  int page,            // 1-based
  bool forceRefresh,   // abaikan TTL, buang halaman lama, minta halaman 1
});

Future<ArticleFeed> searchArticles({required String query, int page});

Future<Article?> findCachedArticle(String url);  // null bila belum pernah di-cache
Future<void> clearCache();                       // lempar CacheFailure
```

Setiap metode selesai dengan hasilnya, atau melempar `Failure` bertipe. Nol
exception transport bocor, nol DTO muncul.

`ArticleFeed` membawa `articles`, `page`, `hasMore`, `totalResults`, `origin`
(`network` / `cache` / `staleCache`), dan `fetchedAt`.

**Entitas** — `Article` menjamin `url`, `title`, dan `source` non-null.
`description`, `imageUrl`, `publishedAt`, dan `content` opsional. Identitas dan
`==` berbasis `url` kanonik.

**Failure** — sealed, 10 varian: `ConfigurationFailure`, `NoConnectionFailure`,
`TimeoutFailure`, `UnauthorizedFailure`, `RateLimitedFailure`,
`UpgradeRequiredFailure`, `ServerFailure`, `MalformedResponseFailure`,
`CacheFailure`, `UnknownFailure`. Copy UI dipetakan di
`core/widgets/status_views.dart` lewat `describeFailure`, bukan di lapisan data.

**State** — `NewsFeedState`, `SearchState` (sealed, immutable, `copyWith` pada
varian `Ready`).

**Controller** — `newsFeedControllerProvider(NewsCategory)` dan
`searchControllerProvider(String)`, keduanya `autoDispose.family`, dengan metode
`refresh()`, `loadMore()`, dan `retry()`.

**Routing** — path dan nama di `AppRoutes`; `AppRoutes.search(query)` dan
`AppRoutes.article(url)` membangun lokasi yang benar.

**Inisialisasi** — `bootstrap()` adalah titik masuk tunggal. Dependensi baru
didaftarkan di `lib/app/di/providers.dart`, bukan di dalam widget atau
controller.

**Repository lain**

```dart
// BookmarkRepository
Stream<Set<String>> watchSavedUrls();
Stream<List<SavedArticle>> watchSaved({String? collectionName});
Stream<List<String>> watchCollections();
Future<void> save(Article article, {String? collectionName});
Future<void> remove(String url);
Future<void> assignToCollection(String url, String? collectionName);
Future<bool> createCollection(String name);   // false bila kosong atau duplikat
Future<void> deleteCollection(String name);   // artikelnya tetap tersimpan

// ReadingHistoryRepository
Stream<List<Article>> watchRecent();
Future<void> record(Article article);
Future<void> clear();                          // bookmark tidak terpengaruh

// RecentSearchRepository
Stream<List<String>> watchRecent();            // maksimal 6
Future<void> record(String query);
Future<void> remove(String query);
Future<void> clear();
```

**Preferensi** — `themeModeProvider`, `appLocaleProvider`,
`selectedCountryProvider`, `selectedCategoryProvider`, dan
`readingTextScaleProvider`. Semuanya dipersist lewat `SettingsStore`, dan
semuanya jatuh ke default bila nilai tersimpan tidak dikenal.

**Token desain** — `NewslineTokens.of(context)` untuk warna di luar
`ColorScheme`; `Spacing`, `Radii`, dan `Dimens` untuk jarak, radius, dan ukuran
komponen. Nol widget boleh menuliskan nilai hex atau angka jarak sendiri.
