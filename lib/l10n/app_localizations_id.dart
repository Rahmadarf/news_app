// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Newsline';

  @override
  String get homeTab => 'Home';

  @override
  String get discoverTab => 'Discover';

  @override
  String get bookmarkTab => 'Bookmark';

  @override
  String get settingsTab => 'Settings';

  @override
  String get greetingMorning => 'Selamat pagi,';

  @override
  String get greetingAfternoon => 'Selamat siang,';

  @override
  String get greetingEvening => 'Selamat malam,';

  @override
  String get greetingReader => 'Pembaca';

  @override
  String get notificationsLabel => 'Notifikasi';

  @override
  String get searchLabel => 'Cari berita';

  @override
  String get trendingTodayTitle => 'Trending today';

  @override
  String get recentStoriesTitle => 'Recent stories';

  @override
  String get seeAllAction => 'Lihat semua';

  @override
  String get loadMoreAction => 'Muat berita lainnya';

  @override
  String get homeFooterTagline => 'Sebuah perspektif baru, setiap hari.';

  @override
  String get categoryAll => 'Semua';

  @override
  String get categoryGeneral => 'Umum';

  @override
  String get categoryTechnology => 'Teknologi';

  @override
  String get categoryBusiness => 'Bisnis';

  @override
  String get categorySports => 'Olahraga';

  @override
  String get categoryHealth => 'Kesehatan';

  @override
  String get categoryScience => 'Sains';

  @override
  String get categoryEntertainment => 'Hiburan';

  @override
  String get saveArticle => 'Simpan artikel';

  @override
  String get removeFromSaved => 'Hapus dari simpanan';

  @override
  String get articleSaved => 'Artikel disimpan';

  @override
  String get articleUnsaved => 'Artikel dihapus dari simpanan';

  @override
  String readArticleLabel(String title) {
    return 'Baca $title';
  }

  @override
  String get offlineBanner => 'Anda offline · menampilkan berita tersimpan';

  @override
  String lastUpdatedLabel(String time) {
    return 'Diperbarui $time';
  }

  @override
  String get retryAction => 'Coba lagi';

  @override
  String get exploreAction => 'Jelajahi berita';

  @override
  String get emptyFeedTitle => 'Belum ada cerita di sini';

  @override
  String get emptyFeedBody =>
      'Coba topik lain untuk menemukan perspektif baru.';

  @override
  String get errorNoConnectionTitle => 'Anda sedang offline';

  @override
  String get errorNoConnectionBody => 'Periksa koneksi Anda lalu coba lagi.';

  @override
  String get errorTimeoutTitle => 'Permintaan terlalu lama';

  @override
  String get errorTimeoutBody => 'Layanan tidak merespons tepat waktu.';

  @override
  String get errorUnauthorizedTitle => 'Akses ditolak';

  @override
  String get errorUnauthorizedBody =>
      'Layanan berita menolak kredensial aplikasi ini.';

  @override
  String get errorRateLimitedTitle => 'Terlalu banyak permintaan';

  @override
  String get errorRateLimitedBody =>
      'Layanan berita sedang membatasi kami. Coba lagi nanti.';

  @override
  String get errorUpgradeRequiredTitle => 'Tidak tersedia pada paket ini';

  @override
  String get errorUpgradeRequiredBody =>
      'Layanan berita tidak mengizinkan permintaan ini.';

  @override
  String get errorServerTitle => 'Layanan tidak tersedia';

  @override
  String get errorServerBody =>
      'Layanan berita sedang bermasalah. Coba lagi nanti.';

  @override
  String get errorMalformedTitle => 'Respons tidak terduga';

  @override
  String get errorMalformedBody =>
      'Layanan berita mengirim data yang tidak dapat kami baca.';

  @override
  String get errorCacheTitle => 'Masalah penyimpanan';

  @override
  String get errorCacheBody => 'Berita tersimpan tidak dapat dibaca.';

  @override
  String get errorConfigurationTitle => 'Aplikasi belum dikonfigurasi';

  @override
  String get errorConfigurationBody =>
      'Build ini belum memiliki konfigurasi berita.';

  @override
  String get errorUnknownTitle => 'Terjadi kesalahan';

  @override
  String get errorUnknownBody => 'Silakan coba lagi.';

  @override
  String get loadingStories => 'Memuat berita';

  @override
  String get sampleDataNotice =>
      'Konten editorial contoh untuk peninjauan desain.';

  @override
  String get comingSoonTitle => 'Belum dibuat';

  @override
  String get comingSoonBody => 'Layar ini hadir pada tahap desain berikutnya.';

  @override
  String get unknownSource => 'Sumber tidak diketahui';
}
