import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_header.dart';
import 'login_screen.dart';
import '../home/truck_owner_home_screen.dart';
import '../shipper/cargo_shipper_home_screen.dart';
import '../../services/auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  final String role;
  const RegistrationScreen({super.key, required this.role});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  double _passwordStrength = 0;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    double strength = 0;
    if (value.length >= 8) strength += 0.33;
    if (value.contains(RegExp(r'[A-Z]'))) strength += 0.33;
    if (value.contains(RegExp(r'[0-9!@#\$&*]'))) strength += 0.34;
    setState(() => _passwordStrength = strength);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Column(
          children: [
            AuthHeader(
              title: 'Create Account',
              subtitle: 'Join FreightMatch and grow your logistics business.',
              badgeLabel: widget.role,
              showBack: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Section: Personal Info ────────────────────────────
                    _SectionLabel(label: 'Personal Information'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full Name / Company Name',
                        prefixIcon: Icon(Icons.business_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: '+255 7XX XXX XXX',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Section: Security ─────────────────────────────────
                    _SectionLabel(label: 'Account Security'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onChanged: _onPasswordChanged,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _PasswordStrengthBar(strength: _passwordStrength),
                    const SizedBox(height: 12),
                    TextFormField(
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () =>
                              setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Terms checkbox ────────────────────────────────────
                    const _TermsRow(),
                    const SizedBox(height: 24),

                    // ── CTA ───────────────────────────────────────────────
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _GradientButton(
                            label: 'Create Account',
                            onTap: () async {
                              setState(() => _isLoading = true);
                              try {
                                final user = await AuthService().registerUser(
                                  name: _nameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  phone: _phoneController.text.trim(),
                                  password: _passwordController.text,
                                  role: widget.role,
                                );
                                if (!context.mounted) return;
                                setState(() => _isLoading = false);
                                if (user != null) {
                                  if (widget.role == 'Shipper') {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (_) => const CargoShipperHomeScreen()),
                                    );
                                  } else {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (_) => const TruckOwnerHomeScreen()),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                setState(() => _isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                          ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          ),
                          child: const Text('Log In'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppTheme.secondaryContainer,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurfaceVariant,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.strength});
  final double strength;

  Color get _color {
    if (strength < 0.34) return AppTheme.statusRed;
    if (strength < 0.67) return AppTheme.statusAmber;
    return AppTheme.statusGreen;
  }

  String get _label {
    if (strength == 0) return '';
    if (strength < 0.34) return 'Weak';
    if (strength < 0.67) return 'Fair';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    if (strength == 0) return const SizedBox.shrink();
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: strength,
              backgroundColor: AppTheme.surfaceContainer,
              color: _color,
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _color,
          ),
        ),
      ],
    );
  }
}

class _TermsRow extends StatefulWidget {
  const _TermsRow();

  @override
  State<_TermsRow> createState() => _TermsRowState();
}

class _TermsRowState extends State<_TermsRow> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _agreed = !_agreed),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _agreed ? AppTheme.secondaryContainer : Colors.transparent,
              border: Border.all(
                color: _agreed
                    ? AppTheme.secondaryContainer
                    : AppTheme.outlineVariant,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _agreed
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppTheme.onSurfaceVariant,
                  height: 1.5,
                ),
                children: [
                  TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppTheme.secondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppTheme.secondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
