/// The publication an [Article] came from.
///
/// Pure domain: no Flutter, no HTTP, no persistence, no DTO imports.
class ArticleSource {
  const ArticleSource({required this.name, this.id});

  /// Always present. The mapper substitutes a fallback when the API omits it.
  final String name;

  /// NewsAPI source identifier. Absent for many sources.
  final String? id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleSource && other.name == name && other.id == id;

  @override
  int get hashCode => Object.hash(name, id);

  @override
  String toString() => 'ArticleSource($name)';
}
