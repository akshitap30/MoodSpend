import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import '../services/pattern_service.dart';

// ─── Settings Provider ─────────────────────────────────────────────────────
class AppSettings {
  final String userId;
  final String name;
  final String? avatarUrl;
  final double hourlyWage;
  final String goalType;
  final double goalAmount;
  final String goalName;
  final bool onboardingComplete;
  final bool notifyDailyReminder;
  final bool notifyWeeklySummary;
  final bool notifyChallengeNudge;
  final bool notifyPeakWindow;
  final String dailyReminderTime; // HH:mm
  final String memberSince;
  final int streak;
  final DateTime? lastLogDate;

  const AppSettings({
    this.userId = '',
    this.name = 'User',
    this.avatarUrl,
    this.hourlyWage = 312,
    this.goalType = 'vacation',
    this.goalAmount = 50000,
    this.goalName = 'Vacation Fund',
    this.onboardingComplete = false,
    this.notifyDailyReminder = true,
    this.notifyWeeklySummary = true,
    this.notifyChallengeNudge = true,
    this.notifyPeakWindow = true,
    this.dailyReminderTime = '20:00',
    this.memberSince = '',
    this.streak = 0,
    this.lastLogDate,
  });

  AppSettings copyWith({
    String? userId,
    String? name,
    String? avatarUrl,
    double? hourlyWage,
    String? goalType,
    double? goalAmount,
    String? goalName,
    bool? onboardingComplete,
    bool? notifyDailyReminder,
    bool? notifyWeeklySummary,
    bool? notifyChallengeNudge,
    bool? notifyPeakWindow,
    String? dailyReminderTime,
    String? memberSince,
    int? streak,
    DateTime? lastLogDate,
  }) =>
      AppSettings(
        userId: userId ?? this.userId,
        name: name ?? this.name,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        hourlyWage: hourlyWage ?? this.hourlyWage,
        goalType: goalType ?? this.goalType,
        goalAmount: goalAmount ?? this.goalAmount,
        goalName: goalName ?? this.goalName,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        notifyDailyReminder: notifyDailyReminder ?? this.notifyDailyReminder,
        notifyWeeklySummary: notifyWeeklySummary ?? this.notifyWeeklySummary,
        notifyChallengeNudge: notifyChallengeNudge ?? this.notifyChallengeNudge,
        notifyPeakWindow: notifyPeakWindow ?? this.notifyPeakWindow,
        dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
        memberSince: memberSince ?? this.memberSince,
        streak: streak ?? this.streak,
        lastLogDate: lastLogDate ?? this.lastLogDate,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'avatar_url': avatarUrl,
        'hourly_wage': hourlyWage,
        'goal_type': goalType,
        'goal_amount': goalAmount,
        'goal_name': goalName,
        'onboarding_complete': onboardingComplete,
        'notify_daily': notifyDailyReminder,
        'notify_weekly': notifyWeeklySummary,
        'notify_challenge': notifyChallengeNudge,
        'notify_peak': notifyPeakWindow,
        'reminder_time': dailyReminderTime,
        'member_since': memberSince,
        'streak': streak,
        'last_log_date': lastLogDate?.toIso8601String(),
      };

  factory AppSettings.fromJson(Map<dynamic, dynamic> json) => AppSettings(
        userId: json['user_id'] as String? ?? '',
        name: json['name'] as String? ?? 'User',
        avatarUrl: json['avatar_url'] as String?,
        hourlyWage: (json['hourly_wage'] as num?)?.toDouble() ?? 312,
        goalType: json['goal_type'] as String? ?? 'vacation',
        goalAmount: (json['goal_amount'] as num?)?.toDouble() ?? 50000,
        goalName: json['goal_name'] as String? ?? 'Vacation Fund',
        onboardingComplete: json['onboarding_complete'] as bool? ?? false,
        notifyDailyReminder: json['notify_daily'] as bool? ?? true,
        notifyWeeklySummary: json['notify_weekly'] as bool? ?? true,
        notifyChallengeNudge: json['notify_challenge'] as bool? ?? true,
        notifyPeakWindow: json['notify_peak'] as bool? ?? true,
        dailyReminderTime: json['reminder_time'] as String? ?? '20:00',
        memberSince: json['member_since'] as String? ?? '',
        streak: json['streak'] as int? ?? 0,
        lastLogDate: json['last_log_date'] != null
            ? DateTime.tryParse(json['last_log_date'] as String)
            : null,
      );
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _boxKey = 'app_settings';

  @override
  AppSettings build() {
    _loadFromHive();
    return const AppSettings();
  }

  Box get _box => Hive.box(settingsBoxName);

  void _loadFromHive() {
    final data = _box.get(_boxKey);
    if (data != null) {
      Future.microtask(() => state = AppSettings.fromJson(data as Map));
    }
  }

  Future<void> _save() async {
    await _box.put(_boxKey, state.toJson());
  }

  void update(AppSettings Function(AppSettings) fn) {
    state = fn(state);
    _save();
  }

  void incrementStreak() {
    final now = DateTime.now();
    final lastLog = state.lastLogDate;
    if (lastLog == null || now.difference(lastLog).inDays >= 1) {
      final newStreak = lastLog != null && now.difference(lastLog).inDays == 1
          ? state.streak + 1
          : 1;
      state = state.copyWith(streak: newStreak, lastLogDate: now);
      _save();
    }
  }

  /// Clears all persisted settings and resets in-memory state.
  /// Call this on sign-out so the router redirects to /auth automatically.
  Future<void> signOut() async {
    await _box.clear();
    state = const AppSettings();
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

// ─── Habits Provider ───────────────────────────────────────────────────────
class HabitsNotifier extends Notifier<List<HabitModel>> {
  @override
  List<HabitModel> build() {
    _loadFromHive();
    return [];
  }

  Box<HabitModel> get _box => Hive.box<HabitModel>(habitBoxName);

  void _loadFromHive() {
    final raw = _box.values.toList();
    if (raw.isNotEmpty) {
      Future.microtask(() {
        state = raw.whereType<HabitModel>().where((h) => h.isActive).toList();
      });
    }
  }

  Future<void> add(HabitModel habit) async {
    await _box.put(habit.id, habit);
    state = [...state, habit];
  }

  Future<void> remove(String id) async {
    final item = _box.get(id);
    if (item is HabitModel) {
      item.isActive = false;
      await item.save();
    }
    state = state.where((h) => h.id != id).toList();
  }

  Future<void> update(HabitModel updated) async {
    await _box.put(updated.id, updated);
    state = state.map((h) => h.id == updated.id ? updated : h).toList();
  }

  void seedDefaults(String userId, List<String> habitNames) {
    if (state.isNotEmpty) return;
    final defaults = _defaultHabits(userId, habitNames);
    for (final h in defaults) {
      _box.put(h.id, h);
    }
    state = defaults;
  }

  /// Wipes all habits from Hive and clears state. Called on sign-out.
  Future<void> clearAll() async {
    await _box.clear();
    state = [];
  }

  static final _prebuiltData = <String, Map<String, dynamic>>{
    'Morning coffee': {'category': 'food', 'cost': 120.0, 'freq': 22},
    'Uber/Ola': {'category': 'transport', 'cost': 250.0, 'freq': 12},
    'Swiggy/Zomato': {'category': 'food', 'cost': 400.0, 'freq': 8},
    'Netflix': {'category': 'subscriptions', 'cost': 649.0, 'freq': 1},
    'Spotify': {'category': 'subscriptions', 'cost': 119.0, 'freq': 1},
    'Amazon impulse': {'category': 'other', 'cost': 800.0, 'freq': 3},
    'Cigarettes': {'category': 'other', 'cost': 350.0, 'freq': 20},
    'Energy drinks': {'category': 'food', 'cost': 120.0, 'freq': 10},
    'Office canteen': {'category': 'food', 'cost': 150.0, 'freq': 20},
    'Weekend drinks': {'category': 'food', 'cost': 1200.0, 'freq': 4},
    'Movie tickets': {'category': 'other', 'cost': 350.0, 'freq': 2},
    'Online shopping': {'category': 'other', 'cost': 600.0, 'freq': 4},
  };

  static List<HabitModel> _defaultHabits(
      String userId, List<String> names) {
    final now = DateTime.now().toIso8601String();
    return names.map((name) {
      final data = _prebuiltData[name] ?? {'category': 'other', 'cost': 200.0, 'freq': 5};
      return HabitModel(
        id: 'habit_${name.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        name: name,
        category: data['category'] as String,
        costPerInstance: data['cost'] as double,
        frequencyPerMonth: data['freq'] as int,
        createdAt: now,
      );
    }).toList();
  }
}

final habitsProvider = NotifierProvider<HabitsNotifier, List<HabitModel>>(
  HabitsNotifier.new,
);

// ─── Mood Log Provider ─────────────────────────────────────────────────────
class MoodLogNotifier extends Notifier<List<MoodLogModel>> {
  @override
  List<MoodLogModel> build() {
    _loadFromHive();
    return [];
  }

  Box<MoodLogModel> get _box => Hive.box<MoodLogModel>(moodLogBoxName);

  void _loadFromHive() {
    final raw = _box.values.toList();
    if (raw.isNotEmpty) {
      Future.microtask(() {
        state = raw.whereType<MoodLogModel>().toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
    }
  }

  Future<void> addLog(MoodLogModel log) async {
    await _box.put(log.id, log);
    state = [log, ...state];
  }

  /// Wipes all mood logs from Hive and clears state. Called on sign-out.
  Future<void> clearAll() async {
    await _box.clear();
    state = [];
  }

  MoodLogModel? get todaysLog {
    final today = DateTime.now();
    return state.where((l) {
      final d = DateTime.parse(l.timestamp);
      return d.year == today.year && d.month == today.month && d.day == today.day;
    }).firstOrNull;
  }

  double get todayTotal {
    final today = DateTime.now();
    return state
        .where((l) {
          final d = DateTime.parse(l.timestamp);
          return d.year == today.year &&
              d.month == today.month &&
              d.day == today.day;
        })
        .fold<double>(0, (s, l) => s + (l.amount ?? 0));
  }
}

final moodLogProvider = NotifierProvider<MoodLogNotifier, List<MoodLogModel>>(
  MoodLogNotifier.new,
);

// ─── Pattern Provider ──────────────────────────────────────────────────────
final patternProvider = Provider<PatternModel?>((ref) {
  final logs = ref.watch(moodLogProvider);
  final habits = ref.watch(habitsProvider);
  final settings = ref.watch(settingsProvider);
  if (logs.length < 3) return null;
  return PatternService.detectPattern(
    logs: logs,
    habits: habits,
    userId: settings.userId,
  );
});

// ─── Challenge Provider ────────────────────────────────────────────────────
class ChallengeNotifier extends Notifier<List<ChallengeModel>> {
  @override
  List<ChallengeModel> build() {
    _loadFromHive();
    return [];
  }

  Box<ChallengeModel> get _box => Hive.box<ChallengeModel>(challengeBoxName);

  void _loadFromHive() {
    final raw = _box.values.toList();
    if (raw.isNotEmpty) {
      Future.microtask(() {
        state = raw.whereType<ChallengeModel>().toList()
          ..sort((a, b) => b.weekStart.compareTo(a.weekStart));
      });
    }
  }

  Future<void> add(ChallengeModel c) async {
    await _box.put(c.id, c);
    state = [c, ...state];
  }

  Future<void> complete(String id, double saving) async {
    final item = _box.get(id);
    if (item is ChallengeModel) {
      item.status = 'completed';
      item.completedAt = DateTime.now().toIso8601String();
      await item.save();
    }
    state = state.map((c) {
      if (c.id == id) {
        c.status = 'completed';
        c.completedAt = DateTime.now().toIso8601String();
      }
      return c;
    }).toList();

    // Credit savings jar
    ref.read(savedJarProvider.notifier).addEntry(SavedJarEntry(
          id: 'jar_${DateTime.now().millisecondsSinceEpoch}',
          userId: '',
          amount: saving,
          sourceChallengeId: id,
          createdAt: DateTime.now().toIso8601String(),
          note: 'Challenge completed',
        ));
  }

  Future<void> skip(String id) async {
    final item = _box.get(id);
    if (item is ChallengeModel) {
      item.status = 'skipped';
      await item.save();
    }
    state = state.map((c) {
      if (c.id == id) c.status = 'skipped';
      return c;
    }).toList();
  }

  /// Wipes all challenges from Hive and clears state. Called on sign-out.
  Future<void> clearAll() async {
    await _box.clear();
    state = [];
  }

  ChallengeModel? get currentChallenge =>
      state.where((c) => c.status == 'pending').firstOrNull;

  void generateFromPattern(PatternModel pattern, List<HabitModel> habits) {
    if (currentChallenge != null) return;
    final habit = habits
        .where((h) => h.id == pattern.triggerHabitId)
        .firstOrNull;
    if (habit == null) return;

    const replacements = [
      'Take a 10-minute walk instead',
      'Do a 5-minute breathing exercise',
      'Drink a glass of water and wait 15 mins',
      'Call a friend for 5 minutes',
      'Write 3 things you\'re grateful for',
    ];
    final replacement = replacements[DateTime.now().microsecond % replacements.length];

    final weekStart = _getWeekStart();
    final challenge = ChallengeModel(
      id: 'challenge_${DateTime.now().millisecondsSinceEpoch}',
      userId: pattern.userId,
      weekStart: weekStart,
      habitId: habit.id,
      habitName: habit.name,
      triggerDescription:
          'Skip ${habit.name} once when you feel ${pattern.triggerTags.isNotEmpty ? pattern.triggerTags.first : "stressed"}',
      replacementAction: replacement,
      targetSaving: habit.costPerInstance,
    );
    add(challenge);
  }

  static String _getWeekStart() {
    final now = DateTime.now();
    final diff = now.weekday - 1;
    final monday = now.subtract(Duration(days: diff));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }
}

final challengeProvider =
    NotifierProvider<ChallengeNotifier, List<ChallengeModel>>(
  ChallengeNotifier.new,
);

// ─── Saved Jar Provider ────────────────────────────────────────────────────
class SavedJarNotifier extends Notifier<List<SavedJarEntry>> {
  @override
  List<SavedJarEntry> build() {
    _loadFromHive();
    return [];
  }

  Box<SavedJarEntry> get _box => Hive.box<SavedJarEntry>(savedJarBoxName);

  void _loadFromHive() {
    final raw = _box.values.toList();
    if (raw.isNotEmpty) {
      Future.microtask(() {
        state = raw.whereType<SavedJarEntry>().toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      });
    }
  }

  Future<void> addEntry(SavedJarEntry entry) async {
    await _box.put(entry.id, entry);
    state = [entry, ...state];
  }

  /// Wipes all jar entries from Hive and clears state. Called on sign-out.
  Future<void> clearAll() async {
    await _box.clear();
    state = [];
  }

  double get totalSaved => state.fold(0, (s, e) => s + e.amount);
}

final savedJarProvider =
    NotifierProvider<SavedJarNotifier, List<SavedJarEntry>>(
  SavedJarNotifier.new,
);


