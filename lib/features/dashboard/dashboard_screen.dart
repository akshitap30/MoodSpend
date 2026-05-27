import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final habits = ref.watch(habitsProvider);
    final logs = ref.watch(moodLogProvider);
    final pattern = ref.watch(patternProvider);
    final todaySpent = ref.watch(moodLogProvider.notifier).todayTotal;
    final todayLog = ref.watch(moodLogProvider.notifier).todaysLog;

    // Category spending breakdown
    final categorySpend = <String, double>{};
    for (final habit in habits) {
      categorySpend[habit.category] =
          (categorySpend[habit.category] ?? 0) + habit.monthlyTotal;
    }

    // Top 3 habits by yearly cost
    final topHabits = [...habits]
      ..sort((a, b) => b.yearlyTotal.compareTo(a.yearlyTotal));
    final top3 = topHabits.take(3).toList();

    // Future You teaser (top habit * 10yr compound 10%)
    final topHabit = topHabits.isNotEmpty ? topHabits.first : null;
    final futureValue = topHabit != null
        ? topHabit.monthlyTotal * ((pow(1.1, 10) - 1) / (0.1 / 12) * (0.1 / 12))
        : 0.0;

    // Insight text (only show when meaningful)
    final hasInsight = pattern != null || logs.length >= 3;
    final insightText = pattern != null
        ? pattern.insightText
        : logs.length >= 3
            ? 'Pattern detected! Check your Insights tab.'
            : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accentLime,
          backgroundColor: AppColors.card,
          onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
          child: CustomScrollView(
            slivers: [
              // ── Header ────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_greeting(), style: AppTextStyles.caption),
                          Text(settings.name, style: AppTextStyles.h2),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.go('/profile'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.accentLime,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              settings.name.isNotEmpty
                                  ? settings.name[0].toUpperCase()
                                  : 'U',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.background,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // ── 3 Metric Chips ────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: MetricChip(
                            label: 'Spent today',
                            value: formatRupees(todaySpent),
                            valueColor: todaySpent > 0
                                ? AppColors.accentCoral
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MetricChip(
                            label: 'Mood logged',
                            value: todayLog != null
                                ? _moodEmoji(todayLog.mood)
                                : '— none',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MetricChip(
                            label: 'Streak',
                            value: settings.streak > 0
                                ? '🔥 ${settings.streak}d'
                                : '— start',
                            valueColor: settings.streak > 0
                                ? AppColors.accentCoral
                                : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ── Insight Banner (only when there's actual insight) ──
                    if (hasInsight && insightText != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Text('⚡',
                                style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(insightText,
                                  style: AppTextStyles.bodySecondary),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => context.go('/log'),
                              child: Text('Log →',
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.accentLime)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Quick-log nudge (new users only) ──────────────────
                    if (!hasInsight) ...[
                      _QuickLogNudge(
                        logsCount: logs.length,
                        onLog: () => context.go('/log'),
                        onChallenge: () => context.go('/challenge'),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Habit Cost Ring Chart ─────────────────────────────
                    if (habits.isNotEmpty) ...[
                      SectionHeader(
                        title: 'MONTHLY SPENDING',
                        action: 'See all →',
                        onAction: () => context.push('/habits'),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: _SpendingDonut(
                                  categorySpend: categorySpend),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: categorySpend.entries.map((e) {
                                final idx = categorySpend.keys
                                    .toList()
                                    .indexOf(e.key);
                                final color = AppColors.chartPalette[
                                    idx % AppColors.chartPalette.length];
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Text(
                                        '${e.key.capitalize()} ${formatRupees(e.value)}',
                                        style: AppTextStyles.caption),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── Top Habits List ───────────────────────────────────
                    if (top3.isNotEmpty) ...[
                      SectionHeader(
                        title: 'YOUR HABITS COST YOU',
                        action: 'View all →',
                        onAction: () => context.push('/habits'),
                      ),
                      const SizedBox(height: 12),
                      ...top3.map((h) =>
                          _HabitCostCard(habit: h, wage: settings.hourlyWage)),
                      const SizedBox(height: 24),
                    ],

                    // ── Future You Teaser ─────────────────────────────────
                    if (topHabit != null) ...[
                      GestureDetector(
                        onTap: () => context.go('/simulator'),
                        child: AppCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('FUTURE YOU',
                                        style: AppTextStyles.microCaps
                                            .copyWith(
                                                color: AppColors.accentLime)),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Fix ${topHabit.name} → ${formatRupees(futureValue)} in 10yr',
                                      style: AppTextStyles.h3,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  color: AppColors.textMuted, size: 16),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _moodEmoji(int mood) {
    const emojis = ['😫', '😔', '😐', '😊', '🤩'];
    return emojis[mood.clamp(1, 5) - 1];
  }
}

// ── Quick Log Nudge ────────────────────────────────────────────────────────────
// Replaces the empty insight card for new users — compact, actionable
class _QuickLogNudge extends StatelessWidget {
  final int logsCount;
  final VoidCallback onLog;
  final VoidCallback onChallenge;

  const _QuickLogNudge({
    required this.logsCount,
    required this.onLog,
    required this.onChallenge,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = 3 - logsCount;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.accentLime, width: 3),
          top: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              remaining > 0
                  ? 'Log $remaining more mood${remaining > 1 ? "s" : ""} to unlock your first insight'
                  : 'Pattern detected! Tap Insights to see your report.',
              style: AppTextStyles.bodySecondary,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onLog,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentLime,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Log now',
                style: AppTextStyles.micro
                    .copyWith(color: AppColors.background, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Spending Donut ─────────────────────────────────────────────────────────────
class _SpendingDonut extends StatelessWidget {
  final Map<String, double> categorySpend;
  const _SpendingDonut({required this.categorySpend});

  @override
  Widget build(BuildContext context) {
    if (categorySpend.isEmpty) {
      return const Center(
          child: Text('No data yet',
              style: TextStyle(color: AppColors.textMuted)));
    }

    final sections = categorySpend.entries.toList();

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 60,
        sections: List.generate(sections.length, (i) {
          final color =
              AppColors.chartPalette[i % AppColors.chartPalette.length];
          return PieChartSectionData(
            color: color,
            value: sections[i].value,
            radius: 40,
            showTitle: false,
          );
        }),
        pieTouchData: PieTouchData(enabled: false),
      ),
      swapAnimationDuration: const Duration(milliseconds: 600),
    );
  }
}

// ── Habit Cost Card ────────────────────────────────────────────────────────────
class _HabitCostCard extends StatelessWidget {
  final HabitModel habit;
  final double wage;
  const _HabitCostCard({required this.habit, required this.wage});

  @override
  Widget build(BuildContext context) {
    final workDays = wage > 0 ? habit.yearlyTotal / (wage * 8) : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(_categoryIcon(habit.category),
              style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.name, style: AppTextStyles.h3),
                Text('${formatRupees(habit.monthlyTotal)}/month',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatRupees(habit.yearlyTotal),
                  style:
                      AppTextStyles.h3.copyWith(color: AppColors.accentCoral)),
              Text('${workDays.toStringAsFixed(1)} work days',
                  style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  String _categoryIcon(String cat) {
    switch (cat) {
      case 'food':
        return '🍔';
      case 'transport':
        return '🚗';
      case 'subscriptions':
        return '📱';
      default:
        return '💸';
    }
  }
}

extension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
