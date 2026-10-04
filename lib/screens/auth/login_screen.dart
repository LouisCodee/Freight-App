import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_header.dart';
import 'forgot_password_screen.dart';
import 'role_selection_screen.dart';
import 'google_role_selection_screen.dart';
import '../home/truck_owner_home_screen.dart';
import '../shipper/cargo_shipper_home_screen.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              title: 'Welcome Back',
              subtitle: 'Log in to your FreightMatch account.',
              showLogo: true,
              showBack: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Fields ────────────────────────────────────────────
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
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    // Forgot password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                        ),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryContainer,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── CTA ─────────────────────────────────────────────
                    _isEmailLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _GradientButton(
                            label: 'Log In',
                            onTap: () async {
                              setState(() => _isEmailLoading = true);
                              try {
                                final user = await AuthService().loginUser(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                );
                                if (!context.mounted) return;
                                setState(() => _isEmailLoading = false);
                                if (user != null) {
                                  if (user.role == 'Shipper') {
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
                                setState(() => _isEmailLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                          ),
                    const SizedBox(height: 28),

                    // ── Divider ───────────────────────────────────────────
                    const _OrDivider(),
                    const SizedBox(height: 20),

                    // ── Social login ──────────────────────────────────────
                    _isGoogleLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _SocialButton(
                      label: 'Continue with Google',
                      icon: Icons.g_mobiledata_rounded,
                      onTap: () async {
                        setState(() => _isGoogleLoading = true);
                        try {
                          final result =
                              await AuthService().signInWithGoogle();
                          if (!context.mounted) return;
                          setState(() => _isGoogleLoading = false);
                          if (result == null) return; // user cancelled

                          if (result.isNewUser) {
                            // First-time Google user — collect role.
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => GoogleRoleSelectionScreen(
                                  firebaseUid: result.firebaseUid,
                                  displayName: result.displayName,
                                  email: result.email,
                                ),
                              ),
                            );
                          } else {
                            // Returning user — route by saved role.
                            final role = result.user?.role;
                            if (role == 'Shipper') {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const CargoShipperHomeScreen(),
                                ),
                              );
                            } else {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const TruckOwnerHomeScreen(),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          setState(() => _isGoogleLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 32),

                    // ── Register link ─────────────────────────────────────
                    Center(
                      child: RichText(
                        text: WidgetSpan(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const RoleSelectionScreen(),
                                      ),
                                    ),
                                child: const Text('Sign Up'),
                              ),
                            ],
                          ),
                        ),
                      ),
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.outlineVariant)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.outlineVariant, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.onSurface, size: 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurface,
              ),
            ),
          ],
        ),
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
