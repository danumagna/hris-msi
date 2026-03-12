import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Forgot-password page.
///
/// Consists of three steps:
/// 1. Enter email / username
/// 2. Enter OTP verification code
/// 3. Set new password
///
/// Currently UI-only; actual API calls will be wired later.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  final _emailFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _newPasswordFormKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _otpCtrls = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  /// 0 = email, 1 = OTP, 2 = new password
  int _currentStep = 0;

  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Step transitions ──────────────────────────────────

  void _goToStep(int step) {
    _animCtrl.reset();
    setState(() => _currentStep = step);
    _animCtrl.forward();
  }

  void _handleSendOtp() {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: call send-OTP use-case
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _goToStep(1);
    });
  }

  void _handleVerifyOtp() {
    if (!_otpFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: call verify-OTP use-case
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _goToStep(2);
    });
  }

  void _handleResetPassword() {
    if (!_newPasswordFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: call reset-password use-case
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Password Changed!',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your password has been changed\nsuccessfully. Please login with\nyour new password.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  context.pop(); // go back to login
                },
                child: const Text('Back to Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            height: screenHeight,
            child: Column(
              children: [
                _buildHeader(screenHeight),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: switch (_currentStep) {
                        0 => _buildEmailStep(),
                        1 => _buildOtpStep(),
                        2 => _buildNewPasswordStep(),
                        _ => const SizedBox.shrink(),
                      },
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

  // ── Header ────────────────────────────────────────────

  Widget _buildHeader(double screenHeight) {
    final stepTitles = ['Forgot Password', 'Verification', 'New Password'];
    final stepSubtitles = [
      'Enter your email address to receive\na verification code',
      'We have sent a verification code\nto your email address',
      'Create a new password for\nyour account',
    ];

    return Container(
      width: double.infinity,
      height: screenHeight * 0.35,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Back button
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: IconButton(
                  onPressed: () {
                    if (_currentStep > 0) {
                      _goToStep(_currentStep - 1);
                    } else {
                      context.pop();
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                switch (_currentStep) {
                  0 => Icons.lock_reset_rounded,
                  1 => Icons.verified_user_outlined,
                  2 => Icons.password_rounded,
                  _ => Icons.lock_reset_rounded,
                },
                color: AppColors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              stepTitles[_currentStep],
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stepSubtitles[_currentStep],
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 16),
            // Step indicator
            _buildStepIndicator(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isActive = i <= _currentStep;
        return Container(
          width: isActive ? 28 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.white
                : AppColors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ── Step 1: Email ─────────────────────────────────────

  Widget _buildEmailStep() {
    return Form(
      key: _emailFormKey,
      child: Column(
        children: [
          const SizedBox(height: 36),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSendOtp(),
            decoration: const InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your registered email',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: AppColors.accentBlue,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          _buildPrimaryButton(
            label: 'Send Verification Code',
            onPressed: _handleSendOtp,
          ),
          const Spacer(),
          _buildBackToLogin(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Step 2: OTP ───────────────────────────────────────

  Widget _buildOtpStep() {
    return Form(
      key: _otpFormKey,
      child: Column(
        children: [
          const SizedBox(height: 36),
          // Masked email display
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.bodyMedium,
              children: [
                const TextSpan(text: 'Code sent to '),
                TextSpan(
                  text: _maskEmail(_emailCtrl.text.trim()),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // OTP fields
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              return Container(
                width: 46,
                height: 54,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: TextFormField(
                  controller: _otpCtrls[i],
                  focusNode: _otpFocusNodes[i],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w700,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && i < 5) {
                      _otpFocusNodes[i + 1].requestFocus();
                    } else if (value.isEmpty && i > 0) {
                      _otpFocusNodes[i - 1].requestFocus();
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return '';
                    return null;
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          // Resend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Didn't receive the code? ", style: AppTextStyles.bodySmall),
              TextButton(
                onPressed: () {
                  // TODO: resend OTP
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Resend',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildPrimaryButton(
            label: 'Verify Code',
            onPressed: _handleVerifyOtp,
          ),
          const Spacer(),
          _buildBackToLogin(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Step 3: New Password ──────────────────────────────

  Widget _buildNewPasswordStep() {
    return Form(
      key: _newPasswordFormKey,
      child: Column(
        children: [
          const SizedBox(height: 36),
          TextFormField(
            controller: _newPasswordCtrl,
            obscureText: _obscureNewPassword,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'New Password',
              hintText: 'Enter your new password',
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.accentBlue,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppColors.textHint,
                ),
                onPressed: () =>
                    setState(() => _obscureNewPassword = !_obscureNewPassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordCtrl,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleResetPassword(),
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter your new password',
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.accentBlue,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppColors.textHint,
                ),
                onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _newPasswordCtrl.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          // Password requirements hint
          _buildPasswordHints(),
          const SizedBox(height: 32),
          _buildPrimaryButton(
            label: 'Reset Password',
            onPressed: _handleResetPassword,
          ),
          const Spacer(),
          _buildBackToLogin(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPasswordHints() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password must contain:',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          _buildHintRow('At least 8 characters'),
          _buildHintRow('Upper & lowercase letters'),
          _buildHintRow('At least one number'),
        ],
      ),
    );
  }

  Widget _buildHintRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 14,
            color: AppColors.accentBlue,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared Widgets ────────────────────────────────────

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Text(label),
      ),
    );
  }

  Widget _buildBackToLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Remember your password? ', style: AppTextStyles.bodySmall),
        TextButton(
          onPressed: () => context.pop(),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Sign In',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.accentBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return email;
    final visible = name.substring(0, 2);
    return '$visible${'*' * (name.length - 2)}@$domain';
  }
}
