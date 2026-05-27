import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';

class SavedJarScreen extends ConsumerWidget {
  const SavedJarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(savedJarProvider);
    final total = ref.watch(savedJarProvider.notifier).totalSaved;
    final settings = ref.watch(settingsProvider);
    final fillPct = (total / settings.goalAmount).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Saved Jar', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── SVG Jar ────────────────────────────────────────────────────
            Center(
              child: _AnimatedJar(fillPct: fillPct),
            ),

            const SizedBox(height: 24),

            Text(
              'You\'ve saved',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 4),
            Text(
              formatRupeesExact(total),
              style: AppTextStyles.numberLarge,
            ),
            Text(
              'by taking challenges',
              style: AppTextStyles.bodySecondary,
            ),

            const SizedBox(height: 24),

            // ── Goal Progress ──────────────────────────────────────────────
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${settings.goalName} goal', style: AppTextStyles.h3),
                      Text(
                        '${(fillPct * 100).round()}%',
                        style: AppTextStyles.h3.copyWith(color: AppColors.accentLime),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fillPct,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(AppColors.accentLime),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${formatRupeesExact(total)} of ${formatRupeesExact(settings.goalAmount)}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Invest CTA ─────────────────────────────────────────────────
            AppButton(
              label: '📈 Invest this → Groww / Zerodha',
              outline: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening investment apps...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // ── Transaction Log ────────────────────────────────────────────
            if (entries.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: SectionHeader(title: 'SAVINGS LOG'),
              ),
              const SizedBox(height: 12),
              ...entries.map((e) => _JarEntry(entry: e)),
            ] else ...[
              const SizedBox(height: 20),
              const Text('🫙', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('Complete challenges to fill your jar!',
                  style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _AnimatedJar extends StatefulWidget {
  final double fillPct;
  const _AnimatedJar({required this.fillPct});

  @override
  State<_AnimatedJar> createState() => _AnimatedJarState();
}

class _AnimatedJarState extends State<_AnimatedJar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fillAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fillAnim = Tween<double>(begin: 0, end: widget.fillPct)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_AnimatedJar old) {
    super.didUpdateWidget(old);
    if (old.fillPct != widget.fillPct) {
      _fillAnim = Tween<double>(begin: _fillAnim.value, end: widget.fillPct)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fillAnim,
      builder: (_, __) => CustomPaint(
        size: const Size(160, 220),
        painter: _JarPainter(fillPct: _fillAnim.value),
      ),
    );
  }
}

class _JarPainter extends CustomPainter {
  final double fillPct;
  _JarPainter({required this.fillPct});

  @override
  void paint(Canvas canvas, Size size) {
    final jarPaint = Paint()
      ..color = const Color(0xFF222222)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFF444444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final fillPaint = Paint()
      ..color = AppColors.accentLime.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Jar body path
    final body = Path()
      ..moveTo(size.width * 0.2, size.height * 0.12)
      ..lineTo(size.width * 0.05, size.height * 0.95)
      ..quadraticBezierTo(
          size.width * 0.05, size.height, size.width * 0.15, size.height)
      ..lineTo(size.width * 0.85, size.height)
      ..quadraticBezierTo(
          size.width * 0.95, size.height, size.width * 0.95, size.height * 0.95)
      ..lineTo(size.width * 0.8, size.height * 0.12)
      ..close();

    canvas.drawPath(body, jarPaint);

    // Fill
    if (fillPct > 0) {
      final fillTop = size.height - (size.height * 0.88 * fillPct);
      final fill = Path()
        ..moveTo(size.width * 0.2, size.height * 0.12)
        ..lineTo(size.width * 0.05, size.height * 0.95)
        ..quadraticBezierTo(
            size.width * 0.05, size.height, size.width * 0.15, size.height)
        ..lineTo(size.width * 0.85, size.height)
        ..quadraticBezierTo(
            size.width * 0.95, size.height, size.width * 0.95, size.height * 0.95)
        ..lineTo(size.width * 0.8, size.height * 0.12)
        ..close();

      // save() before clipPath so restore() can undo the clip
      canvas.save();
      canvas.clipPath(fill);

      // Wave effect
      final wavePath = Path()
        ..moveTo(0, fillTop)
        ..cubicTo(size.width * 0.25, fillTop - 8, size.width * 0.75, fillTop + 8, size.width, fillTop)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      canvas.drawPath(wavePath, fillPaint);
      canvas.restore(); // undo clip so border draws cleanly over the fill
    }
    canvas.drawPath(body, borderPaint);

    // Jar lid
    final lidRect = Rect.fromLTWH(size.width * 0.15, 0, size.width * 0.7, size.height * 0.14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(lidRect, const Radius.circular(6)),
      Paint()..color = const Color(0xFF333333),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(lidRect, const Radius.circular(6)),
      Paint()
        ..color = const Color(0xFF555555)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_JarPainter old) => old.fillPct != fillPct;
}

class _JarEntry extends StatelessWidget {
  final SavedJarEntry entry;
  const _JarEntry({required this.entry});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(entry.createdAt);
    final dateStr = date != null ? DateFormat('EEE d MMM').format(date) : '';

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
          const Text('🫙', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.note, style: AppTextStyles.body),
                Text(dateStr, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(
            '+${formatRupees(entry.amount)}',
            style: AppTextStyles.h3.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }
}
