import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  bool _sent = false;
  late AnimationController _checkController;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  void _handleSend() {
    setState(() => _sent = true);
    _checkController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Column(
          children: [
            // Custom navy header with envelope illustration
            Container(
              decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSm,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: _sent
                            ? ScaleTransition(
                                scale: _checkScale,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.mark_email_read_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.mail_outline_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          _sent ? 'Check Your Email' : 'Forgot Password?',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _sent
                              ? 'We\'ve sent a password reset link to your email address. Please check your inbox.'
                              : 'Enter your email and we\'ll send you a link to reset your password.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                child: _sent
                    ? _SuccessBody(onBack: () => Navigator.of(context).pop())
                    : _FormBody(onSend: _handleSend),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({required this.onSend});
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.email_outlined),
            hintText: 'you@example.com',
          ),
        ),
        const SizedBox(height: 32),
        _GradientButton(label: 'Send Reset Link', onTap: onSend),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Back to Log In',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.statusGreenContainer,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppTheme.statusGreen,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Didn\'t receive the email? Check your spam folder or try a different email address.',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppTheme.statusGreen,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _GradientButton(label: 'Back to Log In', onTap: onBack),
        const SizedBox(height: 12),
        TextButton(onPressed: () {}, child: const Text('Resend Email')),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: AppTheme.accentGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppTheme.secondaryContainer.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
