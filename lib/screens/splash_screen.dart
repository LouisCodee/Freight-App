import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const OnboardingScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: Stack(
            children: [
              // Background grid pattern
              Positioned.fill(
                child: CustomPaint(painter: _GridPainter()),
              ),
              // Main content
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, _) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo mark
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: ScaleTransition(
                          scale: _scaleAnim,
                          child: const _LogoMark(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // App name
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnim.value),
                          child: const Text(
                            'FreightMatch',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Tagline
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnim.value),
                          child: Text(
                            'Connect. Load. Deliver.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.65),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom loading bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 48,
                child: Column(
                  children: [
                    Text(
                      'Tanzania\'s Logistics Network',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 64),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (_, _) => ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: _controller.value * 0.9,
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                            color: AppTheme.secondaryContainer,
                            minHeight: 3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        // Mid ring
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        // Core
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.secondaryContainer,
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondaryContainer.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.local_shipping_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
