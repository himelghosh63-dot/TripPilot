
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;
  bool hidePassword = true;

  Future<void> authenticate() async {
    final email = emailController.text.trim();
    final loginInput = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();
    final normalizedUsername = username.toLowerCase();

    if (loginInput.isEmpty || password.isEmpty ||
    (!isLogin && username.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
        ),
      );
      return;
    }

    if (!isLogin &&
        !RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Username must be 3-20 characters (letters, numbers, underscore)',
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      if (isLogin) {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:3000/api/auth/login'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'identifier': loginInput,
      'password': password,
    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode != 200) {
    throw Exception(data['message'] ?? 'Login failed');
  }

  await auth.signInWithCustomToken(data['customToken']);

  if (mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }
      } else {
        final result = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = result.user!;

        try {
          await firestore.runTransaction((transaction) async {
            final usernameRef = firestore
                .collection('usernames')
                .doc(normalizedUsername);

            final usernameDoc = await transaction.get(usernameRef);

            if (usernameDoc.exists) {
              throw Exception('USERNAME_ALREADY_TAKEN');
            }

            transaction.set(usernameRef, {
              'username': username,
              'email': email,
              'uid': user.uid,
              'createdAt': FieldValue.serverTimestamp(),
            });
          });
        } catch (e) {
          await user.delete();
          await auth.signOut();

          if (e.toString().contains('USERNAME_ALREADY_TAKEN')) {
            throw FirebaseAuthException(
              code: 'username-already-taken',
              message: 'This username is already taken. Choose another.',
            );
          }

          rethrow;
        }

        await user.sendEmailVerification();
        await auth.signOut();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account created! Check your email to verify.',
              ),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? e.code)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TripPilot Account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.travel_explore,
                size: 75,
                color: Colors.teal,
              ),
              const SizedBox(height: 20),
              Text(
                isLogin ? 'Welcome Back!' : 'Create Account',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),

              if (!isLogin) ...[
                TextField(
                  controller: usernameController,
                  decoration:  InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 15),
              ],

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: isLogin ? 'Username or Email' : 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: passwordController,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => hidePassword = !hidePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : authenticate,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Text(isLogin ? 'Login' : 'Sign Up'),
                ),
              ),

              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        setState(() => isLogin = !isLogin);
                      },
                child: Text(
                  isLogin
                      ? "Don't have an account? Sign Up"
                      : 'Already have an account? Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
