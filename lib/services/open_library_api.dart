// lib/services/open_library_api.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OpenLibraryApi {
  final http.Client client;
  final String userAgent;
  OpenLibraryApi({http.Client? client, required this.userAgent})
      : client = client ?? http.Client();

  Future<Map<String, dynamic>> _get(String path, [Map<String, String>? params]) async {
    final uri = Uri.https('openlibrary.org', path, params);
    final res = await client.get(uri, headers: {
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.userAgentHeader: userAgent,
    }).timeout(const Duration(seconds: 12));
    if (res.statusCode == 200) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw HttpException('HTTP ${res.statusCode}: ${res.body}');
  }

  /// Search endpoint
  Future<Map<String, dynamic>> search(String q, {int page = 1, int limit = 20}) {
    return _get('/search.json', {
      'q': q,
      'page': page.toString(),
      'limit': limit.toString(),
    });
  }

  /// Get a work by id or key (workId can be "OL123W" or "/works/OL123W")
  Future<Map<String, dynamic>> getWork(String workId) {
    final id = workId.startsWith('/works/') ? workId.replaceFirst('/works/', '') : workId;
    return _get('/works/$id.json');
  }

  /// Editions listing (optional)
  Future<Map<String, dynamic>> getEditions(String workId, {int limit = 20, int offset = 0}) {
    final id = workId.startsWith('/works/') ? workId.replaceFirst('/works/', '') : workId;
    return _get('/works/$id/editions.json', {'limit': limit.toString(), 'offset': offset.toString()});
  }

  /// Return cover url from cover id. size: S, M, L
  String coverUrlFromCoverId(int coverId, {String size = 'M'}) {
    return 'https://covers.openlibrary.org/b/id/$coverId-$size.jpg';
  }

  /// Alias helper (accepts nullable)
  String? coverUrl(int? coverId, {String size = 'M'}) {
    if (coverId == null) return null;
    return coverUrlFromCoverId(coverId, size: size);
  }

  /// Fetch description text from a work resource (handles both String and Map formats)
  Future<String?> fetchWorkDescription(String workKey) async {
    try {
      final json = await getWork(workKey);
      final desc = json['description'];
      if (desc == null) return null;
      if (desc is String) return desc;
      if (desc is Map && desc['value'] is String) return desc['value'] as String;
      return null;
    } catch (e) {
      // propagate or return null so UI can handle missing description gracefully
      return null;
    }
  }
}
