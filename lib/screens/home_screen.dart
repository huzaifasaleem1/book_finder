import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:books_finder/services/open_library_api.dart';
import 'package:books_finder/screens/search_screen.dart';
import 'package:books_finder/screens/favorites_screen.dart';
import 'package:books_finder/screens/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  final OpenLibraryApi api;
  const HomeScreen({super.key, required this.api});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _onLogout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final blue = Colors.blue;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        title: const Text(
          "Search Books",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: blue),
              child: const Center(
                child: Text(
                  "Book Finder",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.black),
              title: const Text("Search"),
              onTap: () {
                Navigator.pop(context); // stay on search (default)
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.black),
              title: const Text("Favorites"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text("Logout"),
              onTap: _onLogout,
            ),
          ],
        ),
      ),
      body: SearchScreen(api: widget.api),
    );
  }
}
