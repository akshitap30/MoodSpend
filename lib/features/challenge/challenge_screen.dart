import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';

class ChallengeScreen extends ConsumerStatefulWidget {
  const ChallengeScreen({super.key});

  @override
  ConsumerState<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends ConsumerState<ChallengeScreen>
    with SingleTickerProviderStateMixin {
  bool _celebrating = false;
  late AnimationController _confettiCtrl;
  late Animation<double> _confettiScale;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _confettiScale = Tween<double>(begin: 0.5, end: 1.1).animate(
      CurvedAnimation(parent: _confettiCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  Future<void> _complete(ChallengeModel challenge) async {
    setState(() => _celebrating = true);
    _confettiCtrl.forward();
    await ref.read(challengeProvider.notifier).complete(
          challenge.id,
          challenge.targetSaving,
        );
    ref.read(settingsProvider.notifier).incrementStreak();
    await Future.delayed(const Duration(milliseconds: 1800));
    _confettiCtrl.reset();
    if (mounted) setState(() => _celebrating = false);
  }

  void _generateChallenge() {
    final pattern = ref.read(patternProvider);
    final habits = ref.read(habitsProvider);
    if (pattern != null) {
      ref.read(challengeProvider.notifier).generateFromPattern(pattern, habits);
    } else {
      // Generate a generic challenge from top habit
      final topHabit = habits.isNotEmpty ? habits.first : null;
      if (topHabit == null) return;
      final challenge = ChallengeModel(
        id: 'ch_${DateTime.now().millisecondsSinceEpoch}',
        userId: ref.read(settingsProvider).userId,
        weekStart: _getWeekStart(),
        habitId: topHabit.id,
        habitName: topHabit.name,
        triggerDescription: 'Skip ${topHabit.name} once this week',
        replacementAction: 'Take a 10-minute walk instead',
        targetSaving: topHabit.costPerInstance,
      );
      ref.read(challengeProvider.notifier).add(challenge);
    }
  }

  static String _getWeekStart() {
    final now = DateTime.now();
    final diff = now.weekday - 1;
    final monday = now.subtract(Duration(days: diff));
    return DateFormat('yyyy-MM-dd').format(monday);
  }

  @override
  Widget build(BuildContext context) {
    final challenges = ref.watch(challengeProvider);
    final current = ref.watch(challengeProvider.notifier).currentChallenge;
    final history = challenges.where((c) => c.status != 'pending').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Weekly Challenge', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: _celebrating
          ? Center(
              child: ScaleTransition(
                scale: _confettiScale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 80)),
                    const SizedBox(height: 16),
                    Text('Challenge complete!', style: AppTextStyles.h2),
                    const SizedBox(height: 8),
                    Text('Savings added to your jar.',
                        style: AppTextStyles.bodySecondary),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Current Challenge ────────────────────────────────────
                  if (current != null) ...[
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
                          Text('THIS WEEK\'S CHALLENGE',
                              style: AppTextStyles.microCaps.copyWith(
                                color: AppColors.accentLime,
                                letterSpacing: 1.5,
                              )),
                          const SizedBox(height: 4),
                          Divider(color: AppColors.accentLime.withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text(current.triggerDescription, style: AppTextStyles.h3),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Text('→ ', style: TextStyle(color: AppColors.accentLime)),
                            Expanded(child: Text(current.replacementAction,
                                style: AppTextStyles.body)),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Text('→ ', style: TextStyle(color: AppColors.success)),
                            Text('Save ${formatRupees(current.targetSaving)} this week',
                                style: AppTextStyles.body.copyWith(color: AppColors.success)),
                          ]),
                          Divider(color: AppColors.accentLime.withValues(alpha: 0.3),
                              height: 28),
                          Row(children: [
                            Expanded(
                              child: AppButton(
                                label: 'I did it! ✓',
                                height: 44,
                                onTap: () => _complete(current),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppButton(
                                label: 'Reschedule',
                                height: 44,
                                outline: true,
                                onTap: () => ref
                                    .read(challengeProvider.notifier)
                                    .skip(current.id),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 12),
                          Text(
                            'Small wins compound. Skipping just once builds the neural pathway that makes the next time easier.',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    AppCard(
                      child: Column(
                        children: [
                          const Text('🎯', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text('No active challenge', style: AppTextStyles.h3),
                          const SizedBox(height: 8),
                          Text('Generate one based on your patterns.',
                              style: AppTextStyles.bodySecondary,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 20),
                          AppButton(
                            label: 'Generate challenge →',
                            onTap: _generateChallenge,
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (history.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    const SectionHeader(title: 'CHALLENGE HISTORY'),
                    const SizedBox(height: 12),
                    ...history.map((c) => _HistoryCard(challenge: c)),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ChallengeModel challenge;
  const _HistoryCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final icon = challenge.status == 'completed' ? '✓' : '✗';
    final color = challenge.status == 'completed'
        ? AppColors.success
        : AppColors.textMuted;

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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(icon, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge.triggerDescription,
                    style: AppTextStyles.body, overflow: TextOverflow.ellipsis),
                Text(
                  'Week of ${challenge.weekStart}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          if (challenge.status == 'completed')
            Text(
              '+${formatRupees(challenge.targetSaving)}',
              style: AppTextStyles.h3.copyWith(color: AppColors.success),
            ),
        ],
      ),
    );
  }
}
