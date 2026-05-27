import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/services/pattern_service.dart';

class InsightScreen extends ConsumerWidget {
  const InsightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(moodLogProvider);
    final pattern = ref.watch(patternProvider);

    if (logs.length < 7) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text('Insights', style: AppTextStyles.h3)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🧠', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 20),
              Text('${7 - logs.length} more log${(7 - logs.length) > 1 ? "s" : ""} until your first insight',
                  style: AppTextStyles.h2, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text('Log your mood daily to discover\nwhat drives your spending.',
                  style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: AppButton(
                  label: 'Log now →',
                  onTap: () => context.go('/log'),
                ),
              ),
              const SizedBox(height: 24),
              // Progress pills
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(7, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 28,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i < logs.length ? AppColors.accentLime : AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                )),
              ),
            ],
          ),
        ),
      );
    }

    final moodAvgs = PatternService.moodSpendAverages(logs);
    final tagAvgs = PatternService.tagSpendAverages(logs);
    final heatmap = PatternService.buildHeatmap(logs);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Pattern Report', style: AppTextStyles.h3)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1: Mood vs Spend ────────────────────────────────
            const SectionHeader(title: 'YOUR SPENDING TRIGGERS'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mood vs Average Spend', style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Text('How much you spend by mood level',
                      style: AppTextStyles.caption),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: _MoodBarChart(moodAvgs: moodAvgs),
                  ),
                  if (moodAvgs.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _insightBadge(_moodInsightText(moodAvgs)),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Section 2: Time Heatmap ─────────────────────────────────
            const SectionHeader(title: 'TIME PATTERN'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spending Heatmap', style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Text('7 days × 24 hours', style: AppTextStyles.caption),
                  const SizedBox(height: 16),
                  _HeatmapGrid(heatmap: heatmap),
                  const SizedBox(height: 8),
                  Row(children: [
                    Text('Low', style: AppTextStyles.micro),
                    const SizedBox(width: 8),
                    ...List.generate(5, (i) => Container(
                      margin: const EdgeInsets.only(right: 4),
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.accentLime.withValues(alpha: (i + 1) * 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )),
                    const SizedBox(width: 8),
                    Text('High', style: AppTextStyles.micro),
                  ]),
                  if (pattern != null) ...[
                    const SizedBox(height: 12),
                    _insightBadge(
                      'Peak window: ${_dayLabel(pattern.triggerHourStart ~/ 3)} '
                      '${pattern.triggerHourStart}:00–${pattern.triggerHourEnd}:00',
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Section 3: Tag Correlation ──────────────────────────────
            if (tagAvgs.isNotEmpty) ...[
              const SectionHeader(title: 'CONTEXT CORRELATION'),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What triggers spending?', style: AppTextStyles.h3),
                    const SizedBox(height: 16),
                    _TagBarChart(tagAvgs: tagAvgs),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Section 4: Top Pattern Hero ─────────────────────────────
            if (pattern != null) ...[
              const SectionHeader(title: 'YOUR TOP PATTERN'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentLime, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔍', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 12),
                    Text(pattern.insightText, style: AppTextStyles.body),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Replace this trigger →',
                      onTap: () => context.push('/challenge'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _insightBadge(String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.accentLime.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accentLime.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: AppTextStyles.caption.copyWith(color: AppColors.accentLime)),
    );
  }

  String _moodInsightText(Map<int, double> moodAvgs) {
    final low = [moodAvgs[1] ?? 0, moodAvgs[2] ?? 0]
        .where((v) => v > 0)
        .fold<double>(0, (a, b) => a + b) / 2;
    final high = [moodAvgs[4] ?? 0, moodAvgs[5] ?? 0]
        .where((v) => v > 0)
        .fold<double>(0, (a, b) => a + b) / 2;
    if (low > 0 && high > 0) {
      final ratio = low / high;
      return 'You spend ${ratio.toStringAsFixed(1)}× more when feeling low vs feeling great.';
    }
    return 'Keep logging to see your mood vs spend pattern.';
  }

  String _dayLabel(int idx) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[idx.clamp(0, 6)];
  }
}

// ── Mood Bar Chart ──────────────────────────────────────────────────────────
class _MoodBarChart extends StatelessWidget {
  final Map<int, double> moodAvgs;
  const _MoodBarChart({required this.moodAvgs});

  @override
  Widget build(BuildContext context) {
    const moodLabels = ['😫', '😔', '😐', '😊', '🤩'];
    final maxVal = moodAvgs.values.fold<double>(0, max);

    return BarChart(
      BarChartData(
        maxY: maxVal * 1.3,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Text(
                moodLabels[v.toInt().clamp(0, 4)],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (v, _) => Text(
                formatRupees(v),
                style: AppTextStyles.micro.copyWith(fontSize: 9),
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.border, strokeWidth: 0.5),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(5, (i) {
          final mood = i + 1;
          final val = moodAvgs[mood] ?? 0;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: val,
                color: val == maxVal ? AppColors.accentCoral : AppColors.accentLime.withValues(alpha: 0.6),
                width: 28,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }),
      ),
      swapAnimationDuration: const Duration(milliseconds: 600),
      swapAnimationCurve: Curves.easeInOut,
    );
  }
}

// ── Heatmap Grid ────────────────────────────────────────────────────────────
class _HeatmapGrid extends StatelessWidget {
  final List<List<int>> heatmap;
  const _HeatmapGrid({required this.heatmap});

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxVal = heatmap.expand((r) => r).fold<int>(0, max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(7, (day) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            children: [
              SizedBox(
                width: 14,
                child: Text(dayLabels[day], style: AppTextStyles.micro.copyWith(fontSize: 9)),
              ),
              const SizedBox(width: 4),
              ...List.generate(24, (hour) {
                final val = heatmap[day][hour];
                final opacity = maxVal > 0 ? val / maxVal : 0.0;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    height: 12,
                    decoration: BoxDecoration(
                      color: opacity > 0
                          ? AppColors.accentLime.withValues(alpha: opacity)
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}

// ── Tag Bar Chart ───────────────────────────────────────────────────────────
class _TagBarChart extends StatelessWidget {
  final Map<String, double> tagAvgs;
  const _TagBarChart({required this.tagAvgs});

  @override
  Widget build(BuildContext context) {
    final sorted = tagAvgs.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();
    final maxVal = top5.isNotEmpty ? top5.first.value : 1.0;

    return Column(
      children: top5.map((e) {
        final ratio = e.value / maxVal;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(e.key, style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: ratio,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(
                          ratio > 0.7 ? AppColors.accentCoral : AppColors.accentLime,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(formatRupees(e.value), style: AppTextStyles.caption),
            ],
          ),
        );
      }).toList(),
    );
  }
}
