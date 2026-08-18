import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/tokens.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SsColors.ivory,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '404',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(color: SsColors.inkMuted),
              ),
              const SizedBox(height: 12),
              const Text(
                'That page is not on the rack.',
                style: TextStyle(fontFamily: 'serif', fontSize: 20),
              ),
              const SizedBox(height: 16),
              const Text(
                'Let us walk you back to the collection.',
                style: TextStyle(color: SsColors.inkMuted),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('BACK TO HOME'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
