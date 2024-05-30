// lib/pages/auth_page.dart
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/images/logo.png",
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text("Voxiloud",
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary)),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      // Navigate to login
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.primary)),
                    onPressed: () {
                      // Navigate to login
                    },
                    child: const Text(
                      'Signup',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
