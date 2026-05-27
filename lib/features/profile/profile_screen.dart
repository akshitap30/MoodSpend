import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final habits = ref.watch(habitsProvider);
    final logs = ref.watch(moodLogProvider);
    final totalSaved = ref.watch(savedJarProvider.notifier).totalSaved;
    final pattern = ref.watch(patternProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Profile', style: AppTextStyles.h3),
        actions: [
          TextButton.icon(
            onPressed: () => _signOut(context, ref),
            icon: const Icon(Icons.logout_rounded,
                color: AppColors.accentCoral, size: 16),
            label: Text('Sign out',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.accentCoral)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── User Block ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.accentLime,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        settings.name.isNotEmpty
                            ? settings.name[0].toUpperCase()
                            : 'U',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.background,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(settings.name,
                            style: AppTextStyles.h3,
                            overflow: TextOverflow.ellipsis),
                        if (settings.memberSince.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Member since ${_formatDate(settings.memberSince)}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                        if (settings.streak > 0) ...[
                          const SizedBox(height: 3),
                          Row(children: [
                            const Text('🔥',
                                style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text('${settings.streak} day streak',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.accentCoral)),
                          ]),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Stats Summary ──────────────────────────────────────────────
            const _SectionLabel('YOUR STATS'),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(children: [
                _StatItem('Habits', '${habits.length}'),
                _StatDivider(),
                _StatItem('Mood Logs', '${logs.length}'),
                _StatDivider(),
                _StatItem('Saved', formatRupees(totalSaved)),
                _StatDivider(),
                _StatItem('Patterns', pattern != null ? '1' : '0'),
              ]),
            ),

            const SizedBox(height: 20),

            // ── Notifications ──────────────────────────────────────────────
            const _SectionLabel('NOTIFICATIONS'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ToggleTile(
                    label: 'Daily log reminder',
                    subtitle: settings.dailyReminderTime,
                    value: settings.notifyDailyReminder,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .update((s) => s.copyWith(notifyDailyReminder: v)),
                  ),
                  const _Divider(),
                  _ToggleTile(
                    label: 'Weekly insight summary',
                    value: settings.notifyWeeklySummary,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .update((s) => s.copyWith(notifyWeeklySummary: v)),
                  ),
                  const _Divider(),
                  _ToggleTile(
                    label: 'Challenge nudge',
                    value: settings.notifyChallengeNudge,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .update((s) => s.copyWith(notifyChallengeNudge: v)),
                  ),
                  const _Divider(),
                  _ToggleTile(
                    label: 'High-risk window alert',
                    subtitle: 'Notify at peak spend time',
                    value: settings.notifyPeakWindow,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .update((s) => s.copyWith(notifyPeakWindow: v)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Preferences ────────────────────────────────────────────────
            const _SectionLabel('PREFERENCES'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _EditTile(
                    label: 'Hourly wage',
                    value: '₹${settings.hourlyWage.toStringAsFixed(0)}/hr',
                    onTap: () =>
                        _editWage(context, ref, settings.hourlyWage),
                  ),
                  const _Divider(),
                  _EditTile(
                    label: 'Goal',
                    value: settings.goalName.isNotEmpty
                        ? settings.goalName
                        : 'Not set',
                    onTap: () => context.push('/onboarding'),
                  ),
                  const _Divider(),
                  const _EditTile(
                    label: 'Currency',
                    value: '₹ INR',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Data ──────────────────────────────────────────────────────
            const _SectionLabel('DATA'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ActionTile(
                    label: 'Export my data (CSV)',
                    icon: Icons.download_outlined,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Data export coming soon')),
                      );
                    },
                  ),
                  const _Divider(),
                  _ActionTile(
                    label: 'Delete all data',
                    icon: Icons.delete_outline,
                    color: AppColors.danger,
                    onTap: () => _confirmDelete(context, ref),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── About ──────────────────────────────────────────────────────
            const _SectionLabel('ABOUT'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ActionTile(
                    label: 'App version',
                    icon: Icons.info_outline,
                    trailing:
                        Text('1.0.0', style: AppTextStyles.caption),
                  ),
                  const _Divider(),
                  const _ActionTile(
                      label: 'Privacy policy',
                      icon: Icons.privacy_tip_outlined),
                  const _Divider(),
                  const _ActionTile(
                      label: 'Send feedback',
                      icon: Icons.mail_outline),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sign-out: clears ALL Hive data, resets all provider state ────────────
  Future<void> _signOut(BuildContext ctx, WidgetRef ref) async {
    // Clear every data box first
    await Future.wait([
      ref.read(habitsProvider.notifier).clearAll(),
      ref.read(moodLogProvider.notifier).clearAll(),
      ref.read(challengeProvider.notifier).clearAll(),
      ref.read(savedJarProvider.notifier).clearAll(),
    ]);
    // signOut() clears settings + resets state → router auto-redirects to /auth
    await ref.read(settingsProvider.notifier).signOut();
    if (ctx.mounted) ctx.go('/auth');
  }

  Future<void> _editWage(
      BuildContext ctx, WidgetRef ref, double current) async {
    final ctrl =
        TextEditingController(text: current.toStringAsFixed(0));
    await showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hourly wage', style: AppTextStyles.h3),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: AppTextStyles.body
                .copyWith(color: AppColors.accentLime),
            hintText: '312',
            hintStyle:
                AppTextStyles.body.copyWith(color: AppColors.textMuted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.accentLime),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTextStyles.caption),
          ),
          TextButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text);
              if (v != null) {
                ref
                    .read(settingsProvider.notifier)
                    .update((s) => s.copyWith(hourlyWage: v));
              }
              Navigator.pop(ctx);
            },
            child: Text('Save',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.accentLime)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext ctx, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete all data?', style: AppTextStyles.h3),
        content: Text(
          'This will permanently erase all your mood logs, habits, challenges and saved jar entries. This cannot be undone.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTextStyles.caption),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (!ctx.mounted) return;
    if (confirm == true) {
      await _signOut(ctx, ref);
    }
  }

  String _formatDate(String iso) {
    try {
      return DateFormat('MMM yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return '';
    }
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label,
            style: AppTextStyles.microCaps
                .copyWith(color: AppColors.textMuted, letterSpacing: 1.1)),
      );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16);
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: AppTextStyles.h3
                  .copyWith(color: AppColors.accentLime, fontSize: 18)),
          const SizedBox(height: 4),
          Text(label,
              style: AppTextStyles.micro.copyWith(fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 32,
        color: AppColors.border,
      );
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile(
      {required this.label,
      this.subtitle,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.body),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppTextStyles.caption),
              ],
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.accentLime,
          activeTrackColor: AppColors.accentLime.withAlpha(80),
        ),
      ]),
    );
  }
}

class _EditTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _EditTile({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        child: Row(children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(value,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right,
              color: AppColors.textMuted, size: 18),
        ]),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final Widget? trailing;
  const _ActionTile(
      {required this.label,
      required this.icon,
      this.color,
      this.onTap,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        child: Row(children: [
          Icon(icon, color: color ?? AppColors.textSecondary, size: 18),
          const SizedBox(width: 14),
          Expanded(
              child: Text(label,
                  style: AppTextStyles.body.copyWith(color: color))),
          trailing ??
              const Icon(Icons.chevron_right,
                  color: AppColors.textMuted, size: 18),
        ]),
      ),
    );
  }
}
