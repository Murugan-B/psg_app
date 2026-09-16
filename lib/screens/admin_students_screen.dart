import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:psg_app/screens/admin_faculty_screen.dart';
import 'package:psg_app/screens/admin_timetable_screen.dart';
import 'package:psg_app/features/admin/providers/admin_providers.dart';
import 'package:psg_app/features/admin/data/admin_repository.dart';

class AdminStudentsScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  const AdminStudentsScreen({super.key, this.isEmbedded = false});

  @override
  ConsumerState<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends ConsumerState<AdminStudentsScreen> {
  final int _bottomNavIndex = 1;
  int _selectedChipIndex = 0;
  final List<String> _chips = ['All', 'I Year', 'II Year', 'III Year', 'IV Year'];

  void _showAddStudentModal(BuildContext context, {Map<String, dynamic>? existingStudent}) async {
    final isEditing = existingStudent != null;
    final nameController = TextEditingController(text: existingStudent?['full_name'] ?? '');
    final rollNumberController = TextEditingController(text: existingStudent?['employee_id'] ?? '');
    final emailController = TextEditingController(); // Profiles table does not have email
    final phoneController = TextEditingController(text: existingStudent?['phone'] ?? '');

    String selectedDept = existingStudent?['department_id'] ?? 'd0000000-0000-0000-0000-000000000001'; // Default CSE
    String selectedBatch = existingStudent?['batch'] ?? '2023-2027';
    String selectedYear = existingStudent?['current_year'] ?? 'I Year';

    // Ensure valid dropdown values
    if (!['2021-2025', '2022-2026', '2023-2027', '2024-2028'].contains(selectedBatch)) {
      selectedBatch = '2023-2027';
    }
    if (!['d0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003'].contains(selectedDept)) {
      selectedDept = 'd0000000-0000-0000-0000-000000000001';
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Edit Student' : 'Add New Student',
                        style: const TextStyle(
                          fontSize: 20,
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: rollNumberController,
                    decoration: InputDecoration(
                      labelText: 'Roll Number',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedDept,
                    decoration: InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'd0000000-0000-0000-0000-000000000001', child: Text('CSE')),
                      DropdownMenuItem(value: 'd0000000-0000-0000-0000-000000000002', child: Text('IT')),
                      DropdownMenuItem(value: 'd0000000-0000-0000-0000-000000000003', child: Text('ECE')),
                    ],
                    onChanged: (val) => setModalState(() => selectedDept = val!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedYear,
                          decoration: InputDecoration(
                            labelText: 'Current Year',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: _chips.skip(1).map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                          onChanged: (val) => setModalState(() => selectedYear = val!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedBatch,
                          decoration: InputDecoration(
                            labelText: 'Batch',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: const [
                            DropdownMenuItem(value: '2021-2025', child: Text('2021-2025')),
                            DropdownMenuItem(value: '2022-2026', child: Text('2022-2026')),
                            DropdownMenuItem(value: '2023-2027', child: Text('2023-2027')),
                            DropdownMenuItem(value: '2024-2028', child: Text('2024-2028')),
                          ],
                          onChanged: (val) => setModalState(() => selectedBatch = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty || rollNumberController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill required fields')));
                          return;
                        }
                        
                        try {
                          final repo = ref.read(adminRepositoryProvider);
                          
                          if (isEditing) {
                            await repo.updateProfile(existingStudent!['id'], {
                              'full_name': nameController.text,
                              'employee_id': rollNumberController.text,
                              'phone': phoneController.text,
                              'department_id': selectedDept,
                              'batch': selectedBatch,
                              'current_year': selectedYear,
                            });
                          } else {
                            await repo.createStudentProfile(
                              id: const Uuid().v4(),
                              fullName: nameController.text,
                              rollNumber: rollNumberController.text,
                              email: emailController.text,
                              phone: phoneController.text,
                              departmentId: selectedDept,
                              batch: selectedBatch,
                              currentYear: selectedYear,
                            );
                          }
                          
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Student updated successfully' : 'Student added successfully')));
                            ref.invalidate(adminStudentListProvider);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E63EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(isEditing ? 'Save Changes' : 'Add Student', style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  void _confirmDeleteStudent(Map<String, dynamic> student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student['full_name']}?'),
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

    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.deleteProfile(student['id']);
      ref.invalidate(adminStudentListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student deleted successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(adminStudentListProvider);

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
          'Student Management',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E63EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  onPressed: () => _showAddStudentModal(context),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar & Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search students by name or roll no',
                        hintStyle: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(_chips.length, (index) {
                final isSelected = _selectedChipIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedChipIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2E63EB) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _chips[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          
          // Students List
          Expanded(
            child: studentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (allStudents) {
                // Filter by year if needed
                var filtered = allStudents;
                if (_selectedChipIndex > 0) {
                  final selectedYear = _chips[_selectedChipIndex];
                  filtered = allStudents.where((s) => s['current_year'] == selectedYear).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.people_outline, size: 48, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 16),
                        Text('No students found', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final student = filtered[index];
                    final isActive = student['is_active'] ?? true;
                    final deptName = student['departments']?['name'] ?? 'Unknown Dept';
                    final rollNo = student['employee_id'] ?? 'Unknown Roll';
                    
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFF1F5F9)),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFFF1F5F9),
                            backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=${student['full_name']}'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student['full_name'] ?? 'Unknown',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  rollNo,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  deptName,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showAddStudentModal(context, existingStudent: student);
                                  } else if (value == 'delete') {
                                    _confirmDeleteStudent(student);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'edit', child: Text('Edit Student')),
                                  const PopupMenuItem(value: 'delete', child: Text('Delete Student', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isActive ? const Color(0xFF16A34A) : const Color(0xFFC2410C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Pagination Area
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            color: Colors.white,
            alignment: Alignment.centerLeft,
            child: const Text(
              'Manage Students',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
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
          currentIndex: _bottomNavIndex,
          onTap: (index) {
            if (index == 0) {
              Navigator.popUntil(context, (route) => route.isFirst);
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AdminFacultyScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
            } else if (index == 3) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AdminTimetableScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2E63EB),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Students'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: 'Faculty'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Timetable'),
            BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
          ],
        ),
      ),
    );
  }
}
