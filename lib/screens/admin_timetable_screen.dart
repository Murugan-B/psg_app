import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psg_app/utils/ui_helpers.dart';
import 'package:psg_app/screens/admin_request_substitute_screen.dart';
import 'package:psg_app/features/admin/providers/admin_providers.dart';
import 'package:psg_app/features/admin/data/admin_repository.dart';

class AdminTimetableScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  const AdminTimetableScreen({super.key, this.isEmbedded = false});

  @override
  ConsumerState<AdminTimetableScreen> createState() => _AdminTimetableScreenState();
}

class _AdminTimetableScreenState extends ConsumerState<AdminTimetableScreen> {
  int _selectedViewIndex = 0; // 0: Week View, 1: Subject View
  int _bottomNavIndex = 3; // 3 for Timetable

  String? _selectedClassId;

  final List<String> times = [
    '09:00 - 10:00',
    '10:10 - 11:10',
    '11:20 - 12:20',
    '13:30 - 14:30',
    '14:40 - 15:40',
    '15:50 - 16:50',
  ];

  final List<String> displayTimes = [
    '09:00\n- 10:00',
    '10:10\n- 11:10',
    '11:20\n- 12:20',
    '01:30\n- 02:30',
    '02:40\n- 03:40',
    '03:50\n- 04:50',
  ];

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  final List<String> displayDays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  final Map<String, Map<String, Color>> typeColors = {
    'Theory': {'bg': const Color(0xFFE0F2FE), 'text': const Color(0xFF1E3A8A)}, // Blue
    'Lab': {'bg': const Color(0xFFDCFCE7), 'text': const Color(0xFF166534)}, // Green
    'Tutorial': {'bg': const Color(0xFFFEF3C7), 'text': const Color(0xFF92400E)}, // Yellow
    'Activity': {'bg': const Color(0xFFFCE7F3), 'text': const Color(0xFF9D174D)}, // Pink
    'Other': {'bg': const Color(0xFFF1F5F9), 'text': const Color(0xFF475569)}, // Grey
  };

  final Map<String, Color> legendColors = {
    'Theory': const Color(0xFF3B82F6), // Blue
    'Lab': const Color(0xFF22C55E), // Green
    'Tutorial': const Color(0xFFF59E0B), // Yellow
    'Activity': const Color(0xFFEC4899), // Pink
    'Other': const Color(0xFFCBD5E1), // Grey
  };

  void _showAssignSlotModal(int rowIndex, int colIndex, Map<String, String>? existingData) {
    if (_selectedClassId == null) return;
    
    final dayOfWeek = days[colIndex];
    
    // Convert to DB time format (e.g. 09:00:00)
    String startTimeStr = '09:00:00';
    String endTimeStr = '10:00:00';
    if (rowIndex == 1) { startTimeStr = '10:10:00'; endTimeStr = '11:10:00'; }
    else if (rowIndex == 2) { startTimeStr = '11:20:00'; endTimeStr = '12:20:00'; }
    else if (rowIndex == 3) { startTimeStr = '13:30:00'; endTimeStr = '14:30:00'; }
    else if (rowIndex == 4) { startTimeStr = '14:40:00'; endTimeStr = '15:40:00'; }
    else if (rowIndex == 5) { startTimeStr = '15:50:00'; endTimeStr = '16:50:00'; }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AssignTimetableSlotModal(
        classId: _selectedClassId!,
        dayOfWeek: dayOfWeek,
        startTime: startTimeStr,
        endTime: endTimeStr,
        displayTime: displayTimes[rowIndex].replaceAll('\n', ' '),
        existingData: existingData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(adminClassesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.isEmbedded ? null : IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Weekly Timetable',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              
              // Dynamic Class Dropdown
              classesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error loading classes: $err'),
                data: (classes) {
                  if (_selectedClassId == null && classes.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() => _selectedClassId = classes.first['id']);
                    });
                  }
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedClassId,
                        isExpanded: true,
                        hint: const Text('Select a Class'),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748B)),
                        items: classes.map((c) {
                          return DropdownMenuItem<String>(
                            value: c['id'],
                            child: Text(
                              '${c['subject_code']} - ${c['subject_name']} (${c['year']} ${c['department']} - ${c['section']})',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedClassId = val);
                        },
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              

              
              // Timetable Grid (Dynamic)
              if (_selectedClassId != null)
                ref.watch(adminTimetableProvider(_selectedClassId!)).when(
                  loading: () => const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  )),
                  error: (err, stack) => Text('Error: $err'),
                  data: (timetableData) {
                    // Build the 6x6 schedule array
                    final List<List<Map<String, String>?>> schedule = List.generate(
                      6,
                      (_) => List.generate(6, (_) => null),
                    );

                    for (var entry in timetableData) {
                      final day = entry['day_of_week'];
                      final startTime = entry['start_time'];
                      
                      int colIndex = days.indexOf(day);
                      int rowIndex = -1;
                      
                      if (startTime.startsWith('09:00')) rowIndex = 0;
                      else if (startTime.startsWith('10:10')) rowIndex = 1;
                      else if (startTime.startsWith('11:20')) rowIndex = 2;
                      else if (startTime.startsWith('13:30')) rowIndex = 3;
                      else if (startTime.startsWith('14:40')) rowIndex = 4;
                      else if (startTime.startsWith('15:50')) rowIndex = 5;

                      if (rowIndex != -1 && colIndex != -1) {
                        final facultyName = entry['faculty']?['full_name'] ?? 'Unknown';
                        schedule[rowIndex][colIndex] = {
                          'id': entry['id'].toString(),
                          'faculty_id': entry['faculty_id']?.toString() ?? '',
                          'title': facultyName,
                          'type': entry['type'] ?? 'Theory',
                        };
                      }
                    }

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Header Row
                          Row(
                            children: [
                              _buildHeaderCell('Time', isTimeColumn: true),
                              ...displayDays.map((day) => _buildHeaderCell(day)),
                            ],
                          ),
                          // Schedule Rows
                          ...List.generate(6, (rowIndex) {
                            return Row(
                              children: [
                                _buildTimeCell(displayTimes[rowIndex]),
                                ...List.generate(6, (colIndex) {
                                  final cellData = schedule[rowIndex][colIndex];
                                  return _buildScheduleCell(
                                    cellData, 
                                    onTap: () => _showAssignSlotModal(rowIndex, colIndex, cellData),
                                  );
                                }),
                              ],
                            );
                          }),
                        ],
                      ),
                    );
                  },
                )
              else
                const Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('Please select a class to view timetable'),
                )),

              const SizedBox(height: 24),
              
              // Legend
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: legendColors.entries.map((entry) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: entry.value,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => showComingSoonSnackBar(context),
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: const Text(
                        'Export PDF',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF2E63EB), width: 1.5),
                        foregroundColor: const Color(0xFF2E63EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminRequestSubstituteScreen()),
                        );
                      },
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text(
                        'Assign Substitute',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF2E63EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildHeaderCell(String text, {bool isTimeColumn = false}) {
    return Expanded(
      flex: 2,
      child: Container(
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: const BorderSide(color: Color(0xFFF1F5F9)),
            right: BorderSide(color: isTimeColumn ? const Color(0xFFF1F5F9) : Colors.transparent),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            height: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCell(String text) {
    return Expanded(
      flex: 2,
      child: Container(
        height: 80,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: Color(0xFFF1F5F9)),
            bottom: BorderSide(color: Color(0xFFF1F5F9)),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCell(Map<String, String>? data, {required VoidCallback onTap}) {
    if (data == null) {
      return Expanded(
        flex: 2,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 80,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9)),
                right: BorderSide(color: Color(0xFFF1F5F9)),
              ),
            ),
            child: const Icon(Icons.add, color: Color(0xFFCBD5E1), size: 20),
          ),
        ),
      );
    }

    final type = data['type']!;
    final colors = typeColors[type] ?? typeColors['Other']!;
    
    return Expanded(
      flex: 2,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 80,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFF1F5F9)),
              right: BorderSide(color: Color(0xFFF1F5F9)),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: colors['bg'],
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              data['title']!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: colors['text'],
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Modal for assigning/editing a faculty member to a slot
class AssignTimetableSlotModal extends ConsumerStatefulWidget {
  final String classId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String displayTime;
  final Map<String, String>? existingData;

  const AssignTimetableSlotModal({
    super.key,
    required this.classId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.displayTime,
    this.existingData,
  });

  @override
  ConsumerState<AssignTimetableSlotModal> createState() => _AssignTimetableSlotModalState();
}

class _AssignTimetableSlotModalState extends ConsumerState<AssignTimetableSlotModal> {
  String? _selectedFacultyId;
  String _selectedType = 'Theory';
  bool _isLoading = false;

  final List<String> _types = ['Theory', 'Lab', 'Tutorial', 'Activity', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _selectedFacultyId = widget.existingData!['faculty_id'];
      if (_selectedFacultyId != null && _selectedFacultyId!.isEmpty) _selectedFacultyId = null;
      if (widget.existingData!['type'] != null && _types.contains(widget.existingData!['type'])) {
        _selectedType = widget.existingData!['type']!;
      }
    }
  }

  void _submit() async {
    if (_selectedFacultyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a faculty member')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.assignTimetableSlot(
        classId: widget.classId,
        facultyId: _selectedFacultyId!,
        dayOfWeek: widget.dayOfWeek,
        startTime: widget.startTime,
        endTime: widget.endTime,
        type: _selectedType,
      );

      // Refresh timetable
      ref.invalidate(adminTimetableProvider(widget.classId));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Slot assigned successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _delete() async {
    if (widget.existingData == null || widget.existingData!['id'] == null) return;
    
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Slot'),
        content: const Text('Are you sure you want to remove this timetable slot?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.deleteTimetableSlot(widget.existingData!['id']!);
      
      ref.invalidate(adminTimetableProvider(widget.classId));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Slot deleted!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final facultyAsync = ref.watch(adminStaffListProvider);
    final isEditing = widget.existingData != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Timetable Slot' : 'Assign Timetable Slot',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Color(0xFF2E63EB), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.dayOfWeek}  •  ${widget.displayTime}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('Faculty', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
            const SizedBox(height: 6),
            facultyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data: (facultyList) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFacultyId,
                      isExpanded: true,
                      hint: const Text('Select Faculty'),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                      items: facultyList.map((f) {
                        return DropdownMenuItem<String>(
                          value: f['id'],
                          child: Text('${f['full_name']} (${f['designation'] ?? 'Faculty'})',
                            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedFacultyId = val),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            const Text('Session Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                  items: _types.map((t) {
                    return DropdownMenuItem<String>(
                      value: t,
                      child: Text(t, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            Row(
              children: [
                if (isEditing)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _delete,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Delete Slot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (isEditing) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF2E63EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(isEditing ? 'Save Changes' : 'Assign Slot', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
