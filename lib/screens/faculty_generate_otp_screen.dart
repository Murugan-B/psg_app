import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psg_app/features/staff/providers/staff_providers.dart';
import 'package:psg_app/features/staff/data/attendance_repository.dart';
import 'package:psg_app/features/staff/data/staff_repository.dart';
import 'package:psg_app/features/staff/domain/models/attendance_session_model.dart';
import 'package:psg_app/core/providers/supabase_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

class FacultyGenerateOtpScreen extends ConsumerStatefulWidget {
  const FacultyGenerateOtpScreen({super.key});

  @override
  ConsumerState<FacultyGenerateOtpScreen> createState() => _FacultyGenerateOtpScreenState();
}

class _FacultyGenerateOtpScreenState extends ConsumerState<FacultyGenerateOtpScreen> {
  AttendanceSessionModel? _currentSession;
  String _otp = "";
  String? _endOtp;
  Timer? _timer;
  int _secondsRemaining = 40; // 40 seconds
  DateTime? _customDateTime;

  @override
  void initState() {
    super.initState();
    // We start without a session, the user can click "Generate"
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = 40;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return;
      
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        // Regenerate OTP
        final repo = ref.read(attendanceRepositoryProvider);
        final newOtp = repo.generateOtp();
        
        if (_currentSession != null) {
          if (_endOtp == null) {
            // Start OTP
            await repo.updateStartOtp(_currentSession!.id, newOtp);
            if (mounted) {
              setState(() {
                _otp = newOtp;
                _secondsRemaining = 40;
              });
            }
          } else {
            // End OTP
            await repo.updateEndOtp(_currentSession!.id, newOtp);
            if (mounted) {
              setState(() {
                _endOtp = newOtp;
                _secondsRemaining = 40;
              });
            }
          }
        }
      }
    });
  }

  Future<void> _generateOtp() async {
    final staffRepo = ref.read(staffRepositoryProvider);
    final attendanceRepo = ref.read(attendanceRepositoryProvider);
    final staffId = staffRepo.currentStaffId;

    if (staffId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Not logged in')));
      return;
    }

    final selectedClass = ref.read(selectedClassProvider);
    String targetClassId = '';
    
    if (selectedClass == null) {
      // Testing bypass: Use first available class if none selected
      try {
        final supabase = ref.read(supabaseClientProvider);
        final res = await supabase.from('classes').select('id').limit(1).single();
        targetClassId = res['id'];
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Testing Mode: Using dummy class for OTP')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: No classes in DB for testing fallback')),
          );
        }
        return;
      }
    } else {
      targetClassId = selectedClass.id;
    }

    final otp = attendanceRepo.generateOtp();
    final session = await attendanceRepo.createSession(
      classId: targetClassId,
      staffId: staffId,
      otp: otp,
      durationMinutes: 10,
      customDateTime: _customDateTime,
    );

    if (session != null) {
      setState(() {
        _currentSession = session;
        _otp = otp;
        _endOtp = null;
      });
      _startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to generate OTP session')));
    }
  }

  Future<void> _generateEndOtp() async {
    final attendanceRepo = ref.read(attendanceRepositoryProvider);
    if (_currentSession == null) return;
    
    final endOtp = await attendanceRepo.generateEndOtp(_currentSession!.id);
    if (endOtp != null) {
      setState(() {
        _endOtp = endOtp;
      });
      _startTimer();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to generate End OTP')));
      }
    }
  }

  String get _formattedTime {
    final m = (_secondsRemaining / 60).floor().toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Future<void> _pickCustomDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _customDateTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_customDateTime ?? DateTime.now()),
      );
      if (time != null) {
        setState(() {
          _customDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedClass = ref.watch(selectedClassProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Generate OTP',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Class Info Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.people_alt, color: Color(0xFF1E3A8A), size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedClass != null 
                                  ? '${selectedClass.subjectCode} - ${selectedClass.subjectName}' 
                                  : 'No Class Selected',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedClass != null 
                                  ? '${selectedClass.year ?? ""} ${selectedClass.department} - ${selectedClass.section ?? ""}' 
                                  : 'Go to My Classes to select',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const SizedBox(height: 24),

              if (_otp.isEmpty) ...[
                // Custom Time Selection for Testing
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _pickCustomDateTime,
                    icon: const Icon(Icons.edit_calendar, size: 20),
                    label: Text(_customDateTime != null 
                        ? 'Testing Time: ${_customDateTime!.toString().substring(0, 16)}' 
                        : 'Set Custom Time (Testing Only)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: ElevatedButton.icon(
                      onPressed: _generateOtp,
                      icon: const Icon(Icons.sync, size: 24),
                      label: const Text('Generate Session OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        backgroundColor: const Color(0xFF2E63EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // OTP Display Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF), // Light blue
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.verified, color: Color(0xFF2E63EB), size: 24),
                          const SizedBox(width: 8),
                          Text(
                            _endOtp != null ? 'End OTP (Class Closing)' : 'Start OTP (Class Started)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // OTP Digits
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: (_endOtp ?? _otp).split('').map((digit) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Container(
                                height: 56,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  digit,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      
                      // QR Code Display
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: _endOtp ?? _otp,
                          version: QrVersions.auto,
                          size: 180.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Validity Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.access_time, color: Color(0xFF1E3A8A), size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Valid for 40 seconds',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1E3A8A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Progress Bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _secondsRemaining / 40,
                                minHeight: 6,
                                backgroundColor: Colors.white,
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E63EB)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formattedTime,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (_endOtp == null)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _generateEndOtp,
                      icon: const Icon(Icons.exit_to_app, size: 20),
                      label: const Text('Generate End OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                if (_endOtp == null) const SizedBox(height: 24),

                // Live Attendance stream
                if (_currentSession != null)
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: ref.read(attendanceRepositoryProvider).getLiveAttendance(_currentSession!.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final records = snapshot.data ?? [];
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Live Attendance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text('${records.length} Present', style: const TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (records.isEmpty)
                              const Text('Waiting for students to scan...', style: TextStyle(color: Color(0xFF64748B)))
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: records.length,
                                itemBuilder: (context, index) {
                                  return _StudentAttendanceTile(record: records[index]);
                                },
                              ),
                          ],
                        ),
                      );
                    }
                  ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentAttendanceTile extends ConsumerStatefulWidget {
  final Map<String, dynamic> record;
  const _StudentAttendanceTile({required this.record});

  @override
  ConsumerState<_StudentAttendanceTile> createState() => _StudentAttendanceTileState();
}

class _StudentAttendanceTileState extends ConsumerState<_StudentAttendanceTile> {
  String? studentName;
  String? rollNumber;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final supabase = ref.read(supabaseClientProvider);
    try {
      final res = await supabase.from('profiles').select('full_name, roll_number').eq('id', widget.record['student_id']).single();
      if (mounted) {
        setState(() {
          studentName = res['full_name'];
          rollNumber = res['roll_number'];
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.record['status'] as String? ?? '';
    final isFull = status.contains('Full');
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(child: Icon(Icons.person, size: 20)),
      title: Text(studentName ?? 'Loading...', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(
        rollNumber != null ? '$rollNumber • $status' : status, 
        style: TextStyle(color: isFull ? Colors.green : Colors.orange, fontSize: 12)
      ),
      trailing: isFull 
          ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
          : const Icon(Icons.check_circle_outline, color: Colors.orange, size: 20),
    );
  }
}
