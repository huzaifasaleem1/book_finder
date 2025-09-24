import 'package:flutter/material.dart';
import '../models/book_work.dart';
import '../services/open_library_api.dart';

class BookCard extends StatelessWidget {
  final BookWork book;
  final OpenLibraryApi api;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.api,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ListTile(
        leading: book.coverUrl != null
            ? Image.network(book.coverUrl!, width: 50, fit: BoxFit.cover)
            : const Icon(Icons.book, size: 40),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          book.authors.isNotEmpty ? book.authors.join(", ") : "Unknown Author",
        ),
        onTap: onTap,
      ),
    );
  }
}
