import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';

class HabitLibraryScreen extends ConsumerStatefulWidget {
  const HabitLibraryScreen({super.key});

  @override
  ConsumerState<HabitLibraryScreen> createState() => _HabitLibraryScreenState();
}

class _HabitLibraryScreenState extends ConsumerState<HabitLibraryScreen> {
  String _filter = 'All';
  String _sort = 'yearly';

  static const _filters = ['All', 'Food', 'Transport', 'Subscriptions', 'Other'];
  static const _sorts = [
    ('yearly', 'Yearly cost ↓'),
    ('monthly', 'Monthly cost ↓'),
    ('name', 'Name A-Z'),
  ];

  List<HabitModel> _filtered(List<HabitModel> habits) {
    var list = habits.where((h) {
      if (_filter == 'All') return true;
      return h.category.toLowerCase() == _filter.toLowerCase();
    }).toList();

    switch (_sort) {
      case 'yearly':
        list.sort((a, b) => b.yearlyTotal.compareTo(a.yearlyTotal));
        break;
      case 'monthly':
        list.sort((a, b) => b.monthlyTotal.compareTo(a.monthlyTotal));
        break;
      case 'name':
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    final settings = ref.watch(settingsProvider);
    final logs = ref.watch(moodLogProvider);
    final filtered = _filtered(habits);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Habit Library', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          PopupMenuButton<String>(
            color: AppColors.card,
            icon: const Icon(Icons.sort, color: AppColors.textSecondary),
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (_) => _sorts.map((s) => PopupMenuItem(
              value: s.$1,
              child: Text(s.$2, style: AppTextStyles.body),
            )).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentLime,
        foregroundColor: AppColors.background,
        onPressed: () => context.push('/add-habit'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // ── Filter Bar ─────────────────────────────────────────────────
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Center(
                child: AppChip(
                  label: _filters[i],
                  selected: _filter == _filters[i],
                  onTap: () => setState(() => _filter = _filters[i]),
                ),
              ),
            ),
          ),

          // ── Habit List ─────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📭', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text('No habits yet', style: AppTextStyles.h3),
                        const SizedBox(height: 8),
                        Text('Tap + to add your first habit',
                            style: AppTextStyles.bodySecondary),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _HabitCard(
                      habit: filtered[i],
                      wage: settings.hourlyWage,
                      logs: logs,
                      onTap: () => _showDetail(context, filtered[i], logs, settings),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext ctx, HabitModel habit,
      List<MoodLogModel> logs, AppSettings settings) {
    // Mood correlation
    final habitLogs = logs.where((l) => l.habitId == habit.id).toList();
    String? moodCorrelation;
    if (habitLogs.length >= 3) {
      final lowMood = habitLogs.where((l) => l.mood <= 2).length;
      final pct = (lowMood / habitLogs.length * 100).round();
      if (pct > 40) {
        moodCorrelation =
            'You spend on this $pct% when in low mood';
      }
    }

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, sc) => SingleChildScrollView(
          controller: sc,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(_categoryIcon(habit.category),
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(habit.name, style: AppTextStyles.h2),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Cost breakdown
              AppCard(
                child: Column(
                  children: [
                    _CostRow('Per instance',
                        formatRupeesExact(habit.costPerInstance)),
                    const Divider(color: AppColors.border, height: 16),
                    _CostRow('Monthly (×${habit.frequencyPerMonth})',
                        formatRupeesExact(habit.monthlyTotal)),
                    const Divider(color: AppColors.border, height: 16),
                    _CostRow(
                      'Yearly',
                      formatRupeesExact(habit.yearlyTotal),
                      valueColor: AppColors.accentCoral,
                    ),
                    const Divider(color: AppColors.border, height: 16),
                    _CostRow(
                      'Work days lost/yr',
                      settings.hourlyWage > 0
                          ? '${(habit.yearlyTotal / (settings.hourlyWage * 8)).toStringAsFixed(1)} days'
                          : '—',
                      valueColor: AppColors.accentCoral,
                    ),
                  ],
                ),
              ),

              if (moodCorrelation != null) ...[
                const SizedBox(height: 16),
                AppCard(
                  hasAccentBorder: true,
                  child: Row(
                    children: [
                      const Text('🔍', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(moodCorrelation,
                            style: AppTextStyles.body.copyWith(
                                color: AppColors.accentLime)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              AppButton(
                label: 'See swap suggestion →',
                onTap: () {
                  Navigator.pop(ctx);
                  ctx.push('/swap?habitId=${habit.id}');
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Add to 1 Less challenge',
                outline: true,
                onTap: () {
                  Navigator.pop(ctx);
                  ctx.push('/challenge');
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Remove habit',
                outline: true,
                onTap: () {
                  ref.read(habitsProvider.notifier).remove(habit.id);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryIcon(String cat) {
    switch (cat) {
      case 'food': return '🍔';
      case 'transport': return '🚗';
      case 'subscriptions': return '📱';
      default: return '💸';
    }
  }
}

class _HabitCard extends StatelessWidget {
  final HabitModel habit;
  final double wage;
  final List<MoodLogModel> logs;
  final VoidCallback onTap;

  const _HabitCard({
    required this.habit,
    required this.wage,
    required this.logs,
    required this.onTap,
  });

  String _categoryIcon(String cat) {
    switch (cat) {
      case 'food': return '🍔';
      case 'transport': return '🚗';
      case 'subscriptions': return '📱';
      default: return '💸';
    }
  }

  @override
  Widget build(BuildContext context) {
    final workDays = wage > 0 ? habit.yearlyTotal / (wage * 8) : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(_categoryIcon(habit.category),
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.name, style: AppTextStyles.h3),
                      Text(
                        '${formatRupees(habit.costPerInstance)} × ${habit.frequencyPerMonth}/month',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatRupees(habit.yearlyTotal),
                        style: AppTextStyles.h3
                            .copyWith(color: AppColors.accentCoral)),
                    Text('${workDays.toStringAsFixed(1)} days',
                        style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Progress bar (monthly spent / monthly budget)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (habit.monthlyTotal / 5000).clamp(0.0, 1.0),
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.accentCoral),
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _CostRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySecondary),
        Text(value,
            style: AppTextStyles.h3
                .copyWith(color: valueColor ?? AppColors.textPrimary)),
      ],
    );
  }
}
