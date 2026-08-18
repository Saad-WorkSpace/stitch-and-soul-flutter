import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'app/bootstrap.dart';
import 'data/repositories.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // On the web, SharedPreferences uses localStorage; on mobile it uses the
  // platform-specific store. Either way, we resolve before the first frame.
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: <Override>[
        favoritesRepositoryProvider.overrideWithValue(
          FavoritesRepository(prefs),
        ),
        measurementsRepositoryProvider.overrideWithValue(
          MeasurementsRepository(prefs),
        ),
      ],
      child: const SsBootstrap(child: StitchAndSoulApp()),
    ),
  );
}
