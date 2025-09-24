import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Auth error")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final blue = CupertinoColors.systemBlue;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _isLogin ? "Login" : "Sign Up",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        )
            : null,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailController,
                  cursorColor: blue,
                  decoration: InputDecoration(
                    labelText: "Email",
                    suffixIcon: _emailController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        _emailController.clear();
                        setState(() {});
                      },
                    )
                        : null,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: blue, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: blue, width: 1),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  cursorColor: blue,
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: _passwordController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        _passwordController.clear();
                        setState(() {});
                      },
                    )
                        : null,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: blue, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: blue, width: 1),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                if (_loading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_isLogin ? "Login" : "Sign Up"),
                  ),
                TextButton(
                  onPressed: () =>
                      setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin
                        ? "Create new account"
                        : "I already have an account",
                    style: TextStyle(color: blue),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
