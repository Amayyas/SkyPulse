import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:skypulse/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skypulse/providers/theme_provider.dart';
import 'package:skypulse/providers/weather_provider.dart';
import 'package:skypulse/screens/home_screen.dart';
import 'package:skypulse/utils/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Both supported locales, so date formatting works whichever one wins.
  await initializeDateFormatting('en');
  await initializeDateFormatting('fr');
  // Loaded before the first frame so the saved city is available synchronously
  // when providers build — no flash of GPS before it appears.
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const SkyPulseApp(),
    ),
  );
}

class SkyPulseApp extends ConsumerStatefulWidget {
  const SkyPulseApp({super.key});

  @override
  ConsumerState<SkyPulseApp> createState() => _SkyPulseAppState();
}

class _SkyPulseAppState extends ConsumerState<SkyPulseApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A backgrounded app can sit through an hour boundary and miss its timer;
    // recompute the theme when it comes back.
    if (state == AppLifecycleState.resumed) {
      ref.read(timeOfDayThemeProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bucket = ref.watch(timeOfDayThemeProvider);
    // Honour the OS "reduce motion" setting: some users disable animations for
    // vestibular reasons, and the entrance animations run on every card.
    Animate.restartOnHotReload = false;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      Animate.defaultDuration = Duration.zero;
    }

    return MaterialApp(
      title: 'SkyPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeFor(bucket),
      // No hardcoded locale: the app follows the device language, falling back
      // to the first supported locale (English) when it isn't French.
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const HomeScreen(),
    );
  }
}
