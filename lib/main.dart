import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/library_controller.dart';
import 'services/catalog_controller.dart';
import 'services/playback_controller.dart';
import 'services/preferences_store.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AuroraBootstrap());
}

/// Shows Flutter content immediately instead of holding the Android launch
/// surface while preferences or the media service are being initialized.
class AuroraBootstrap extends StatefulWidget {
  const AuroraBootstrap({super.key});

  @override
  State<AuroraBootstrap> createState() => _AuroraBootstrapState();
}

class _AuroraBootstrapState extends State<AuroraBootstrap> {
  PreferencesStore? _preferences;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final preferences = await PreferencesStore.create();
    if (mounted) setState(() => _preferences = preferences);
  }

  @override
  Widget build(BuildContext context) {
    final preferences = _preferences;
    if (preferences == null) return const AuroraLoadingApp();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LibraryController(preferences)..load()),
        ChangeNotifierProvider(create: (_) => CatalogController()),
        ChangeNotifierProvider(create: (_) => PlaybackController(preferences)),
      ],
      child: const AuroraApp(),
    );
  }
}
