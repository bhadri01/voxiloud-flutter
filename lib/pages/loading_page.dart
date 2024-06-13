// lib/pages/loading_page.dart
import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});
  @override
  Widget build(BuildContext context) {
    // Simulate a loading process
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/dashboard');
    });

    return Scaffold(
      body: Center(
        child: Container(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logo.png",
                height: 150,
                width: 150,
              ),
              const SizedBox(
                height: 24,
              ),
              Text("Voxiloud",
                  style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary))
            ],
          ),
        ),
      ),
    );
  }
}
