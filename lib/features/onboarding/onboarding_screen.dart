import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  String _selectedGoal = '';
  final _wageCtrl = TextEditingController();
  final _customGoalCtrl = TextEditingController();
  final _customAmountCtrl = TextEditingController();
  final Set<String> _selectedHabits = {};

  static const _goals = [
    (id: 'vacation', emoji: '🏖', label: 'Vacation fund', amount: 50000.0),
    (id: 'house', emoji: '🏠', label: 'House down payment', amount: 500000.0),
    (id: 'investment', emoji: '📈', label: 'Investment / SIP', amount: 100000.0),
    (id: 'vehicle', emoji: '🚗', label: 'Big purchase (bike/car)', amount: 150000.0),
    (id: 'emergency', emoji: '🆘', label: 'Emergency fund', amount: 100000.0),
    (id: 'custom', emoji: '✏️', label: 'Custom goal', amount: 0.0),
  ];

  static const _prebuiltHabits = [
    'Morning coffee', 'Uber/Ola', 'Swiggy/Zomato', 'Netflix',
    'Spotify', 'Amazon impulse', 'Cigarettes', 'Energy drinks',
    'Office canteen', 'Weekend drinks', 'Movie tickets', 'Online shopping',
  ];

  double get _wage => double.tryParse(_wageCtrl.text) ?? 0;
  double get _wagePerDay => _wage * 8;
  double get _wagePerMonth => _wage * 160;

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _complete();
    }
  }

  void _complete() {
    try {
      final settings = ref.read(settingsProvider);
      
      // Seed habits first
      ref.read(habitsProvider.notifier).seedDefaults(
          settings.userId, _selectedHabits.toList());

      final goal = _goals.firstWhere((g) => g.id == _selectedGoal,
          orElse: () => _goals.first);

      // Set onboardingComplete which triggers the router redirect
      ref.read(settingsProvider.notifier).update((s) => s.copyWith(
            hourlyWage: _wage > 0 ? _wage : 312,
            goalType: _selectedGoal,
            goalAmount: _selectedGoal == 'custom' ? (double.tryParse(_customAmountCtrl.text) ?? 0) : goal.amount,
            goalName: _selectedGoal == 'custom' ? _customGoalCtrl.text : goal.label,
            onboardingComplete: true,
          ));
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            _ProgressBar(step: _step),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _step == 0
                    ? _Step1Goal(
                        key: const ValueKey(0),
                        selectedGoal: _selectedGoal,
                        customGoalCtrl: _customGoalCtrl,
                        customAmountCtrl: _customAmountCtrl,
                        onSelect: (id) => setState(() => _selectedGoal = id),
                      )
                    : _step == 1
                        ? _Step2Wage(
                            key: const ValueKey(1),
                            wageCtrl: _wageCtrl,
                            wagePerDay: _wagePerDay,
                            wagePerMonth: _wagePerMonth,
                          )
                        : _Step3Habits(
                            key: const ValueKey(2),
                            selected: _selectedHabits,
                            habits: _prebuiltHabits,
                            onToggle: (h) => setState(() {
                              if (_selectedHabits.contains(h)) {
                                _selectedHabits.remove(h);
                              } else {
                                _selectedHabits.add(h);
                              }
                            }),
                          ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: AppButton(
                label: _step == 2 ? 'Let\'s go →' : 'Continue →',
                onTap: _step == 0 && _selectedGoal.isEmpty ? null : _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int step;
  const _ProgressBar({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: List.generate(3, (i) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
            height: 3,
            decoration: BoxDecoration(
              color: i <= step ? AppColors.accentLime : AppColors.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        )),
      ),
    );
  }
}

// ── Step 1: Goal Selection ──────────────────────────────────────────────────
class _Step1Goal extends StatelessWidget {
  final String selectedGoal;
  final TextEditingController customGoalCtrl;
  final TextEditingController customAmountCtrl;
  final ValueChanged<String> onSelect;

  const _Step1Goal({
    super.key,
    required this.selectedGoal,
    required this.customGoalCtrl,
    required this.customAmountCtrl,
    required this.onSelect,
  });

  static const _goals = [
    (id: 'vacation', emoji: '🏖', label: 'Vacation fund'),
    (id: 'house', emoji: '🏠', label: 'House down payment'),
    (id: 'investment', emoji: '📈', label: 'Investment / SIP'),
    (id: 'vehicle', emoji: '🚗', label: 'Big purchase (bike/car)'),
    (id: 'emergency', emoji: '🆘', label: 'Emergency fund'),
    (id: 'custom', emoji: '✏️', label: 'Custom goal'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('What are you working toward?', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text('We\'ll track your habits against this', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 32),
          ...List.generate(_goals.length, (i) {
            final g = _goals[i];
            final selected = selectedGoal == g.id;
            return GestureDetector(
              onTap: () => onSelect(g.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accentLime.withValues(alpha: 0.08) : AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppColors.accentLime : AppColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(g.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 16),
                    Text(g.label,
                        style: AppTextStyles.h3.copyWith(
                          color: selected ? AppColors.accentLime : AppColors.textPrimary,
                        )),
                    const Spacer(),
                    if (selected)
                      const Icon(Icons.check_circle, color: AppColors.accentLime, size: 20),
                  ],
                ),
              ),
            );
          }),
          if (selectedGoal == 'custom') ...[
            const SizedBox(height: 8),
            TextField(
              controller: customGoalCtrl,
              style: AppTextStyles.body,
              decoration: const InputDecoration(hintText: 'Goal name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: customAmountCtrl,
              keyboardType: TextInputType.number,
              style: AppTextStyles.body,
              decoration: const InputDecoration(hintText: '₹ Target amount', prefixText: '₹ '),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Step 2: Hourly Wage ──────────────────────────────────────────────────────
class _Step2Wage extends StatelessWidget {
  final TextEditingController wageCtrl;
  final double wagePerDay;
  final double wagePerMonth;

  const _Step2Wage({
    super.key,
    required this.wageCtrl,
    required this.wagePerDay,
    required this.wagePerMonth,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('How much do you earn\nper hour?', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text('We use this to show habits as work time, not just money',
              style: AppTextStyles.bodySecondary),
          const SizedBox(height: 32),
          TextField(
            controller: wageCtrl,
            keyboardType: TextInputType.number,
            style: AppTextStyles.h2,
            decoration: const InputDecoration(
              prefixText: '₹ ',
              hintText: 'e.g. 312',
            ),
          ),
          const SizedBox(height: 8),
          Text('Not sure? Monthly salary ÷ 160 working hours',
              style: AppTextStyles.caption),
          if (wagePerDay > 0) ...[
            const SizedBox(height: 24),
            AppCard(
              hasAccentBorder: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    Text('Per day', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Text('₹${wagePerDay.toStringAsFixed(0)}',
                        style: AppTextStyles.h2.copyWith(color: AppColors.accentLime)),
                  ]),
                  Container(width: 1, height: 40, color: AppColors.border),
                  Column(children: [
                    Text('Per month', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Text('₹${wagePerMonth.toStringAsFixed(0)}',
                        style: AppTextStyles.h2.copyWith(color: AppColors.accentLime)),
                  ]),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Step 3: Habit Selection ──────────────────────────────────────────────────
class _Step3Habits extends StatelessWidget {
  final Set<String> selected;
  final List<String> habits;
  final ValueChanged<String> onToggle;

  const _Step3Habits({
    super.key,
    required this.selected,
    required this.habits,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('What do you spend on\nwithout thinking?', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text('Pick all that apply — you can add more anytime',
              style: AppTextStyles.bodySecondary),
          const SizedBox(height: 32),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: habits.map((h) => AppChip(
              label: h,
              selected: selected.contains(h),
              onTap: () => onToggle(h),
            )).toList(),
          ),
          const SizedBox(height: 24),
          if (selected.isEmpty)
            Text('Select at least one habit to get started',
                style: AppTextStyles.caption.copyWith(color: AppColors.accentCoral)),
        ],
      ),
    );
  }
}
