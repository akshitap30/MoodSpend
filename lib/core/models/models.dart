import 'package:hive/hive.dart';

part 'habit_model.g.dart';

const habitBoxName = 'habits';
const moodLogBoxName = 'mood_logs';
const challengeBoxName = 'challenges';
const savedJarBoxName = 'saved_jar';
const settingsBoxName = 'settings';

// ─── User ────────────────────────────────────────────────────────────────────
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final double hourlyWage;
  final String goalType;
  final double goalAmount;
  final String goalName;
  final bool onboardingComplete;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.hourlyWage = 312,
    this.goalType = 'vacation',
    this.goalAmount = 50000,
    this.goalName = 'Vacation Fund',
    this.onboardingComplete = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatar_url': avatarUrl,
        'hourly_wage': hourlyWage,
        'goal_type': goalType,
        'goal_amount': goalAmount,
        'goal_name': goalName,
        'onboarding_complete': onboardingComplete,
        'created_at': createdAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'User',
        email: json['email'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
        hourlyWage: (json['hourly_wage'] as num?)?.toDouble() ?? 312,
        goalType: json['goal_type'] as String? ?? 'vacation',
        goalAmount: (json['goal_amount'] as num?)?.toDouble() ?? 50000,
        goalName: json['goal_name'] as String? ?? 'Vacation Fund',
        onboardingComplete: json['onboarding_complete'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  UserModel copyWith({
    String? name,
    String? avatarUrl,
    double? hourlyWage,
    String? goalType,
    double? goalAmount,
    String? goalName,
    bool? onboardingComplete,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        hourlyWage: hourlyWage ?? this.hourlyWage,
        goalType: goalType ?? this.goalType,
        goalAmount: goalAmount ?? this.goalAmount,
        goalName: goalName ?? this.goalName,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        createdAt: createdAt,
      );
}

// ─── Habit ───────────────────────────────────────────────────────────────────
@HiveType(typeId: 0)
class HabitModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String userId;

  @HiveField(2)
  late String name;

  @HiveField(3)
  late String category; // food | transport | subscriptions | other

  @HiveField(4)
  late double costPerInstance;

  @HiveField(5)
  late int frequencyPerMonth;

  @HiveField(6)
  String? triggerTime; // HH:mm

  @HiveField(7)
  late String createdAt;

  @HiveField(8)
  late bool isActive;

  HabitModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.costPerInstance,
    required this.frequencyPerMonth,
    this.triggerTime,
    required this.createdAt,
    this.isActive = true,
  });

  double get monthlyTotal => costPerInstance * frequencyPerMonth;
  double get yearlyTotal => monthlyTotal * 12;
  double get workDaysLost => yearlyTotal / (312 * 8); // fallback wage

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'category': category,
        'cost_per_instance': costPerInstance,
        'frequency_per_month': frequencyPerMonth,
        'trigger_time': triggerTime,
        'created_at': createdAt,
        'is_active': isActive,
      };

  factory HabitModel.fromJson(Map<String, dynamic> json) => HabitModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        costPerInstance: (json['cost_per_instance'] as num).toDouble(),
        frequencyPerMonth: json['frequency_per_month'] as int,
        triggerTime: json['trigger_time'] as String?,
        createdAt: json['created_at'] as String,
        isActive: json['is_active'] as bool? ?? true,
      );
}

// ─── MoodLog ─────────────────────────────────────────────────────────────────
@HiveType(typeId: 1)
class MoodLogModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String userId;

  @HiveField(2)
  late String timestamp;

  @HiveField(3)
  late int mood; // 1-5

  @HiveField(4)
  late int energy; // 1-10

  @HiveField(5)
  late List<String> contextTags;

  @HiveField(6)
  String? habitId;

  @HiveField(7)
  double? amount;

  @HiveField(8)
  String? note;

  @HiveField(9)
  late int hourOfDay;

  @HiveField(10)
  late int dayOfWeek;

  MoodLogModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.mood,
    required this.energy,
    required this.contextTags,
    this.habitId,
    this.amount,
    this.note,
    required this.hourOfDay,
    required this.dayOfWeek,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'timestamp': timestamp,
        'mood': mood,
        'energy': energy,
        'context_tags': contextTags,
        'habit_id': habitId,
        'amount': amount,
        'note': note,
        'hour_of_day': hourOfDay,
        'day_of_week': dayOfWeek,
      };

  factory MoodLogModel.fromJson(Map<String, dynamic> json) => MoodLogModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        timestamp: json['timestamp'] as String,
        mood: json['mood'] as int,
        energy: json['energy'] as int,
        contextTags: List<String>.from(json['context_tags'] ?? []),
        habitId: json['habit_id'] as String?,
        amount: (json['amount'] as num?)?.toDouble(),
        note: json['note'] as String?,
        hourOfDay: json['hour_of_day'] as int,
        dayOfWeek: json['day_of_week'] as int,
      );
}

// ─── Pattern ─────────────────────────────────────────────────────────────────
class PatternModel {
  final String id;
  final String userId;
  final DateTime generatedAt;
  final String? triggerHabitId;
  final String? triggerHabitName;
  final List<int> triggerMoodRange;
  final List<String> triggerTags;
  final int triggerHourStart;
  final int triggerHourEnd;
  final double avgSpend;
  final int occurrenceCount;
  final double confidenceScore;

  PatternModel({
    required this.id,
    required this.userId,
    required this.generatedAt,
    this.triggerHabitId,
    this.triggerHabitName,
    required this.triggerMoodRange,
    required this.triggerTags,
    required this.triggerHourStart,
    required this.triggerHourEnd,
    required this.avgSpend,
    required this.occurrenceCount,
    required this.confidenceScore,
  });

  String get insightText {
    final moodDesc = triggerMoodRange.contains(1) || triggerMoodRange.contains(2)
        ? 'low mood'
        : 'high mood';
    final tagStr = triggerTags.isNotEmpty ? triggerTags.join(' + ') : moodDesc;
    final habitStr = triggerHabitName ?? 'this habit';
    return 'You spend on $habitStr ${(confidenceScore * 100).round()}% of the time when you\'re $tagStr and it\'s past $triggerHourStart:00. This pattern costs you ₹${(avgSpend * occurrenceCount).round()}/month.';
  }
}

// ─── Challenge ───────────────────────────────────────────────────────────────
@HiveType(typeId: 2)
class ChallengeModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String userId;

  @HiveField(2)
  late String weekStart;

  @HiveField(3)
  late String habitId;

  @HiveField(4)
  late String habitName;

  @HiveField(5)
  late String triggerDescription;

  @HiveField(6)
  late String replacementAction;

  @HiveField(7)
  late double targetSaving;

  @HiveField(8)
  late String status; // pending | completed | skipped

  @HiveField(9)
  String? completedAt;

  ChallengeModel({
    required this.id,
    required this.userId,
    required this.weekStart,
    required this.habitId,
    required this.habitName,
    required this.triggerDescription,
    required this.replacementAction,
    required this.targetSaving,
    this.status = 'pending',
    this.completedAt,
  });
}

// ─── SavedJar Entry ──────────────────────────────────────────────────────────
@HiveType(typeId: 3)
class SavedJarEntry extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String userId;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  String? sourceChallengeId;

  @HiveField(4)
  late String createdAt;

  @HiveField(5)
  late String note;

  SavedJarEntry({
    required this.id,
    required this.userId,
    required this.amount,
    this.sourceChallengeId,
    required this.createdAt,
    required this.note,
  });
}
