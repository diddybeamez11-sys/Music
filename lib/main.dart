import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/library_controller.dart';
import 'services/catalog_controller.dart';
import 'services/playback_controller.dart';
import 'services/preferences_store.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await PreferencesStore.create();
  final playback = await PlaybackController.create(preferences);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LibraryController(preferences)..load()),
        ChangeNotifierProvider(create: (_) => CatalogController()),
        ChangeNotifierProvider.value(value: playback),
      ],
      child: const AuroraApp(),
    ),
  );
}
