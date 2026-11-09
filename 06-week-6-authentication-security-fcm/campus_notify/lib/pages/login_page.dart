
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Campus Notify')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Login Campus Notify',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              key: const Key('emailField'),
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref.read(emailInputProvider.notifier).state = value;
              },
            ),
            const SizedBox(height: 15),
            TextField(
              key: const Key('passwordField'),
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Kata Sandi',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref.read(passwordInputProvider.notifier).state = value;
              },
            ),
            const SizedBox(height: 20),
            if (auth.hasError)
              Text(
                auth.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : () {
                        ref.read(authStateProvider.notifier).login(
                          ref.read(emailInputProvider),
                          ref.read(passwordInputProvider),
                        );
                      },
                child: auth.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final emailInputProvider = StateProvider<String>((ref) => '');
final passwordInputProvider = StateProvider<String>((ref) => '');
