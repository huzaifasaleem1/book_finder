import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/book_work.dart';
import '../services/open_library_api.dart';

class WorkDetailScreen extends StatefulWidget {
  final OpenLibraryApi api;
  final BookWork work;

  const WorkDetailScreen({
    super.key,
    required this.api,
    required this.work,
  });

  @override
  State<WorkDetailScreen> createState() => _WorkDetailScreenState();
}

class _WorkDetailScreenState extends State<WorkDetailScreen> {
  bool _loading = true;
  String? _description;
  bool _isFavorite = false;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkFavorite();
  }

  Future<void> _loadData() async {
    final desc = await widget.api.fetchWorkDescription(widget.work.workId);
    setState(() {
      _description = desc;
      _loading = false;
    });
  }

  Future<void> _checkFavorite() async {
    if (user == null) return;
    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favorites')
        .doc(widget.work.workId);

    final doc = await favRef.get();
    setState(() {
      _isFavorite = doc.exists;
    });
  }

  Future<void> _toggleFavorite() async {
    if (user == null) return;

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favorites')
        .doc(widget.work.workId);

    try {
      if (_isFavorite) {
        await favRef.delete();
        setState(() => _isFavorite = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Removed from favorites")),
        );
      } else {
        await favRef.set({
          'title': widget.work.title,
          'author': widget.work.authorName ?? "Unknown Author",
          'coverUrl': widget.work.coverUrl ?? "",
          'workKey': widget.work.workId, // ✅ yaha correct id save hogi
        });
        setState(() => _isFavorite = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Added to favorites")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final blue = CupertinoColors.systemBlue;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        title: const Text(
          "Book Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.work.coverUrl != null &&
                widget.work.coverUrl!.isNotEmpty)
              Image.network(
                widget.work.coverUrl!,
                height: 220,
                fit: BoxFit.cover,
              )
            else
              const Icon(Icons.book,
                  size: 120, color: Colors.blueAccent),
            const SizedBox(height: 16),
            Text(
              widget.work.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.work.authorName ?? "Unknown Author",
              style:
              const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              _description ?? "No description available",
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _toggleFavorite,
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(
                _isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Colors.white,
              ),
              label: Text(
                _isFavorite
                    ? "Remove from Favorites"
                    : "Add to Favorites",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
