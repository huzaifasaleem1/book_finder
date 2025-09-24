class BookWork {
  final String key; // e.g. "/works/OL123W"
  final String title;
  final List<String> authors;
  final int? firstPublishYear;
  final int? coverId;

  BookWork({
    required this.key,
    required this.title,
    required this.authors,
    this.firstPublishYear,
    this.coverId,
  });

  factory BookWork.fromJson(Map<String, dynamic> j) {
    final rawAuthors = j['author_name'];
    final authorList = <String>[];
    if (rawAuthors is List) {
      for (final a in rawAuthors) {
        if (a != null) authorList.add(a.toString());
      }
    }

    return BookWork(
      key: (j['key'] ?? '') as String,
      title: (j['title'] ?? 'Untitled') as String,
      authors: authorList,
      firstPublishYear: j['first_publish_year'] is int
          ? j['first_publish_year'] as int
          : (j['first_publish_year'] is String
          ? int.tryParse(j['first_publish_year'] as String)
          : null),
      coverId: j['cover_i'] is int
          ? j['cover_i'] as int
          : (j['cover_i'] is String
          ? int.tryParse(j['cover_i'] as String)
          : null),
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'title': title,
    'authors': authors,
    'firstPublishYear': firstPublishYear,
    'coverId': coverId,
  };

  String? get authorName =>
      authors.isNotEmpty ? authors.join(', ') : null;

  String? get coverUrl =>
      coverId != null ? 'https://covers.openlibrary.org/b/id/$coverId-L.jpg' : null;

  String? get coverSmall =>
      coverId != null ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg' : null;

  /// "/works/OL123W" -> "OL123W"
  String get workId {
    if (key.startsWith('/works/')) {
      return key.replaceFirst('/works/', '');
    }
    return key;
  }

  @override
  String toString() =>
      'BookWork(key: $key, title: $title, authors: ${authors.join(", ")})';
}
