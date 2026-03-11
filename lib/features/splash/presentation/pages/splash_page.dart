import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Animated splash screen shown on app launch.
///
/// Checks the user's authentication status and redirects
/// to either the login page or the main shell.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack));

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _animCtrl.forward();
    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    await Future<void>.delayed(AppConstants.splashDuration);
    if (!mounted) return;
    ref.read(authProvider.notifier).checkAuthStatus();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // ── Animated Logo ─────────────────────
              ScaleTransition(
                scale: _scaleAnim,
                child: Image.asset(
                  'assets/icons/logo.png',
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 28),

              // ── App Name ──────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: Text(
                  'HRIS MSI',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.white,
                    letterSpacing: 4,
                    fontSize: 32,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              FadeTransition(
                opacity: _fadeAnim,
                child: Text(
                  'Human Resource Information System',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
              const Spacer(flex: 3),

              // ── Loading indicator ─────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              FadeTransition(
                opacity: _fadeAnim,
                child: Text(
                  'v${AppConstants.appVersion}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
