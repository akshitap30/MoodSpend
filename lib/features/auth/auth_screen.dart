import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/providers.dart';

/// Fully local auth — no server, no network calls.
/// Works offline. Perfect for a prototype.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _emailError = 'Enter a valid email');
      return;
    }
    if (password.length < 6) {
      setState(() => _passwordError = 'At least 6 characters');
      return;
    }

    setState(() => _loading = true);

    // Small delay for UX feel
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    // Generate a stable local user ID from email (no server needed)
    final userId = 'user_${email.toLowerCase().hashCode.abs()}';
    final name = email.split('@').first;

    final settings = ref.read(settingsProvider);

    ref.read(settingsProvider.notifier).update((s) => s.copyWith(
          userId: userId,
          name: name,
          memberSince: s.memberSince.isNotEmpty
              ? s.memberSince
              : DateTime.now().toIso8601String(),
        ));

    setState(() => _loading = false);

    if (settings.onboardingComplete) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Hero Image ───────────────────────────────────────────
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/auth_hero.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── App Name ─────────────────────────────────────────────
                Text('MoodSpend', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text('Track habits, build wealth',
                    style: AppTextStyles.bodySecondary),

                const SizedBox(height: 48),

                // ── Email ────────────────────────────────────────────────
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    hintText: 'Email address',
                    errorText: _emailError,
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Password ─────────────────────────────────────────────
                TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  style: AppTextStyles.body,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'Password (min 6 chars)',
                    errorText: _passwordError,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Continue Button ──────────────────────────────────────
                AppButton(
                  label: 'Continue →',
                  loading: _loading,
                  onTap: _submit,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
