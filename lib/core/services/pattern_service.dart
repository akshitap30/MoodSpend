import '../models/models.dart';

/// Client-side pattern detection engine.
/// Runs entirely on device. No server ML required.
class PatternService {
  /// Analyse last N mood logs and produce a PatternModel.
  /// Returns null if insufficient data (< 7 logs).
  static PatternModel? detectPattern({
    required List<MoodLogModel> logs,
    required List<HabitModel> habits,
    required String userId,
  }) {
    final spendingLogs = logs.where((l) => l.amount != null && l.amount! > 0).toList();
    if (spendingLogs.length < 3) return null;

    // ── 1. Find the habit with highest total spend ──────────────────────────
    final habitSpend = <String, double>{};
    final habitCount = <String, int>{};
    for (final log in spendingLogs) {
      if (log.habitId != null) {
        habitSpend[log.habitId!] = (habitSpend[log.habitId!] ?? 0) + log.amount!;
        habitCount[log.habitId!] = (habitCount[log.habitId!] ?? 0) + 1;
      }
    }

    String? topHabitId;
    double topHabitSpend = 0;
    habitSpend.forEach((id, spend) {
      if (spend > topHabitSpend) {
        topHabitSpend = spend;
        topHabitId = id;
      }
    });

    // ── 2. Filter logs for that habit ───────────────────────────────────────
    final habitLogs = topHabitId != null
        ? spendingLogs.where((l) => l.habitId == topHabitId).toList()
        : spendingLogs;

    // ── 3. Find the most common mood bucket ─────────────────────────────────
    final moodCount = <int, int>{};
    for (final log in habitLogs) {
      moodCount[log.mood] = (moodCount[log.mood] ?? 0) + 1;
    }
    final moodBuckets = moodCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topMood = moodBuckets.isNotEmpty ? moodBuckets.first.key : 3;
    final moodRange = topMood <= 2 ? [1, 2] : (topMood == 3 ? [3] : [4, 5]);

    // ── 4. Find the top context tag ─────────────────────────────────────────
    final tagCount = <String, int>{};
    for (final log in habitLogs) {
      for (final tag in log.contextTags) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }
    }
    final topTags = tagCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final triggerTags = topTags.take(2).map((e) => e.key).toList();

    // ── 5. Find peak hour window (sliding 3-hour) ───────────────────────────
    final hourCount = <int, int>{};
    for (final log in habitLogs) {
      hourCount[log.hourOfDay] = (hourCount[log.hourOfDay] ?? 0) + 1;
    }
    int peakHour = 21;
    int peakCount = 0;
    for (int h = 0; h <= 21; h++) {
      final count =
          (hourCount[h] ?? 0) + (hourCount[h + 1] ?? 0) + (hourCount[h + 2] ?? 0);
      if (count > peakCount) {
        peakCount = count;
        peakHour = h;
      }
    }

    // ── 6. Calculate avg spend & confidence ─────────────────────────────────
    final totalSpend = habitLogs.fold<double>(0, (s, l) => s + (l.amount ?? 0));
    final avgSpend = habitLogs.isNotEmpty ? totalSpend / habitLogs.length : 0.0;
    final confidence = habitLogs.length / spendingLogs.length;

    final habitName = habits
        .where((h) => h.id == topHabitId)
        .map((h) => h.name)
        .firstOrNull;

    return PatternModel(
      id: 'pattern_$userId',
      userId: userId,
      generatedAt: DateTime.now(),
      triggerHabitId: topHabitId,
      triggerHabitName: habitName,
      triggerMoodRange: moodRange,
      triggerTags: triggerTags,
      triggerHourStart: peakHour,
      triggerHourEnd: peakHour + 3,
      avgSpend: avgSpend,
      occurrenceCount: habitLogs.length,
      confidenceScore: confidence,
    );
  }

  /// Mood bucket averages for the bar chart.
  static Map<int, double> moodSpendAverages(List<MoodLogModel> logs) {
    final buckets = <int, List<double>>{};
    for (final log in logs) {
      if (log.amount != null) {
        buckets.putIfAbsent(log.mood, () => []).add(log.amount!);
      }
    }
    return buckets.map((mood, amounts) =>
        MapEntry(mood, amounts.reduce((a, b) => a + b) / amounts.length));
  }

  /// Tag spend averages for the horizontal bar chart.
  static Map<String, double> tagSpendAverages(List<MoodLogModel> logs) {
    final tagAmounts = <String, List<double>>{};
    for (final log in logs) {
      if (log.amount != null) {
        for (final tag in log.contextTags) {
          tagAmounts.putIfAbsent(tag, () => []).add(log.amount!);
        }
      }
    }
    return tagAmounts.map((tag, amounts) =>
        MapEntry(tag, amounts.reduce((a, b) => a + b) / amounts.length));
  }

  /// Returns a 7×24 heatmap matrix (dayOfWeek × hour) with spend counts.
  static List<List<int>> buildHeatmap(List<MoodLogModel> logs) {
    final matrix = List.generate(7, (_) => List.filled(24, 0));
    for (final log in logs) {
      if (log.amount != null && log.amount! > 0) {
        matrix[log.dayOfWeek][log.hourOfDay]++;
      }
    }
    return matrix;
  }
}
