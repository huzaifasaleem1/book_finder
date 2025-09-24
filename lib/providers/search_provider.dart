import 'package:flutter/foundation.dart';
import '../models/book_work.dart';
import '../services/open_library_api.dart';

enum SearchState { idle, loading, error, empty, success }

class SearchProvider extends ChangeNotifier {
  final OpenLibraryApi api;

  SearchProvider({required this.api});

  SearchState _state = SearchState.idle;
  SearchState get state => _state;

  List<BookWork> _results = [];
  List<BookWork> get results => _results;

  bool _hasMore = false;
  bool get hasMore => _hasMore;

  String? _error;
  String? get error => _error;

  String _query = "";
  int _page = 1;

  bool get loading => _state == SearchState.loading;

  void setQuery(String value) {
    _query = value;
  }

  Future<void> search({bool reset = true}) async {
    if (_query.isEmpty) {
      _state = SearchState.idle;
      _results = [];
      notifyListeners();
      return;
    }

    if (reset) {
      _page = 1;
      _results = [];
      _hasMore = false;
    }

    _state = SearchState.loading;
    _error = null;
    notifyListeners();

    try {
      final json = await api.search(_query, page: _page, limit: 20);
      final docs = (json['docs'] as List).cast<Map<String, dynamic>>();

      final newResults = docs.map((j) => BookWork.fromJson(j)).toList();

      if (reset && newResults.isEmpty) {
        _state = SearchState.empty;
      } else {
        _results.addAll(newResults);
        _page++;
        _hasMore = newResults.isNotEmpty;
        _state = SearchState.success;
      }
    } catch (e) {
      _error = e.toString();
      _state = SearchState.error;
    }

    notifyListeners();
  }
}
