import 'dart:io';

void main() {
  final screens = [
    // Admin
    {'path': 'lib/features/admin/presentation/screens/admin_home_screen.dart', 'name': 'AdminHomeScreen', 'title': 'Admin Home'},
    {'path': 'lib/features/admin/presentation/screens/admin_stock_screen.dart', 'name': 'AdminStockScreen', 'title': 'Admin Stock'},
    {'path': 'lib/features/admin/presentation/screens/admin_pos_screen.dart', 'name': 'AdminPosScreen', 'title': 'Admin POS'},
    {'path': 'lib/features/admin/presentation/screens/admin_staff_screen.dart', 'name': 'AdminStaffScreen', 'title': 'Admin Staff'},
    {'path': 'lib/features/admin/presentation/screens/admin_report_screen.dart', 'name': 'AdminReportScreen', 'title': 'Admin Report'},
    // Staff
    {'path': 'lib/features/staff/presentation/screens/staff_home_screen.dart', 'name': 'StaffHomeScreen', 'title': 'Staff Home'},
    {'path': 'lib/features/staff/presentation/screens/staff_pos_screen.dart', 'name': 'StaffPosScreen', 'title': 'Staff POS'},
    {'path': 'lib/features/staff/presentation/screens/staff_attendance_screen.dart', 'name': 'StaffAttendanceScreen', 'title': 'Staff Attendance'},
    // Misc
    {'path': 'lib/features/admin/presentation/screens/admin_products_screen.dart', 'name': 'AdminProductsScreen', 'title': 'Admin Products'},
  ];

  for (final screen in screens) {
    final file = File(screen['path']!);
    file.createSync(recursive: true);
    file.writeAsStringSync('''
import 'package:flutter/material.dart';

class ${screen['name']} extends StatelessWidget {
  const ${screen['name']}({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('${screen['title']}')),
      body: const Center(child: Text('${screen['title']}')),
    );
  }
}
''');
  }
}
