import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
import 'package:tr_tech_solutions/core/theme/app_typography.dart';

typedef NavItem = ({IconData icon, IconData activeIcon, String label, String route});

class Sidebar extends StatelessWidget {
  final String currentRoute;
  final List<NavItem> navItems;
  final VoidCallback onSignOut;

  const Sidebar({
    super.key,
    required this.currentRoute,
    required this.navItems,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 272,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brandDeep,
            AppColors.brand,
            Color(0xFF0A4E56),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -50,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withOpacity(0.08),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 18),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.16),
                            Colors.white.withOpacity(0.06),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.18)),
                      ),
                      child: const Icon(Icons.hub_outlined, color: AppColors.primaryLight, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TR Tech',
                            style: TextStyle(
                              fontFamily: AppTypography.display,
                              fontWeight: FontWeight.w700,
                              fontSize: 19,
                              color: AppColors.textOnBrand,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            'Solutions LLP',
                            style: TextStyle(
                              fontFamily: AppTypography.body,
                              color: Color(0xFFB7D4D8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome_outlined, size: 16, color: AppColors.primaryLight),
                      SizedBox(width: 8),
                      Text(
                        'Business OS',
                        style: TextStyle(
                          color: Color(0xFFD5EBEE),
                          fontSize: 12,
                          fontFamily: AppTypography.body,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: navItems.length,
                  itemBuilder: (context, index) {
                    final item = navItems[index];
                    final isActive = currentRoute == item.route ||
                        (item.route == '/clients' && currentRoute.startsWith('/clients/'));

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white.withOpacity(0.14) : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isActive ? Colors.white.withOpacity(0.12) : Colors.transparent,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => context.go(item.route),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                              child: Row(
                                children: [
                                  Icon(
                                    isActive ? item.activeIcon : item.icon,
                                    size: 20,
                                    color: isActive
                                        ? AppColors.primaryLight
                                        : const Color(0xFFB7D4D8),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: TextStyle(
                                        color: isActive ? Colors.white : const Color(0xFFD5EBEE),
                                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                        fontSize: 14,
                                        fontFamily: AppTypography.body,
                                      ),
                                    ),
                                  ),
                                  if (isActive)
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryLight,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton.icon(
                  onPressed: onSignOut,
                  icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFD5EBEE)),
                  label: const Text(
                    'Sign out',
                    style: TextStyle(color: Color(0xFFD5EBEE), fontFamily: AppTypography.body),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
