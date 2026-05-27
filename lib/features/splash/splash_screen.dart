import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _underlineCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _underlineWidth;
  late Animation<double> _fadeOut;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);

    _underlineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _underlineWidth = CurvedAnimation(
      parent: _underlineCtrl,
      curve: Curves.easeInOut,
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeOut = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _underlineCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1500));
    _fadeCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) context.go('/auth');
  }

  @override
  void dispose() {
    _underlineCtrl.dispose();
    _fadeCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0).animate(_fadeOut),
        child: Center(
          child: FadeTransition(
            opacity: _textFade,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('MoodSpend', style: AppTextStyles.hero),
                const SizedBox(height: 8),
                Text(
                  'spend less. feel more.',
                  style: AppTextStyles.caption.copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                // Animated underline
                LayoutBuilder(builder: (ctx, constraints) {
                  final textPainter = TextPainter(
                    text: TextSpan(text: 'MoodSpend', style: AppTextStyles.hero),
                    textDirection: TextDirection.ltr,
                  )..layout();
                  final textWidth = textPainter.width;
                  return AnimatedBuilder(
                    animation: _underlineWidth,
                    builder: (_, __) => Container(
                      height: 2,
                      width: textWidth * _underlineWidth.value,
                      color: AppColors.accentLime,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
