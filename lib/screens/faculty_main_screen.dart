import 'package:flutter/material.dart';
import 'package:psg_app/screens/faculty_dashboard_screen.dart';
import 'package:psg_app/screens/faculty_classes_screen.dart';
import 'package:psg_app/screens/faculty_timetable_screen.dart';
import 'package:psg_app/screens/faculty_directory_screen.dart';
import 'package:psg_app/screens/more_screen.dart';
import 'package:psg_app/utils/ui_helpers.dart';

class FacultyMainScreen extends StatefulWidget {
  const FacultyMainScreen({super.key});

  @override
  State<FacultyMainScreen> createState() => _FacultyMainScreenState();
}

class _FacultyMainScreenState extends State<FacultyMainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    FacultyDashboardScreen(onTabSelect: _onItemTapped),
    const FacultyClassesScreen(isEmbedded: true),
    const FacultyTimetableScreen(isEmbedded: true),
    const FacultyDirectoryScreen(role: 'faculty', isEmbedded: true),
    const MoreScreen(isEmbedded: true),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2E63EB),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              activeIcon: Icon(Icons.people_alt),
              label: 'Classes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Timetable',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Faculty',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
