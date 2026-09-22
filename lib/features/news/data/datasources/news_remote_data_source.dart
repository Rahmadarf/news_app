import 'package:news_app/features/news/data/dto/news_response_dto.dart';

/// Contract implemented by both the live NewsAPI source and the local mock.
///
/// Data sources return DTOs. Mapping to domain entities and translating
/// technical exceptions into `Failure`s is the repository's job.
abstract interface class NewsRemoteDataSource {
  Future<NewsResponseDto> fetchTopHeadlines({
    required String country,
    required String category,
    required int page,
    required int pageSize,
  });

  Future<NewsResponseDto> searchEverything({
    required String query,
    required int page,
    required int pageSize,
    String? sortBy,
  });
}
