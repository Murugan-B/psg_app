import 'package:flutter/material.dart';
import 'package:psg_app/utils/ui_helpers.dart';
import 'package:psg_app/screens/student_timetable_screen.dart';
import 'package:psg_app/screens/student_attendance_screen.dart';
import 'package:psg_app/screens/student_attendance_history_screen.dart';
import 'package:psg_app/screens/faculty_directory_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class StudentDashboardScreen extends StatefulWidget {
  final void Function(int)? onTabSelect;
  const StudentDashboardScreen({super.key, this.onTabSelect});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;
  String _userName = 'Student';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final res = await Supabase.instance.client
            .from('profiles')
            .select('full_name')
            .eq('id', userId)
            .single();
        if (mounted) {
          setState(() {
            _userName = res['full_name'] ?? 'Student';
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light blue-grey background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Header Profile Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Good Morning,',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$_userName!',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Keep learning, keep growing!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: const NetworkImage(
                        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Banner
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.8),
                              Colors.black.withValues(alpha: 0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 20,
                        top: 60,
                        child: Text(
                          'Discipline Today\nSuccess Tomorrow',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 8,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 8,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Actions Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        title: 'Mark Attendance',
                        icon: Icons.check_circle_outline,
                        color: const Color(0xFF10B981), // Green
                        iconBgColor: const Color(0xFFD1FAE5),
                        onTap: () {
                          if (widget.onTabSelect != null) {
                            widget.onTabSelect!(2);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const StudentAttendanceScreen()),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        title: 'View Timetable',
                        icon: Icons.calendar_today,
                        color: const Color(0xFF8B5CF6), // Purple
                        iconBgColor: const Color(0xFFEDE9FE),
                        onTap: () {
                          if (widget.onTabSelect != null) {
                            widget.onTabSelect!(1);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const StudentTimetableScreen()),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        title: 'Attendance Status',
                        icon: Icons.bar_chart,
                        color: const Color(0xFFEC4899), // Pink
                        iconBgColor: const Color(0xFFFCE7F3),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const StudentAttendanceHistoryScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        title: 'Study Resources',
                        icon: Icons.menu_book,
                        color: const Color(0xFFF97316), // Orange
                        iconBgColor: const Color(0xFFFFEDD5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Today's Classes Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Today\'s Classes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Flexible(
                      child: TextButton(
                        onPressed: () {
                          showComingSoonSnackBar(context);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'View All',
                              style: TextStyle(
                                color: Color(0xFF2E63EB),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Color(0xFF2E63EB),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Classes List
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.event_busy, size: 48, color: Color(0xFFCBD5E1)),
                      SizedBox(height: 16),
                      Text(
                        'No classes scheduled for today',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Motivational Quote
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF), // Light blue
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '"',
                        style: TextStyle(
                          fontSize: 40,
                          color: Color(0xFF3B82F6),
                          height: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: const Text(
                          '"A little progress each day adds up to big results."',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1E3A8A),
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),

    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color iconBgColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildClassTile({
    required String startTime,
    required String endTime,
    required String subjectName,
    required String details,
    required String status,
  }) {
    final isOngoing = status == 'Ongoing';

    return Container(
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Column
          SizedBox(
            width: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startTime,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  endTime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subjectName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          
          // Status Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isOngoing ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isOngoing ? const Color(0xFF16A34A) : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
