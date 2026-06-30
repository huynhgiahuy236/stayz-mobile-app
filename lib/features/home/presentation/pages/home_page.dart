import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('StayZ')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Find your next stay', style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Project structure is ready for feature-based development.',
                style: textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
