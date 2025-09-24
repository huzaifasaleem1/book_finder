import '../services/open_library_api.dart';
import '../models/book_work.dart';

class BookRepository {
  final OpenLibraryApi api;
  BookRepository(this.api);

  Future<List<BookWork>> search(String query, {int page = 1, int limit = 20}) async {
    final res = await api.search(query, page: page, limit: limit);
    final docs = (res['docs'] as List?) ?? [];
    return docs.map((e) => BookWork.fromJson(e)).toList();
  }
}
