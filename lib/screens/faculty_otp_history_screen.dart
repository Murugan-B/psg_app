import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psg_app/core/providers/supabase_provider.dart';
import 'package:psg_app/features/staff/providers/staff_providers.dart';
import 'package:psg_app/features/staff/data/staff_repository.dart';

class FacultyOtpHistoryScreen extends ConsumerStatefulWidget {
  const FacultyOtpHistoryScreen({super.key});

  @override
  ConsumerState<FacultyOtpHistoryScreen> createState() => _FacultyOtpHistoryScreenState();
}

class _FacultyOtpHistoryScreenState extends ConsumerState<FacultyOtpHistoryScreen> {
  bool _isLoading = true;
  Map<String, List<Map<String, dynamic>>> _groupedSessions = {};

  @override
  void initState() {
    super.initState();
    _fetchOtpHistory();
  }

  Future<void> _fetchOtpHistory() async {
    setState(() => _isLoading = true);
    try {
      final supabase = ref.read(supabaseClientProvider);
      final staffId = ref.read(staffRepositoryProvider).currentStaffId;
      if (staffId == null) return;

      final response = await supabase
          .from('attendance_sessions')
          .select('''
            id,
            date,
            start_time,
            end_time,
            status,
            classes (
              subject_name,
              subject_code,
              year,
              department,
              section
            )
          ''')
          .eq('staff_id', staffId)
          .order('date', ascending: false)
          .order('start_time', ascending: false);

      final List<dynamic> sessions = response;

      // Group by date
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var session in sessions) {
        final date = session['date'] as String;
        if (!grouped.containsKey(date)) {
          grouped[date] = [];
        }
        grouped[date]!.add(session as Map<String, dynamic>);
      }

      if (mounted) {
        setState(() {
          _groupedSessions = grouped;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching OTP history: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          'OTP History',
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
          : _groupedSessions.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchOtpHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _groupedSessions.keys.length,
                    itemBuilder: (context, index) {
                      final date = _groupedSessions.keys.elementAt(index);
                      final sessionsForDate = _groupedSessions[date]!;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDateHeader(date),
                          const SizedBox(height: 12),
                          ...sessionsForDate.map((session) => _buildSessionCard(session)).toList(),
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
          Icon(Icons.history, size: 64, color: Color(0xFFCBD5E1)),
          SizedBox(height: 16),
          Text(
            'No OTP sessions found',
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

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final classes = session['classes'] ?? {};
    final subjectCode = classes['subject_code'] ?? 'N/A';
    final subjectName = classes['subject_name'] ?? 'Unknown Class';
    final department = classes['department'] ?? '';
    final year = classes['year'] ?? '';
    final section = classes['section'] ?? '';
    
    final batch = "$year $department - $section".trim();
    final startTime = _formatTime(session['start_time'] ?? '00:00:00');
    final endTime = _formatTime(session['end_time'] ?? '00:00:00');
    final status = session['status'] ?? 'CLOSED';

    final isOpen = status == 'OPEN';

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
                      batch.isEmpty ? 'General' : batch,
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
                  color: isOpen ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isOpen ? const Color(0xFF16A34A) : const Color(0xFF64748B),
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
