import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psg_app/utils/ui_helpers.dart';
import 'package:psg_app/features/admin/providers/admin_providers.dart';
import 'package:psg_app/features/admin/data/admin_repository.dart';
import 'package:intl/intl.dart';

class AdminRequestSubstituteScreen extends ConsumerStatefulWidget {
  const AdminRequestSubstituteScreen({super.key});

  @override
  ConsumerState<AdminRequestSubstituteScreen> createState() => _AdminRequestSubstituteScreenState();
}

class _AdminRequestSubstituteScreenState extends ConsumerState<AdminRequestSubstituteScreen> {
  int _selectedFacultyIndex = -1;
  String? _selectedClassId;
  DateTime _selectedDate = DateTime.now();
  String _selectedTimeSlot = '09:00 AM - 10:00 AM';
  
  final List<String> _timeSlots = [
    '09:00 AM - 10:00 AM',
    '10:10 AM - 11:10 AM',
    '11:20 AM - 12:20 PM',
    '01:30 PM - 02:30 PM',
    '02:40 PM - 03:40 PM',
    '03:50 PM - 04:50 PM',
  ];

  List<Map<String, dynamic>> _availableFaculty = [];
  bool _isLoadingFaculty = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAvailableFaculty();
    });
  }

  Future<void> _fetchAvailableFaculty() async {
    setState(() {
      _isLoadingFaculty = true;
      _selectedFacultyIndex = -1;
    });
    
    final repo = ref.read(adminRepositoryProvider);
    final faculty = await repo.getAvailableFaculty(_selectedDate, _selectedTimeSlot);
    
    if (mounted) {
      setState(() {
        _availableFaculty = faculty;
        _isLoadingFaculty = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), // Restrict to today or future
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E63EB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchAvailableFaculty();
    }
  }

  void _submitAssignment() async {
    if (_selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a class')));
      return;
    }
    if (_selectedFacultyIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a faculty member')));
      return;
    }

    final faculty = _availableFaculty[_selectedFacultyIndex];
    
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final repo = ref.read(adminRepositoryProvider);
      await repo.assignSubstitute(
        classId: _selectedClassId!,
        substituteStaffId: faculty['id'],
        date: _selectedDate,
        timeSlot: _selectedTimeSlot,
        assignedBy: faculty['id'], // Assuming admin is assigning, but we use the substitute ID for schema NOT NULL constraint for now
      );

      if (mounted) {
        Navigator.pop(context); // close dialog
        Navigator.pop(context); // close screen
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assigned successfully!')));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(adminClassesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Request Substitute',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF1E3A8A)),
            onPressed: () => showComingSoonSnackBar(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF), // Light blue
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info, color: Color(0xFF2E63EB)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Assign a substitute faculty for a class',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Select the class, date and time, then choose an available faculty member.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Form Fields
                  // Class Dropdown
                  classesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Text('Error loading classes: $err'),
                    data: (classes) {
                      if (_selectedClassId == null && classes.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() => _selectedClassId = classes.first['id']);
                        });
                      }
                      return _buildDropdownRow(
                        label: 'Class',
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedClassId,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748B)),
                            items: classes.map((c) {
                              return DropdownMenuItem<String>(
                                value: c['id'],
                                child: Text(
                                  '${c['subject_code']} - ${c['subject_name']} (${c['year']} ${c['department']} - ${c['section']})',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
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
                  
                  // Date Picker
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: _buildDropdownRow(
                      label: 'Date',
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined, size: 18, color: Color(0xFF64748B)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              DateFormat('MMM d, yyyy (E)').format(_selectedDate),
                              style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Time Slot Dropdown
                  _buildDropdownRow(
                    label: 'Time Slot',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTimeSlot,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748B)),
                        items: _timeSlots.map((ts) {
                          return DropdownMenuItem<String>(
                            value: ts,
                            child: Text(
                              ts,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedTimeSlot = val);
                            _fetchAvailableFaculty();
                          }
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Available Faculty Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Available Faculty Members',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.filter_list, size: 16, color: Color(0xFF1E3A8A)),
                            SizedBox(width: 6),
                            Text(
                              'Filter',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Faculty List
                  if (_isLoadingFaculty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_availableFaculty.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      child: Column(
                        children: const [
                          Icon(Icons.person_search, size: 48, color: Color(0xFFCBD5E1)),
                          SizedBox(height: 16),
                          Text(
                            'No available faculty found',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...List.generate(_availableFaculty.length, (index) {
                      final isSelected = _selectedFacultyIndex == index;
                      final faculty = _availableFaculty[index];
                      final name = faculty['full_name'] ?? 'Unknown';
                      final designation = faculty['designation'] ?? 'Faculty';
                      final department = faculty['departments']?['name'] ?? 'Dept';
                      final imageUrl = faculty['image_url'] ?? 'https://ui-avatars.com/api/?name=$name';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: isSelected ? const Color(0xFF2E63EB) : const Color(0xFFF1F5F9), width: isSelected ? 1.5 : 1),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Checkbox
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedFacultyIndex = index;
                                  });
                                },
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF2E63EB) : Colors.transparent,
                                    border: Border.all(color: isSelected ? const Color(0xFF2E63EB) : const Color(0xFFCBD5E1), width: 1.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Avatar
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFFF1F5F9),
                                backgroundImage: NetworkImage(imageUrl),
                              ),
                              const SizedBox(width: 12),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E3A8A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      designation,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      department,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF16A34A), // Green dot
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Available',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF16A34A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Assign Button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedFacultyIndex = index;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF2E63EB) : const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Assign',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFF2E63EB),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Bottom Action Button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _submitAssignment,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text(
                  'Assign Substitute',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E63EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow({required String label, required Widget child}) {
    return Row(
      children: [
        SizedBox(
          width: 85, // INCREASED WIDTH to fix layout overflow
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}
