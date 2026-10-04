import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../home/truck_owner_home_screen.dart';
import '../shipper/cargo_shipper_home_screen.dart';

/// Shown when a brand-new Google user has authenticated but has no Firestore
/// profile yet. They pick their role here, and we persist the document.
class GoogleRoleSelectionScreen extends StatefulWidget {
  final String firebaseUid;
  final String displayName;
  final String email;

  const GoogleRoleSelectionScreen({
    super.key,
    required this.firebaseUid,
    required this.displayName,
    required this.email,
  });

  @override
  State<GoogleRoleSelectionScreen> createState() =>
      _GoogleRoleSelectionScreenState();
}

class _GoogleRoleSelectionScreenState
    extends State<GoogleRoleSelectionScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  Future<void> _confirm() async {
    if (_selectedRole == null) return;
    setState(() => _isLoading = true);
    try {
      await AuthService().saveGoogleUserProfile(
        uid: widget.firebaseUid,
        name: widget.displayName,
        email: widget.email,
        role: _selectedRole!,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (_selectedRole == 'Shipper') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CargoShipperHomeScreen()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const TruckOwnerHomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ─────────────────────────────────────────────
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Welcome, ${widget.displayName.split(' ').first}! 👋',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'One last step — how will you use FreightMatch?',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.75),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ── Role cards ─────────────────────────────────────────
                  _RoleCard(
                    role: 'Shipper',
                    title: 'I need to ship cargo',
                    subtitle:
                        'Find & book reliable trucks across Tanzania for your goods.',
                    icon: Icons.inventory_2_rounded,
                    selected: _selectedRole == 'Shipper',
                    onTap: () => setState(() => _selectedRole = 'Shipper'),
                  ),
                  const SizedBox(height: 16),
                  _RoleCard(
                    role: 'Truck Owner',
                    title: 'I own trucks',
                    subtitle:
                        'List your trucks, accept bookings, and earn on your schedule.',
                    icon: Icons.local_shipping_rounded,
                    selected: _selectedRole == 'Truck Owner',
                    onTap: () =>
                        setState(() => _selectedRole = 'Truck Owner'),
                  ),

                  const Spacer(),

                  // ── CTA ────────────────────────────────────────────────
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _selectedRole != null ? 1.0 : 0.4,
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : GestureDetector(
                            onTap: _selectedRole != null ? _confirm : null,
                            child: Container(
                              width: double.infinity,
                              height: 54,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMd),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Get Started',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryColor,
                                  ),
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
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String role;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.25),
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primaryColor.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 26,
                color: selected ? AppTheme.primaryColor : Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: selected ? AppTheme.onSurface : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      height: 1.4,
                      color: selected
                          ? AppTheme.onSurfaceVariant
                          : Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppTheme.secondaryContainer : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppTheme.secondaryContainer
                      : Colors.white.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
