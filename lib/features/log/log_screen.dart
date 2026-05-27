import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';

class LogScreen extends ConsumerStatefulWidget {
  const LogScreen({super.key});

  @override
  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen>
    with SingleTickerProviderStateMixin {
  int _selectedMood = 0; // 0 = not selected, 1-5
  double _energy = 5;
  final Set<String> _selectedTags = {};
  bool _didSpend = false;
  String? _selectedHabitId;
  double _amount = 0;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _saving = false;
  bool _showCelebration = false;
  late AnimationController _celebrationCtrl;
  late Animation<double> _celebrationScale;

  static const _moodEmojis = ['😫', '😔', '😐', '😊', '🤩'];
  static const _moodLabels = ['Very low', 'Low', 'Neutral', 'Good', 'Great'];
  static const _contextTags = [
    'Stressed', 'Bored', 'Lonely', 'Celebratory', 'Tired',
    'Anxious', 'Productive', 'Social', 'Hungry', 'Procrastinating',
  ];

  @override
  void initState() {
    super.initState();
    _celebrationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _celebrationScale = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _celebrationCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _celebrationCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedMood == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your mood first')),
      );
      return;
    }

    setState(() => _saving = true);

    final now = DateTime.now();
    final log = MoodLogModel(
      id: const Uuid().v4(),
      userId: ref.read(settingsProvider).userId,
      timestamp: now.toIso8601String(),
      mood: _selectedMood,
      energy: _energy.round(),
      contextTags: _selectedTags.toList(),
      habitId: _didSpend ? _selectedHabitId : null,
      amount: _didSpend ? (_amount > 0 ? _amount : null) : null,
      note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
      hourOfDay: now.hour,
      dayOfWeek: now.weekday - 1,
    );

    await ref.read(moodLogProvider.notifier).addLog(log);
    ref.read(settingsProvider.notifier).incrementStreak();

    setState(() {
      _saving = false;
      _showCelebration = true;
    });

    _celebrationCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    final now = DateTime.now();
    final timeLabel =
        'Logging for ${DateFormat('h:mm a').format(now)} · ${DateFormat('EEEE').format(now)}';

    if (_showCelebration) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: ScaleTransition(
            scale: _celebrationScale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('✅', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 16),
                Text('Log saved!', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text('Keep it up 🔥', style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Log Mood + Habit', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Timestamp ────────────────────────────────────────────────
            Text(timeLabel, style: AppTextStyles.caption.copyWith(color: AppColors.accentLime)),

            const SizedBox(height: 24),

            // ── Mood Selector ─────────────────────────────────────────────
            Text('How are you feeling?', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (i) {
                final mood = i + 1;
                final selected = _selectedMood == mood;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = mood),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.elasticOut,
                    transform: Matrix4.diagonal3Values(
                        selected ? 1.2 : 1.0,
                        selected ? 1.2 : 1.0,
                        1.0),
                    transformAlignment: Alignment.center,
                    decoration: selected
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accentLime, width: 2),
                          )
                        : null,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Text(_moodEmojis[i], style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 4),
                        Text(
                          _moodLabels[i],
                          style: AppTextStyles.micro.copyWith(
                            color: selected ? AppColors.accentLime : AppColors.textMuted,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 28),

            // ── Energy Slider ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Energy level', style: AppTextStyles.h3),
                Text('${_energy.round()}/10',
                    style: AppTextStyles.h3.copyWith(color: AppColors.accentLime)),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              ),
              child: Slider(
                value: _energy,
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (v) => setState(() => _energy = v),
              ),
            ),

            const SizedBox(height: 24),

            // ── Context Tags ───────────────────────────────────────────────
            Text('What\'s the context?', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _contextTags.map((tag) => AppChip(
                label: tag,
                selected: _selectedTags.contains(tag),
                onTap: () => setState(() {
                  if (_selectedTags.contains(tag)) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                }),
              )).toList(),
            ),

            const SizedBox(height: 28),

            // ── Did You Spend Toggle ───────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Did you spend on a habit?', style: AppTextStyles.h3),
                Switch(
                  value: _didSpend,
                  onChanged: (v) => setState(() => _didSpend = v),
                ),
              ],
            ),

            if (_didSpend) ...[
              const SizedBox(height: 16),
              // Habit chips
              if (habits.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...habits.map((h) => AppChip(
                      label: h.name,
                      selected: _selectedHabitId == h.id,
                      onTap: () => setState(() {
                        _selectedHabitId = h.id;
                        _amount = h.costPerInstance;
                        _amountCtrl.text = h.costPerInstance.toStringAsFixed(0);
                      }),
                    )),
                    AppChip(
                      label: 'Something else',
                      selected: _selectedHabitId == 'other',
                      onTap: () => setState(() => _selectedHabitId = 'other'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              // Amount input
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                style: AppTextStyles.body,
                onChanged: (v) => _amount = double.tryParse(v) ?? 0,
                decoration: const InputDecoration(
                  hintText: 'Amount spent',
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(height: 12),
              // Note
              TextField(
                controller: _noteCtrl,
                style: AppTextStyles.body,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'What triggered this? (optional)',
                ),
              ),
            ],

            const SizedBox(height: 32),

            AppButton(
              label: 'Save log →',
              loading: _saving,
              onTap: _submit,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
