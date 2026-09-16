import 'package:flutter/material.dart';
import 'package:psg_app/screens/faculty_class_details_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psg_app/features/staff/providers/staff_providers.dart';

class FacultyClassesScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  const FacultyClassesScreen({super.key, this.isEmbedded = false});

  @override
  ConsumerState<FacultyClassesScreen> createState() => _FacultyClassesScreenState();
}

class _FacultyClassesScreenState extends ConsumerState<FacultyClassesScreen> {
  bool _isCurrentSemester = true;

  @override
  Widget build(BuildContext context) {
    final myClassesAsync = ref.watch(myClassesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.isEmbedded ? null : IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Classes',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          
          // Semester Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), // Light grey
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCurrentSemester = true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isCurrentSemester ? const Color(0xFF2E63EB) : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Current Semester',
                          style: TextStyle(
                            color: _isCurrentSemester ? Colors.white : const Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCurrentSemester = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !_isCurrentSemester ? const Color(0xFF2E63EB) : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'All Semesters',
                          style: TextStyle(
                            color: !_isCurrentSemester ? Colors.white : const Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Classes List
          Expanded(
            child: myClassesAsync.when(
              data: (classes) {
                if (classes.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(myClassesProvider);
                    },
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Column(
                            children: const [
                              Icon(Icons.class_outlined, size: 64, color: Color(0xFFCBD5E1)),
                              SizedBox(height: 16),
                              Text(
                                'No classes found',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Info Card
                        _buildInfoCard(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(myClassesProvider);
                    // Wait for the new future to complete
                    try {
                      await ref.read(myClassesProvider.future);
                    } catch (_) {}
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    itemCount: classes.length + 1, // +1 for the info card at bottom
                    separatorBuilder: (context, index) {
                      if (index == classes.length - 1) return const SizedBox(height: 24);
                      return const SizedBox(height: 16);
                    },
                    itemBuilder: (context, index) {
                      if (index == classes.length) {
                        return _buildInfoCard();
                      }

                      final cls = classes[index];
                      final batch = "${cls.year ?? ''} ${cls.department} - ${cls.section ?? ''}".trim();
                      final colors = [
                        const Color(0xFF3B82F6), // Blue
                        const Color(0xFF10B981), // Green
                        const Color(0xFF8B5CF6), // Purple
                        const Color(0xFFF59E0B), // Orange
                      ];
                      final barColor = colors[index % colors.length];

                      return _buildClassCard(
                        courseCode: cls.subjectCode,
                        courseName: cls.subjectName,
                        batch: batch,
                        studentsCount: cls.studentCount.toString(),
                        barColor: barColor,
                        onTap: () {
                          // We also set the selected class in provider so we can use it in OTP flow
                          ref.read(selectedClassProvider.notifier).setClass(cls);
                          _navigateToClassDetails(cls.subjectCode, cls.subjectName, batch, cls.studentCount.toString());
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to load classes',
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
                          ref.invalidate(myClassesProvider);
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.isEmbedded ? null : Container(
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
          currentIndex: 1, // Classes tab
          onTap: (index) {
            if (index == 0) {
              Navigator.pop(context);
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2E63EB),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt),
              label: 'Classes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Timetable',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Light blue
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF2E63EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Need to make changes?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Contact the department admin for any class allocation changes.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToClassDetails(String code, String name, String batch, String count) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FacultyClassDetailsScreen(
          courseCode: code,
          courseName: name,
          batch: batch,
          studentsCount: count,
        ),
      ),
    );
  }

  Widget _buildClassCard({
    required String courseCode,
    required String courseName,
    required String batch,
    required String studentsCount,
    required Color barColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left Color Bar
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Course Code
                    SizedBox(
                      width: 60,
                      child: Text(
                        courseCode,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Course Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            courseName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            batch,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.people_alt, size: 14, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Text(
                                '$studentsCount Students',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Right Chevron
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF94A3B8),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
