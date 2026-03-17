import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/login_position.dart';
import '../providers/auth_provider.dart';

/// Full-screen login page with a gradient header, modern
/// input fields, and a primary call-to-action button.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _loadRememberMePreference();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    final authNotifier = ref.read(authProvider.notifier);

    final positions = await authNotifier.checkLoginPositions(
      username: username,
      password: password,
    );

    if (!mounted) return;
    final checkPositionState = ref.read(authProvider);
    if (checkPositionState is AuthError) {
      // Error message is already handled by ref.listen(authProvider).
      return;
    }

    if (positions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Posisi login tidak ditemukan untuk akun ini.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    LoginPosition? selectedPosition;
    if (positions.length == 1) {
      selectedPosition = positions.first;
    } else {
      selectedPosition = await _showPositionPicker(positions);
    }

    if (!mounted || selectedPosition == null) return;

    await authNotifier.login(
      username: username,
      password: password,
      positionId: selectedPosition.id,
      positionName: selectedPosition.name,
      remember: _rememberMe,
    );

    if (!mounted) return;
    final loginState = ref.read(authProvider);
    if (loginState is AuthAuthenticated) {
      await _saveRememberMePreference(username: username);
    }
  }

  Future<void> _loadRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(AppConstants.rememberMeKey) ?? false;
    final rememberedUsername =
        prefs.getString(AppConstants.rememberedUsernameKey) ?? '';

    if (!mounted) return;
    setState(() {
      _rememberMe = remember;
      if (remember && rememberedUsername.isNotEmpty) {
        _usernameCtrl.text = rememberedUsername;
      }
    });
  }

  Future<void> _saveRememberMePreference({required String username}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.rememberMeKey, _rememberMe);

    if (_rememberMe) {
      await prefs.setString(AppConstants.rememberedUsernameKey, username);
    } else {
      await prefs.remove(AppConstants.rememberedUsernameKey);
    }
  }

  Future<LoginPosition?> _showPositionPicker(
    List<LoginPosition> positions,
  ) async {
    return showModalBottomSheet<LoginPosition>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Pilih Posisi Login', style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                ...positions.map(
                  (position) => ListTile(
                    leading: const Icon(Icons.badge_rounded),
                    title: Text(position.name),
                    subtitle: Text('Position ID: ${position.id}'),
                    onTap: () => Navigator.pop(sheetContext, position),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final screenHeight = MediaQuery.of(context).size.height;

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            height: screenHeight,
            child: Column(
              children: [
                // ── Gradient Header ───────────────────
                _buildHeader(screenHeight),

                // ── Form Body ─────────────────────────
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 36),
                            _buildUsernameField(),
                            const SizedBox(height: 20),
                            _buildPasswordField(),
                            const SizedBox(height: 12),
                            _buildRememberMeAndForgotPassword(),
                            const SizedBox(height: 32),
                            _buildLoginButton(isLoading),
                            const SizedBox(height: 16),
                            _buildGuestButton(isLoading),
                            const Spacer(),
                            _buildFooter(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header with gradient + logo ───────────────────────

  Widget _buildHeader(double screenHeight) {
    return Container(
      width: double.infinity,
      height: screenHeight * 0.34,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/logo.png', height: 80, width: 80),
            const SizedBox(height: 16),
            Text(
              'HRIS \nMagna Solusi Indonesia',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Human Resource Information System',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Username ──────────────────────────────────────────

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameCtrl,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Username',
        hintText: 'Enter your username',
        prefixIcon: const Icon(
          Icons.person_outline_rounded,
          color: AppColors.accentBlue,
        ),
        floatingLabelStyle: const TextStyle(color: AppColors.darkBlue),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Username is required';
        }
        return null;
      },
    );
  }

  // ── Password ──────────────────────────────────────────

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: AppColors.accentBlue,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: AppColors.textHint,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        floatingLabelStyle: const TextStyle(color: AppColors.darkBlue),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        return null;
      },
    );
  }

  // ── Remember Me + Forgot Password ────────────────────

  Widget _buildRememberMeAndForgotPassword() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(() => _rememberMe = !_rememberMe),
            child: Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() => _rememberMe = value ?? false);
                  },
                ),
                Text(
                  'Remember me',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () => context.push(RoutePaths.forgotPassword),
          child: Text(
            'Forgot Password?',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.accentBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── Login Button ──────────────────────────────────────

  Widget _buildLoginButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : const Text('Sign In'),
      ),
    );
  }

  // ── Guest Button ──────────────────────────────────────

  Widget _buildGuestButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: isLoading
            ? null
            : () => ref.read(authProvider.notifier).loginAsGuest(),
        icon: const Icon(Icons.person_outline_rounded),
        label: const Text('Continue as Guest'),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────

  Widget _buildFooter() {
    return Text(
      '© 2026 MSI — All rights reserved',
      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textHint),
    );
  }
}
