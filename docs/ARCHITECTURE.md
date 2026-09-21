# ARCHITECTURE — news_app

Status: berlaku sejak Part 3 (fondasi arsitektur).
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
| Persistence | **Drift** (belum dipasang) | Dijadwalkan untuk Part 4; lihat §7 |
| Codegen | Belum ada | `build_runner` baru masuk bersama Drift |

Dependensi yang dihapus: `get` (GetX), `flutter_dotenv`.
Dependensi yang ditambah: `flutter_riverpod`, `go_router`, `fake_async` (dev).

---

## 2. Struktur direktori

```text
lib/
  main.dart                     # hanya: bootstrap lalu runApp
  app/
    app.dart                    # NewsApp + ConfigurationErrorApp
    bootstrap.dart              # satu-satunya tempat inisialisasi
    di/
      providers.dart            # graf dependensi aplikasi
    routing/
      app_router.dart           # GoRouter + pembacaan argumen defensif
      app_routes.dart           # path, nama, builder URL
  core/
    config/app_config.dart      # String.fromEnvironment + validasi
    errors/failure.dart         # hierarki Failure bertipe
    theme/                      # AppColors, AppTheme
    widgets/status_views.dart   # FailureView, EmptyView, describeFailure
  features/
    news/
      data/
        datasources/            # NewsRemoteDataSource + Api + Mock
        dto/                    # ArticleDto, NewsResponseDto
        mappers/                # ArticleMapper
        repositories/           # NewsRepositoryImpl
      domain/
        entities/               # Article, ArticleSource, ArticleFeed, NewsCategory
        repositories/           # NewsRepository (kontrak)
      presentation/
        controllers/            # NewsFeedController
        state/                  # NewsFeedState
        pages/                  # NewsFeedPage
        widgets/                # ArticleCard, ArticleListView, CategorySelector, ArticleListShimmer
    search/
      presentation/             # SearchResultsController, SearchState, SearchResultsPage, SearchDialog
    article_detail/
      presentation/pages/       # ArticleDetailPage
test/
  app_smoke_test.dart
  core/config/
  features/news/data/{datasources,mappers,repositories}/
  features/news/presentation/
  support/                      # fake tulis tangan
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

`bootstrap()` adalah `Future` meskipun saat ini tidak ada `await`, karena Part 4
membuka database Drift di sini.

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

## 7. Yang belum ada, dan di mana tempatnya nanti

Struktur berikut **belum dibuat**. Didokumentasikan agar tidak ada direktori
kosong yang di-scaffold lebih awal:

```text
lib/
  core/
    persistence/          # Drift database, DAO, migrasi          → Part 4
    utils/                # clock yang diinjeksi untuk TTL         → Part 4
  features/
    news/data/
      datasources/news_local_data_source.dart                      → Part 4
      fixtures/                                                    → Part 4
    bookmarks/            # domain + data + presentation           → prompt desain
    history/                                                       → prompt desain
    settings/                                                      → prompt desain
```

Perilaku yang sengaja belum ada pada Part 3:

- Cache lokal, TTL, fallback stale saat offline. `ArticleFeed.origin` selalu
  `DataOrigin.network`; nilai `cache`/`staleCache` sudah dapat direpresentasikan
  oleh state dan sudah punya banner di UI, tetapi belum pernah dihasilkan.
- Filter `"[Removed]"`, kanonikalisasi URL, dan dedup lintas halaman di lapisan
  mapping. Dedup saat ini dilakukan controller saat menggabungkan halaman.
- Fixture JSON yang di-commit untuk mock data source.
- Pembatalan request saat kategori berganti dengan cepat.

---

## 8. Kontrak untuk pekerjaan berikutnya

Yang boleh diandalkan oleh Part 4 dan prompt desain:

**Repository** — `NewsRepository`

```dart
Future<ArticleFeed> getTopHeadlines({
  required NewsCategory category,
  int page,
  bool forceRefresh,
});

Future<ArticleFeed> searchArticles({required String query, int page});
```

Setiap metode selesai dengan `ArticleFeed`, atau melempar `Failure` bertipe.
Tidak ada exception transport yang bocor, tidak ada DTO yang muncul.

**State** — `NewsFeedState`, `SearchState` (sealed, immutable, `copyWith` pada
varian `Ready`).

**Controller** — `newsFeedControllerProvider(NewsCategory)` dan
`searchControllerProvider(String)`, keduanya `autoDispose.family`, dengan metode
`refresh()`, `loadMore()`, dan `retry()`.

**Routing** — path dan nama di `AppRoutes`; `AppRoutes.search(query)` dan
`AppRoutes.article(url)` membangun lokasi yang benar.

**Inisialisasi** — `bootstrap()` adalah titik masuk tunggal. Dependensi baru
didaftarkan di `lib/app/di/providers.dart`, bukan di dalam widget atau controller.
