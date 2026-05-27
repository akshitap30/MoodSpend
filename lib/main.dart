import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/models/models.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Hive Init ──────────────────────────────────────────────────────────────
  await Hive.initFlutter();

  // Guard adapter registration (safe for hot restarts)
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(HabitModelAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(MoodLogModelAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ChallengeModelAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SavedJarEntryAdapter());

  // Guard box opening — each box opens exactly once per Hive session
  await Future.wait([
    if (!Hive.isBoxOpen(habitBoxName))
      Hive.openBox<HabitModel>(habitBoxName),
    if (!Hive.isBoxOpen(moodLogBoxName))
      Hive.openBox<MoodLogModel>(moodLogBoxName),
    if (!Hive.isBoxOpen(challengeBoxName))
      Hive.openBox<ChallengeModel>(challengeBoxName),
    if (!Hive.isBoxOpen(savedJarBoxName))
      Hive.openBox<SavedJarEntry>(savedJarBoxName),
    if (!Hive.isBoxOpen(settingsBoxName))
      Hive.openBox(settingsBoxName),
  ]);

  runApp(const ProviderScope(child: MoodSpendApp()));
}

class MoodSpendApp extends ConsumerWidget {
  const MoodSpendApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'MoodSpend',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
