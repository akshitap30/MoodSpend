// MoodSpend - Unit Tests
// Tests for core business logic that does not require Flutter widgets or Hive.

import 'package:flutter_test/flutter_test.dart';
import 'package:moodspend/core/models/models.dart';
import 'package:moodspend/core/services/pattern_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MoodLogModel _makeLog({
  required String id,
  required int mood,
  required int energy,
  double? amount,
  String? habitId,
  List<String> tags = const [],
  int hour = 14,
  int day = 1,
}) =>
    MoodLogModel(
      id: id,
      userId: 'test_user',
      timestamp: DateTime(2024, 1, 1, hour).toIso8601String(),
      mood: mood,
      energy: energy,
      contextTags: tags,
      habitId: habitId,
      amount: amount,
      hourOfDay: hour,
      dayOfWeek: day,
    );

// ---------------------------------------------------------------------------
// UserModel tests
// ---------------------------------------------------------------------------

void main() {
  group('UserModel', () {
    test('fromJson round-trips through toJson', () {
      final user = UserModel(
        id: 'u1',
        name: 'Akshita',
        email: 'akshita@example.com',
        hourlyWage: 500,
        goalType: 'vacation',
        goalAmount: 50000,
        goalName: 'Goa Trip',
        onboardingComplete: true,
        createdAt: DateTime(2024, 1, 1),
      );

      final json = user.toJson();
      final restored = UserModel.fromJson(json);

      expect(restored.id, user.id);
      expect(restored.name, user.name);
      expect(restored.email, user.email);
      expect(restored.hourlyWage, user.hourlyWage);
      expect(restored.goalType, user.goalType);
      expect(restored.goalAmount, user.goalAmount);
      expect(restored.goalName, user.goalName);
      expect(restored.onboardingComplete, user.onboardingComplete);
    });

    test('copyWith preserves unspecified fields', () {
      final original = UserModel(
        id: 'u1',
        name: 'Akshita',
        email: 'akshita@example.com',
        createdAt: DateTime(2024, 1, 1),
      );

      final updated = original.copyWith(name: 'Priya');
      expect(updated.name, 'Priya');
      expect(updated.id, original.id);
      expect(updated.email, original.email);
    });

    test('default values are applied when JSON fields are missing', () {
      final user = UserModel.fromJson({
        'id': 'u2',
        'created_at': '2024-01-01T00:00:00.000Z',
      });

      expect(user.name, 'User');
      expect(user.email, '');
      expect(user.hourlyWage, 312);
      expect(user.goalType, 'vacation');
      expect(user.onboardingComplete, false);
    });
  });

  // -------------------------------------------------------------------------
  // MoodLogModel tests
  // -------------------------------------------------------------------------

  group('MoodLogModel', () {
    test('fromJson round-trips through toJson', () {
      final log = _makeLog(
        id: 'log1',
        mood: 3,
        energy: 7,
        amount: 150,
        habitId: 'h1',
        tags: ['stressed', 'work'],
        hour: 18,
        day: 3,
      );

      final json = log.toJson();
      final restored = MoodLogModel.fromJson(json);

      expect(restored.id, log.id);
      expect(restored.mood, log.mood);
      expect(restored.energy, log.energy);
      expect(restored.amount, log.amount);
      expect(restored.habitId, log.habitId);
      expect(restored.contextTags, log.contextTags);
      expect(restored.hourOfDay, log.hourOfDay);
      expect(restored.dayOfWeek, log.dayOfWeek);
    });

    test('contextTags defaults to empty list when missing from JSON', () {
      final log = MoodLogModel.fromJson({
        'id': 'log2',
        'user_id': 'u1',
        'timestamp': '2024-01-01T10:00:00.000Z',
        'mood': 4,
        'energy': 8,
        'hour_of_day': 10,
        'day_of_week': 1,
      });

      expect(log.contextTags, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // PatternModel tests
  // -------------------------------------------------------------------------

  group('PatternModel.insightText', () {
    test('generates insight text for low-mood pattern', () {
      final pattern = PatternModel(
        id: 'p1',
        userId: 'u1',
        generatedAt: DateTime(2024, 1, 1),
        triggerHabitName: 'Morning coffee',
        triggerMoodRange: [1, 2],
        triggerTags: ['stressed'],
        triggerHourStart: 9,
        triggerHourEnd: 12,
        avgSpend: 150,
        occurrenceCount: 10,
        confidenceScore: 0.8,
      );

      final text = pattern.insightText;
      expect(text, contains('Morning coffee'));
      expect(text, contains('80%'));
    });

    test('generates insight text when no habit name is available', () {
      final pattern = PatternModel(
        id: 'p2',
        userId: 'u1',
        generatedAt: DateTime(2024, 1, 1),
        triggerMoodRange: [4, 5],
        triggerTags: [],
        triggerHourStart: 20,
        triggerHourEnd: 23,
        avgSpend: 500,
        occurrenceCount: 5,
        confidenceScore: 0.6,
      );

      expect(pattern.insightText, contains('this habit'));
    });
  });

  // -------------------------------------------------------------------------
  // PatternService tests
  // -------------------------------------------------------------------------

  group('PatternService.detectPattern', () {
    test('returns null when fewer than 3 spending logs exist', () {
      final logs = [
        _makeLog(id: 'l1', mood: 2, energy: 4, amount: 100, habitId: 'h1'),
        _makeLog(id: 'l2', mood: 3, energy: 5, amount: 200, habitId: 'h1'),
      ];

      final result = PatternService.detectPattern(
        logs: logs,
        habits: [],
        userId: 'u1',
      );

      expect(result, isNull);
    });

    test('detects pattern from sufficient logs', () {
      final logs = List.generate(
        5,
        (i) => _makeLog(
          id: 'l$i',
          mood: 2,
          energy: 4,
          amount: 150,
          habitId: 'h1',
          tags: ['stressed'],
          hour: 21,
          day: i % 7,
        ),
      );

      final result = PatternService.detectPattern(
        logs: logs,
        habits: [],
        userId: 'u1',
      );

      expect(result, isNotNull);
      expect(result!.userId, 'u1');
      expect(result.avgSpend, greaterThan(0));
    });

    test('returns null when no logs have a spending amount', () {
      final logs = List.generate(
        5,
        (i) => _makeLog(id: 'l$i', mood: 3, energy: 6),
      );

      final result = PatternService.detectPattern(
        logs: logs,
        habits: [],
        userId: 'u1',
      );

      expect(result, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // PatternService.moodSpendAverages tests
  // -------------------------------------------------------------------------

  group('PatternService.moodSpendAverages', () {
    test('computes per-mood average spend correctly', () {
      final logs = [
        _makeLog(id: 'l1', mood: 1, energy: 3, amount: 100),
        _makeLog(id: 'l2', mood: 1, energy: 4, amount: 200),
        _makeLog(id: 'l3', mood: 5, energy: 9, amount: 50),
      ];

      final averages = PatternService.moodSpendAverages(logs);

      expect(averages[1], 150);
      expect(averages[5], 50);
    });

    test('ignores logs without amounts', () {
      final logs = [
        _makeLog(id: 'l1', mood: 3, energy: 5),
        _makeLog(id: 'l2', mood: 3, energy: 6, amount: 300),
      ];

      final averages = PatternService.moodSpendAverages(logs);
      expect(averages[3], 300);
    });
  });

  // -------------------------------------------------------------------------
  // PatternService.tagSpendAverages tests
  // -------------------------------------------------------------------------

  group('PatternService.tagSpendAverages', () {
    test('computes per-tag average spend correctly', () {
      final logs = [
        _makeLog(
            id: 'l1', mood: 2, energy: 4, amount: 200, tags: ['stressed']),
        _makeLog(
            id: 'l2', mood: 3, energy: 5, amount: 400, tags: ['stressed']),
        _makeLog(id: 'l3', mood: 4, energy: 7, amount: 100, tags: ['happy']),
      ];

      final averages = PatternService.tagSpendAverages(logs);

      expect(averages['stressed'], 300);
      expect(averages['happy'], 100);
    });
  });

  // -------------------------------------------------------------------------
  // PatternService.buildHeatmap tests
  // -------------------------------------------------------------------------

  group('PatternService.buildHeatmap', () {
    test('returns a 7x24 matrix', () {
      final matrix = PatternService.buildHeatmap([]);
      expect(matrix.length, 7);
      expect(matrix[0].length, 24);
    });

    test('increments correct cell for each spending log', () {
      final logs = [
        _makeLog(id: 'l1', mood: 2, energy: 4, amount: 100, hour: 10, day: 2),
        _makeLog(id: 'l2', mood: 3, energy: 5, amount: 200, hour: 10, day: 2),
        _makeLog(id: 'l3', mood: 4, energy: 7, hour: 10, day: 2), // no amount
      ];

      final matrix = PatternService.buildHeatmap(logs);
      expect(matrix[2][10], 2); // 2 spending logs at day=2, hour=10
    });
  });
}
