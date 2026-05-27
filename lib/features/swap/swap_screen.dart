import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';

class SwapScreen extends ConsumerWidget {
  final String habitId;
  const SwapScreen({super.key, required this.habitId});

  static const _swapData = <String, List<Map<String, dynamic>>>{
    'Swiggy/Zomato': [
      {'try': 'Cook + recipe card', 'save': 320.0, 'tip': 'Try a simple dal-chawal — 20 mins, ₹80 cost.'},
      {'try': 'Meal prep Sundays', 'save': 380.0, 'tip': 'Prep 3 days of lunch on Sunday evenings.'},
      {'try': 'Office canteen', 'save': 200.0, 'tip': 'Often 50% cheaper than delivery with no fee.'},
    ],
    'Morning coffee': [
      {'try': 'Home brew kit', 'save': 180.0, 'tip': 'A ₹800 French press pays back in 5 days.'},
      {'try': 'Green tea', 'save': 110.0, 'tip': 'Better for focus with zero crash.'},
      {'try': 'Office coffee', 'save': 100.0, 'tip': 'Usually free and perfectly decent.'},
    ],
    'Uber/Ola': [
      {'try': 'Metro + auto', 'save': 200.0, 'tip': 'Usually 40% cheaper for distances under 10km.'},
      {'try': 'Bike rental', 'save': 150.0, 'tip': 'Yulu or Rapido bike for short hops.'},
      {'try': 'Carpool (QuickRide)', 'save': 120.0, 'tip': 'Split cost with someone on the same route.'},
    ],
    'Netflix': [
      {'try': 'YouTube Premium', 'save': 350.0, 'tip': 'More content, family sharing for same price.'},
      {'try': 'Share subscription', 'save': 320.0, 'tip': 'Split Netflix with 1 friend — ₹325 each.'},
      {'try': 'Library e-books', 'save': 649.0, 'tip': 'Binge reading is free and rewiring.'},
    ],
    'Weekend drinks': [
      {'try': 'Home drinks night', 'save': 800.0, 'tip': 'Same vibe, 30% of the cost.'},
      {'try': 'Board game cafe', 'save': 600.0, 'tip': 'More fun, less money.'},
      {'try': 'Mocktail evening', 'save': 1000.0, 'tip': 'Better sleep, no regrets, saves ₹1000+.'},
    ],
  };

  static final _genericSwaps = [
    {'try': 'DIY alternative', 'save': 200.0, 'tip': 'Most habits have a cheaper homemade version.'},
    {'try': 'Wait 24 hours', 'save': 0.0, 'tip': '70% of impulse purchases disappear after sleeping on it.'},
    {'try': 'Track the trigger', 'save': 0.0, 'tip': 'Log what triggered it — awareness reduces frequency.'},
  ];

  List<Map<String, dynamic>> _getSwaps(HabitModel? habit) {
    if (habit == null) return _genericSwaps;
    return _swapData[habit.name] ?? _genericSwaps;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final habit = habits.where((h) => h.id == habitId).firstOrNull;
    final swaps = _getSwaps(habit);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Swap Suggester', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (habit != null) ...[
              Text('Instead of', style: AppTextStyles.bodySecondary),
              const SizedBox(height: 4),
              Row(children: [
                const Text('🔴 ', style: TextStyle(fontSize: 18)),
                Text(habit.name, style: AppTextStyles.h2),
              ]),
              const SizedBox(height: 4),
              Text(
                '${formatRupees(habit.costPerInstance)}/time · ${formatRupees(habit.yearlyTotal)}/year',
                style: AppTextStyles.caption.copyWith(color: AppColors.accentCoral),
              ),
              const SizedBox(height: 24),
            ],

            // Header row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(child: Text('INSTEAD OF', style: AppTextStyles.microCaps)),
                  Expanded(child: Text('TRY', style: AppTextStyles.microCaps)),
                  Text('SAVE', style: AppTextStyles.microCaps),
                ],
              ),
            ),

            const SizedBox(height: 8),

            ...swaps.map((swap) => _SwapCard(
              habitName: habit?.name ?? 'this habit',
              swap: swap,
              habitId: habitId,
              onCommit: () {
                context.push('/challenge');
              },
            )),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SwapCard extends StatelessWidget {
  final String habitName;
  final Map<String, dynamic> swap;
  final String habitId;
  final VoidCallback onCommit;

  const _SwapCard({
    required this.habitName,
    required this.swap,
    required this.habitId,
    required this.onCommit,
  });

  @override
  Widget build(BuildContext context) {
    final saving = (swap['save'] as double);
    final try_ = swap['try'] as String;
    final tip = swap['tip'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TRY INSTEAD', style: AppTextStyles.micro),
                    const SizedBox(height: 4),
                    Text(try_, style: AppTextStyles.h3.copyWith(color: AppColors.accentLime)),
                  ],
                ),
              ),
              if (saving > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('SAVE', style: AppTextStyles.micro),
                    const SizedBox(height: 4),
                    Text(
                      formatRupees(saving),
                      style: AppTextStyles.h3.copyWith(color: AppColors.success),
                    ),
                    Text('/time', style: AppTextStyles.caption),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text('💡 ', style: TextStyle(fontSize: 14)),
                Expanded(child: Text(tip, style: AppTextStyles.caption)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: AppButton(
                label: 'Commit to swap →',
                height: 40,
                onTap: onCommit,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
