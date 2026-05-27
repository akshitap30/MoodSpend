import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/log/log_screen.dart';
import '../../features/habits/habit_library_screen.dart';
import '../../features/habits/add_habit_screen.dart';
import '../../features/insights/insight_screen.dart';
import '../../features/simulator/simulator_screen.dart';
import '../../features/challenge/challenge_screen.dart';
import '../../features/jar/saved_jar_screen.dart';
import '../../features/swap/swap_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../providers/providers.dart';

// ─── Router Notifier ──────────────────────────────────────────────────────────
// Bridges Riverpod state → GoRouter's refreshListenable.
// The router is created ONCE; this notifier tells it when to re-check redirects.
class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  late AppSettings _settings;

  _RouterNotifier(this._ref) {
    _settings = _ref.read(settingsProvider);
    // Listen for settings changes and notify GoRouter to re-evaluate redirects
    _ref.listen<AppSettings>(settingsProvider, (_, next) {
      _settings = next;
      notifyListeners();
    });
  }

  AppSettings get settings => _settings;
}

// ─── Router Provider ──────────────────────────────────────────────────────────
// Provider does NOT watch anything — so the GoRouter is created exactly once.
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier, // re-runs redirect when settings change
    redirect: (context, state) {
      final path = state.uri.path;
      final settings = notifier.settings;

      // Splash never redirects
      if (path == '/splash') return null;

      // Not logged in → auth (except if already on auth)
      if (settings.userId.isEmpty) {
        return path == '/auth' ? null : '/auth';
      }

      // Logged in but onboarding not done → onboarding (except if already there)
      if (!settings.onboardingComplete) {
        return path == '/onboarding' ? null : '/onboarding';
      }

      // Fully set up — if still on auth or onboarding, push to home
      if (path == '/auth' || path == '/onboarding') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (_, __) => const AuthScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/log',
            name: 'log',
            builder: (_, __) => const LogScreen(),
          ),
          GoRoute(
            path: '/insights',
            name: 'insights',
            builder: (_, __) => const InsightScreen(),
          ),
          GoRoute(
            path: '/simulator',
            name: 'simulator',
            builder: (_, __) => const SimulatorScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/habits',
        name: 'habits',
        builder: (_, __) => const HabitLibraryScreen(),
      ),
      GoRoute(
        path: '/add-habit',
        name: 'add-habit',
        builder: (_, state) {
          final category = state.uri.queryParameters['category'] ?? 'other';
          return AddHabitScreen(initialCategory: category);
        },
      ),
      GoRoute(
        path: '/challenge',
        name: 'challenge',
        builder: (_, __) => const ChallengeScreen(),
      ),
      GoRoute(
        path: '/jar',
        name: 'jar',
        builder: (_, __) => const SavedJarScreen(),
      ),
      GoRoute(
        path: '/swap',
        name: 'swap',
        builder: (_, state) {
          final habitId = state.uri.queryParameters['habitId'] ?? '';
          return SwapScreen(habitId: habitId);
        },
      ),
    ],
  );

  ref.onDispose(notifier.dispose);
  return router;
});

// ─── Main Shell (bottom nav) ──────────────────────────────────────────────────
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    '/home',
    '/log',
    '/insights',
    '/simulator',
    '/profile',
  ];

  int _tabIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final idx = _tabs.indexOf(location);
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _tabIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(currentIndex: idx),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(top: BorderSide(color: Color(0xFF222222))),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  index: 0,
                  current: currentIndex,
                  path: '/home'),
              _NavItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart,
                  label: 'Insights',
                  index: 2,
                  current: currentIndex,
                  path: '/insights'),
              _NavItemCenter(current: currentIndex),
              _NavItem(
                  icon: Icons.trending_up_outlined,
                  activeIcon: Icons.trending_up,
                  label: 'Simulate',
                  index: 3,
                  current: currentIndex,
                  path: '/simulator'),
              _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  index: 4,
                  current: currentIndex,
                  path: '/profile'),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label, path;
  final int index, current;
  const _NavItem(
      {required this.icon,
      required this.activeIcon,
      required this.label,
      required this.index,
      required this.current,
      required this.path});

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => context.go(path),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(active ? activeIcon : icon,
                color: active
                    ? const Color(0xFFC8F135)
                    : const Color(0xFF444444),
                size: 22),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                  fontSize: 10,
                  color: active
                      ? const Color(0xFFC8F135)
                      : const Color(0xFF444444),
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.w400,
                )),
          ],
        ),
      ),
    );
  }
}

class _NavItemCenter extends StatelessWidget {
  final int current;
  const _NavItemCenter({required this.current});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/log'),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFC8F135),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC8F135).withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 2,
            )
          ],
        ),
        child: const Icon(Icons.add, color: Color(0xFF0A0A0A), size: 26),
      ),
    );
  }
}
