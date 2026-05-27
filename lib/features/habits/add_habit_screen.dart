import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  final String initialCategory;
  const AddHabitScreen({super.key, this.initialCategory = 'other'});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _nameCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  String _category = 'food';
  double _frequency = 10;
  bool _saving = false;

  static const _categories = ['food', 'transport', 'subscriptions', 'other'];
  static const _categoryEmojis = {'food': '🍔', 'transport': '🚗', 'subscriptions': '📱', 'other': '💸'};

  @override
  void initState() {
    super.initState();
    _category = _categories.contains(widget.initialCategory)
        ? widget.initialCategory
        : 'food';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  String get _frequencyLabel {
    final f = _frequency.round();
    final perDay = f / 30;
    if (perDay < 1) return '~$f×/month';
    return '~${perDay.toStringAsFixed(1)}×/day';
  }

  double get _cost => double.tryParse(_costCtrl.text) ?? 0;
  double get _monthlyTotal => _cost * _frequency;
  double get _yearlyTotal => _monthlyTotal * 12;

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit name')),
      );
      return;
    }

    setState(() => _saving = true);

    final habit = HabitModel(
      id: const Uuid().v4(),
      userId: ref.read(settingsProvider).userId,
      name: _nameCtrl.text.trim(),
      category: _category,
      costPerInstance: _cost,
      frequencyPerMonth: _frequency.round(),
      createdAt: DateTime.now().toIso8601String(),
    );

    await ref.read(habitsProvider.notifier).add(habit);

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _nameCtrl.text.isNotEmpty && _cost > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add Custom Habit', style: AppTextStyles.h3),
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
            // ── Live Preview ───────────────────────────────────────────────
            if (hasData) ...[
              AppCard(
                hasAccentBorder: true,
                child: Row(
                  children: [
                    Text(_categoryEmojis[_category] ?? '💸',
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Habit name',
                              style: AppTextStyles.h3),
                          Text(
                            '${formatRupees(_cost)} × ${_frequency.round()}/month = ${formatRupees(_yearlyTotal)}/yr',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Name ──────────────────────────────────────────────────────
            Text('Habit name', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: AppTextStyles.body,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'e.g. Morning latte'),
            ),

            const SizedBox(height: 20),

            // ── Category ──────────────────────────────────────────────────
            Text('Category', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Row(
              children: _categories.map((cat) {
                final selected = _category == cat;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: EdgeInsets.only(right: cat != 'other' ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.accentLime.withValues(alpha: 0.1) : AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: selected ? AppColors.accentLime : AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Text(_categoryEmojis[cat] ?? '💸',
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 4),
                          Text(
                            cat == 'subscriptions' ? 'Subs' : cat.capitalize(),
                            style: AppTextStyles.micro.copyWith(
                              color: selected ? AppColors.accentLime : AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Cost ──────────────────────────────────────────────────────
            Text('Cost per instance', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            TextField(
              controller: _costCtrl,
              keyboardType: TextInputType.number,
              style: AppTextStyles.body,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'e.g. 250',
                prefixText: '₹ ',
              ),
            ),

            const SizedBox(height: 20),

            // ── Frequency ─────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Frequency', style: AppTextStyles.h3),
                Text(_frequencyLabel,
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
                value: _frequency,
                min: 1,
                max: 90,
                divisions: 89,
                onChanged: (v) => setState(() => _frequency = v),
              ),
            ),

            if (_cost > 0 && _frequency > 0) ...[
              const SizedBox(height: 16),
              AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatCol('Monthly', formatRupees(_monthlyTotal)),
                    Container(width: 1, height: 30, color: AppColors.border),
                    _StatCol('Yearly', formatRupees(_yearlyTotal)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            AppButton(
              label: 'Add habit →',
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

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  const _StatCol(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.h3.copyWith(color: AppColors.accentCoral)),
      ],
    );
  }
}

extension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
