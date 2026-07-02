import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../auth/role_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _iconAnimController;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      image: 'assets/images/onboarding/find_loads.jpg',
      title: 'Find Loads Quickly',
      description:
          'Connect with reliable shippers and find the best loads matching your routes and vehicle capacity across Tanzania.',
      accentColor: Color(0xFF1E3A5F),
    ),
    _OnboardingPage(
      image: 'assets/images/onboarding/track_performance.jpg',
      title: 'Track Performance',
      description:
          'Monitor your fleet\'s active trips, earnings, and vehicle metrics all in one unified dashboard.',
      accentColor: Color(0xFF1A2C4E),
    ),
    _OnboardingPage(
      image: 'assets/images/onboarding/trusted_network.jpg',
      title: 'Trusted Network',
      description:
          'Join a community of verified logistics professionals. Safety, transparency, and reliability guaranteed.',
      accentColor: Color(0xFF0D2040),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RoleSelectionScreen(),
        transitionsBuilder: (context, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _iconAnimController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.primaryColor,
        body: Stack(
          children: [
            // ── Hero section (upper 55%) ──────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.55,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) {
                  setState(() => _currentPage = i);
                  _iconAnimController
                    ..reset()
                    ..forward();
                },
                itemCount: _pages.length,
                itemBuilder: (_, i) => _HeroPanel(
                  page: _pages[i],
                  animController: _iconAnimController,
                ),
              ),
            ),

            // ── Skip button ───────────────────────────────────────────────
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _finishOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withValues(alpha: 0.7),
                      textStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('Skip'),
                  ),
                ),
              ),
            ),

            // ── Bottom card ───────────────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: size.height * 0.50,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Page content (animated switcher — NOT a second PageView)
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(0.08, 0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: anim,
                                      curve: Curves.easeOut,
                                    ),
                                  ),
                              child: child,
                            ),
                          ),
                          child: _PageContent(
                            key: ValueKey(_currentPage),
                            page: _pages[_currentPage],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Dots + Next button row
                      Row(
                        children: [
                          // Dots
                          Row(
                            children: List.generate(
                              _pages.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 6),
                                width: _currentPage == i ? 22 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: _currentPage == i
                                      ? AppTheme.secondaryContainer
                                      : AppTheme.outlineVariant,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Next button
                          _NextButton(
                            label: _currentPage == _pages.length - 1
                                ? 'Get Started'
                                : 'Next',
                            onTap: _nextPage,
                            isLast: _currentPage == _pages.length - 1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.page, required this.animController});
  final _OnboardingPage page;
  final AnimationController animController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        Image.asset(
          page.image,
          fit: BoxFit.cover,
        ),
        // Gradient Overlay for readability and premium feel
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                AppTheme.primaryColor.withValues(alpha: 0.85),
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
        // Entrance animation
        SafeArea(
          bottom: false,
          child: FadeTransition(
            opacity: animController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animController,
                curve: Curves.easeOut,
              )),
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({super.key, required this.page});
  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          page.title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          page.description,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppTheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.label,
    required this.onTap,
    required this.isLast,
  });
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isLast ? 24 : 20,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          gradient: AppTheme.accentGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: [
            BoxShadow(
              color: AppTheme.secondaryContainer.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    required this.accentColor,
  });
  final String image;
  final String title;
  final String description;
  final Color accentColor;
}
