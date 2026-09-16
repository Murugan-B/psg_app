import 'package:flutter/material.dart';
import 'package:psg_app/utils/ui_helpers.dart';
import 'package:psg_app/screens/admin_students_screen.dart';
import 'package:psg_app/screens/admin_faculty_screen.dart';
import 'package:psg_app/screens/admin_timetable_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psg_app/features/admin/providers/admin_providers.dart';
import 'package:psg_app/screens/admin_classes_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  final void Function(int)? onTabSelect;
  const AdminDashboardScreen({super.key, this.onTabSelect});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;
  String _userName = 'Admin';

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
            _userName = res['full_name'] ?? 'Admin';
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);
    final stats = statsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => {
        'totalStudents': 0,
        'totalFaculty': 0,
        'totalClasses': 0,
        'avgAttendance': 0,
        'scheduledToday': 0,
        'attendanceMarked': 0,
        'inProgress': 0,
        'pendingAttendance': 0,
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF0F172A)),
          onPressed: () => showComingSoonSnackBar(context),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Color(0xFF0F172A)),
                onPressed: () => showComingSoonSnackBar(context),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              
              // Profile Section
              Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFF1F5F9),
                    backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back,',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                        ),
                      ),
                      Text(
                        '$_userName!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Institute Administrator',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Make Education\nMore Organized\nTogether',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 8,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Statistics Grid
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.people_alt,
                      iconColor: const Color(0xFF2E63EB), // Blue
                      bgColor: const Color(0xFFEFF6FF),
                      value: stats['totalStudents'].toString(),
                      label: 'Students',
                      badgeText: '-',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.groups,
                      iconColor: const Color(0xFF10B981), // Green
                      bgColor: const Color(0xFFF0FDF4),
                      value: stats['totalFaculty'].toString(),
                      label: 'Faculty Members',
                      badgeText: '-',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminClassesScreen()),
                        );
                      },
                      child: _buildStatCard(
                        icon: Icons.menu_book,
                        iconColor: const Color(0xFF8B5CF6), // Purple
                        bgColor: const Color(0xFFF5F3FF),
                        value: stats['totalClasses'].toString(),
                        label: 'Classes',
                        badgeText: '-',
                        badgeColor: Colors.transparent,
                        badgeTextColor: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.check_circle_outline,
                      iconColor: const Color(0xFFF59E0B), // Orange
                      bgColor: const Color(0xFFFFFBEB),
                      value: '${stats['avgAttendance']}%',
                      label: 'Avg. Attendance',
                      badgeText: '-',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Today's Overview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Today\'s Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    DateFormat('EEE, MMM d, yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildOverviewItem(
                icon: Icons.trending_up,
                iconColor: const Color(0xFF3B82F6), // Blue
                iconBgColor: const Color(0xFFDBEAFE),
                title: 'Classes in Progress',
                subtitle: 'Ongoing right now',
                value: stats['inProgress'].toString(),
              ),
              const SizedBox(height: 12),
              _buildOverviewItem(
                icon: Icons.calendar_today,
                iconColor: const Color(0xFF8B5CF6), // Purple
                iconBgColor: const Color(0xFFF3E8FF),
                title: 'Scheduled for Today',
                subtitle: 'Total classes',
                value: stats['scheduledToday'].toString(),
              ),
              const SizedBox(height: 12),
              _buildOverviewItem(
                icon: Icons.check_circle_outline,
                iconColor: const Color(0xFF10B981), // Green
                iconBgColor: const Color(0xFFD1FAE5),
                title: 'Attendance Marked',
                subtitle: 'So far today',
                value: stats['attendanceMarked'].toString(),
              ),
              const SizedBox(height: 12),
              _buildOverviewItem(
                icon: Icons.push_pin_outlined,
                iconColor: const Color(0xFFF97316), // Orange
                iconBgColor: const Color(0xFFFFEDD5),
                title: 'Pending Attendance',
                subtitle: 'Yet to be marked',
                value: stats['pendingAttendance'].toString(),
              ),
              const SizedBox(height: 24),

              // View Detailed Reports
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), // Light blue background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6), // Purple icon bg
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bar_chart, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'View Detailed Reports',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Analyze attendance, class activity and more.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF1E3A8A)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String value,
    required String label,
    required String badgeText,
    Color badgeColor = const Color(0xFFDCFCE7),
    Color badgeTextColor = const Color(0xFF16A34A),
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: badgeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
