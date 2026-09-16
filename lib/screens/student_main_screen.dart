import 'package:flutter/material.dart';
import 'package:psg_app/screens/student_dashboard_screen.dart';
import 'package:psg_app/screens/student_timetable_screen.dart';
import 'package:psg_app/screens/student_attendance_screen.dart';
import 'package:psg_app/screens/faculty_directory_screen.dart';
import 'package:psg_app/screens/more_screen.dart';
import 'package:psg_app/utils/ui_helpers.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    StudentDashboardScreen(onTabSelect: _onItemTapped),
    const StudentTimetableScreen(isEmbedded: true),
    const StudentAttendanceScreen(isEmbedded: true),
    const FacultyDirectoryScreen(role: 'student', isEmbedded: true),
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
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Timetable',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_box_outlined),
              activeIcon: Icon(Icons.check_box),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Faculty',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
