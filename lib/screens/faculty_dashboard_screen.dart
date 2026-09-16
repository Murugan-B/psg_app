import 'package:flutter/material.dart';
import 'package:psg_app/screens/faculty_classes_screen.dart';
import 'package:psg_app/screens/faculty_directory_screen.dart';
import 'package:psg_app/screens/faculty_generate_otp_screen.dart';
import 'package:psg_app/screens/faculty_timetable_screen.dart';
import 'package:psg_app/screens/faculty_otp_history_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psg_app/features/staff/providers/staff_providers.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FacultyDashboardScreen extends ConsumerStatefulWidget {
  final void Function(int)? onTabSelect;
  const FacultyDashboardScreen({super.key, this.onTabSelect});

  @override
  ConsumerState<FacultyDashboardScreen> createState() => _FacultyDashboardScreenState();
}

class _FacultyDashboardScreenState extends ConsumerState<FacultyDashboardScreen> {
  int _selectedIndex = 0;
  String _userName = 'Staff';

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
            _userName = res['full_name'] ?? 'Staff';
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayTimetableAsync = ref.watch(todayTimetableProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light blue-grey background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // Header Profile Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Icon(Icons.menu, size: 28, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Good Morning,',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$_userName!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Faculty • Computer Science',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: const NetworkImage(
                        'https://images.unsplash.com/photo-1560250097-0b93528c311a?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Banner
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0F172A),
                        Color(0xFF1E3A8A), // Dark blue gradient
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Positioned(
                        left: 20,
                        top: 24,
                        child: Text(
                          '"Great teachers\ncreate great futures."',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Icon(
                          Icons.school_outlined,
                          size: 100,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 20,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 8,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
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

                // Action Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        title: 'Generate OTP',
                        subtitle: 'Create class-wise OTP\nfor attendance',
                        icon: Icons.qr_code_2,
                        iconColor: const Color(0xFF3B82F6), // Blue
                        bgColor: const Color(0xFFEFF6FF),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FacultyGenerateOtpScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        title: 'My Classes',
                        subtitle: 'View your assigned\nclasses',
                        icon: Icons.people_alt,
                        iconColor: const Color(0xFF10B981), // Green
                        bgColor: const Color(0xFFF0FDF4),
                        onTap: () {
                          if (widget.onTabSelect != null) {
                            widget.onTabSelect!(1);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FacultyClassesScreen()),
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
                        title: 'View Timetable',
                        subtitle: 'Check your class\nschedule',
                        icon: Icons.calendar_month,
                        iconColor: const Color(0xFF8B5CF6), // Purple
                        bgColor: const Color(0xFFF5F3FF),
                        onTap: () {
                          if (widget.onTabSelect != null) {
                            widget.onTabSelect!(2);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FacultyTimetableScreen()),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        title: 'OTP History',
                        subtitle: 'View generated OTPs',
                        icon: Icons.history,
                        iconColor: const Color(0xFF475569), // Grey
                        bgColor: const Color(0xFFF1F5F9),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FacultyOtpHistoryScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Today's Classes Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                      child: Text(
                        DateFormat('EEE, MMM d, yyyy').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Classes List
                todayTimetableAsync.when(
                  data: (timetable) {
                    if (timetable.isEmpty) {
                      return Container(
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
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: timetable.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = timetable[index];
                        final subjectName = item['courses']?['subject_name'] ?? item['classes']?['subject_name'] ?? 'Unknown Class';
                        final department = item['classes']?['department'] ?? '';
                        final year = item['classes']?['year'] ?? '';
                        final section = item['classes']?['section'] ?? '';
                        final batch = item['classes']?['batch'] ?? "$year $department - $section".trim();
                        
                        // Parse time for status
                        // Simple ongoing status logic for demo
                        return _buildClassTile(
                          startTime: (item['start_time'] as String).substring(0, 5),
                          endTime: (item['end_time'] as String).substring(0, 5),
                          subjectTitle: subjectName,
                          batch: batch,
                          status: 'Upcoming', // Can be dynamic based on current time
                        );
                      },
                    );
                  },
                  loading: () => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, stack) => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Unable to load today\'s classes',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please check your connection and try again.',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.invalidate(todayTimetableProvider);
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E63EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
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
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: const Color(0xFF64748B), size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                height: 1.3,
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
    required String subjectTitle,
    required String batch,
    required String status,
  }) {
    final isOngoing = status == 'Ongoing';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Time
          SizedBox(
            width: 65,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startTime,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  endTime,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Container(
            width: 1,
            height: 36,
            color: const Color(0xFFE2E8F0),
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subjectTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  batch,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          
          // Status Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isOngoing ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isOngoing ? const Color(0xFF16A34A) : const Color(0xFF2E63EB),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
