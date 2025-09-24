import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'services/open_library_api.dart';
import 'providers/search_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final api = OpenLibraryApi(
    userAgent: "BookFinder/1.0 (your_email@example.com)",
  );

  runApp(MyApp(api: api));
}

class MyApp extends StatelessWidget {
  final OpenLibraryApi api;
  const MyApp({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchProvider(api: api)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Book Finder',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: AuthWrapper(api: api),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final OpenLibraryApi api;
  const AuthWrapper({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.blue)),
          );
        }


        if (snapshot.hasData) {
          return HomeScreen(api: api);
        }


        return const AuthScreen();
      },
    );
  }
}
