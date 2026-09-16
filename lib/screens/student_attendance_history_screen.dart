import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psg_app/core/providers/supabase_provider.dart';

class StudentAttendanceHistoryScreen extends ConsumerStatefulWidget {
  const StudentAttendanceHistoryScreen({super.key});

  @override
  ConsumerState<StudentAttendanceHistoryScreen> createState() => _StudentAttendanceHistoryScreenState();
}

class _StudentAttendanceHistoryScreenState extends ConsumerState<StudentAttendanceHistoryScreen> {
  bool _isLoading = true;
  Map<String, List<Map<String, dynamic>>> _groupedAttendance = {};

  @override
  void initState() {
    super.initState();
    _fetchAttendanceHistory();
  }

  Future<void> _fetchAttendanceHistory() async {
    setState(() => _isLoading = true);
    try {
      final supabase = ref.read(supabaseClientProvider);
      final studentId = supabase.auth.currentUser?.id;
      if (studentId == null) return;

      final response = await supabase
          .from('attendance_records')
          .select('''
            status,
            marked_at,
            attendance_sessions!inner (
              date,
              start_time,
              end_time,
              classes (
                subject_name,
                subject_code
              ),
              profiles (
                full_name
              )
            )
          ''')
          .eq('student_id', studentId);

      final List<dynamic> records = response;

      // Sort records by date descending, then by start_time
      records.sort((a, b) {
        final sessionA = a['attendance_sessions'];
        final sessionB = b['attendance_sessions'];
        final dateA = sessionA['date'] as String;
        final dateB = sessionB['date'] as String;
        final dateCompare = dateB.compareTo(dateA); // Descending
        if (dateCompare != 0) return dateCompare;

        final timeA = sessionA['start_time'] as String;
        final timeB = sessionB['start_time'] as String;
        return timeB.compareTo(timeA); // Descending
      });

      // Group by date
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var record in records) {
        final date = record['attendance_sessions']['date'] as String;
        if (!grouped.containsKey(date)) {
          grouped[date] = [];
        }
        grouped[date]!.add(record as Map<String, dynamic>);
      }

      if (mounted) {
        setState(() {
          _groupedAttendance = grouped;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching attendance history: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getStatusColor(String status) {
    if (status.contains('Present')) return const Color(0xFF16A34A);
    if (status == 'Absent') return const Color(0xFFDC2626);
    if (status == 'Late') return const Color(0xFFF59E0B);
    return const Color(0xFF64748B);
  }

  Color _getStatusBgColor(String status) {
    if (status.contains('Present')) return const Color(0xFFDCFCE7);
    if (status == 'Absent') return const Color(0xFFFEE2E2);
    if (status == 'Late') return const Color(0xFFFEF3C7);
    return const Color(0xFFF1F5F9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Attendance History',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groupedAttendance.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchAttendanceHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _groupedAttendance.keys.length,
                    itemBuilder: (context, index) {
                      final date = _groupedAttendance.keys.elementAt(index);
                      final recordsForDate = _groupedAttendance[date]!;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDateHeader(date),
                          const SizedBox(height: 12),
                          ...recordsForDate.map((record) => _buildAttendanceCard(record)).toList(),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.history_edu, size: 64, color: Color(0xFFCBD5E1)),
          SizedBox(height: 16),
          Text(
            'No attendance history yet',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String dateString) {
    // Format date string from YYYY-MM-DD to something nicer like "Oct 12, 2024"
    // Using a simple split for now to avoid intl dependency if not present
    final parts = dateString.split('-');
    String formattedDate = dateString;
    if (parts.length == 3) {
      final year = parts[0];
      final month = _getMonthName(int.tryParse(parts[1]) ?? 1);
      final day = parts[2];
      formattedDate = '$month $day, $year';
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            formattedDate,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
              fontSize: 13,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: Color(0xFFE2E8F0),
            indent: 12,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
    final session = record['attendance_sessions'];
    final classes = session['classes'] ?? {};
    final profile = session['profiles'] ?? {};
    
    final subjectCode = classes['subject_code'] ?? 'N/A';
    final subjectName = classes['subject_name'] ?? 'Unknown Class';
    final facultyName = profile['full_name'] ?? 'Unknown Faculty';
    final startTime = _formatTime(session['start_time'] ?? '00:00:00');
    final endTime = _formatTime(session['end_time'] ?? '00:00:00');
    final status = record['status'] ?? 'Unknown';

    final statusColor = _getStatusColor(status);
    final statusBgColor = _getStatusBgColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$subjectCode - $subjectName',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      facultyName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text(
                '$startTime - $endTime',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(String timeString) {
    // Basic formatting from HH:MM:SS to HH:MM AM/PM
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        final min = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        if (hour > 12) hour -= 12;
        if (hour == 0) hour = 12;
        return '${hour.toString().padLeft(2, '0')}:$min $period';
      }
    } catch (_) {}
    return timeString;
  }
}
