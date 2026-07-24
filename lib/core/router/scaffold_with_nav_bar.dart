import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        height: 68,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildTabs(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTabs() {
    final bool isAdmin = navigationShell.route.branches.length == 5;
    
    if (isAdmin) {
      return [
        _buildTabItem(0, 'Home', 'assets/icons/home.svg'),
        _buildTabItem(1, 'Stock', 'assets/icons/category.svg'),
        _buildTabItem(2, 'POS', 'assets/icons/pos.svg'),
        _buildTabItem(3, 'Staff', 'assets/icons/staff.svg'),
        _buildTabItem(4, 'Report', 'assets/icons/report.svg'),
      ];
    } else {
      return [
        _buildTabItem(0, 'Home', 'assets/icons/home.svg'),
        _buildTabItem(1, 'POS', 'assets/icons/pos.svg'),
        _buildTabItem(2, 'Attendance', 'assets/icons/staff.svg'),
      ];
    }
  }

  Widget _buildTabItem(int index, String label, String iconPath) {
    final bool isSelected = navigationShell.currentIndex == index;
    const activeColor = Color(0xFF2D2F8E);
    const inactiveColor = Color(0xFF8FA0B8);
    const activeBg = Color(0xFFE8E8F5);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isSelected ? activeBg : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SvgPicture.asset(
                iconPath,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  isSelected ? activeColor : inactiveColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
