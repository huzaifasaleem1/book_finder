import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter/services.dart'; // For SystemNavigator.pop

import '../providers/search_provider.dart';
import '../widgets/book_card.dart';
import '../services/open_library_api.dart';
import 'work_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final OpenLibraryApi api;
  const SearchScreen({super.key, required this.api});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final ScrollController _scrollController;
  late final TextEditingController _controller;
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller = TextEditingController();

    _scrollController.addListener(() {
      final prov = context.read<SearchProvider>();
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !prov.loading &&
          prov.hasMore) {
        prov.search(reset: false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Press back again to exit"),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final blue = CupertinoColors.systemBlue;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Consumer<SearchProvider>(
        builder: (context, prov, _) {
          return Column(
            children: [
              // 🔎 Search box
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _controller,
                  cursorColor: blue,
                  decoration: InputDecoration(
                    hintText: "Search books, authors, ISBN...",
                    prefixIcon: const Icon(Icons.search),
                    prefixIconColor: blue,
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () {
                        _controller.clear();
                        prov.setQuery('');
                        setState(() {}); // refresh clear button state
                      },
                    )
                        : null,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: blue, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: blue, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (val) {
                    prov.setQuery(val);
                    setState(() {}); // update suffix icon
                  },
                  onSubmitted: (_) => prov.search(reset: true),
                ),
              ),

              // 📚 Results
              Expanded(
                child: Builder(
                  builder: (ctx) {
                    if (prov.state == SearchState.idle) {
                      return const Center(
                        child: Text("Search for books to get started"),
                      );
                    }

                    if (prov.loading && prov.results.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      );
                    }

                    if (prov.state == SearchState.empty) {
                      return const Center(
                        child: Text("No results found"),
                      );
                    }

                    if (prov.state == SearchState.error &&
                        prov.results.isEmpty) {
                      return Center(
                        child: Text("Error: ${prov.error}"),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: prov.results.length + (prov.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= prov.results.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: Colors.blue),
                            ),
                          );
                        }

                        final book = prov.results[index];
                        return BookCard(
                          book: book,
                          api: widget.api,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WorkDetailScreen(
                                  api: widget.api,
                                  work: book,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
