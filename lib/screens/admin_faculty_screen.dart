import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:psg_app/screens/admin_students_screen.dart';
import 'package:psg_app/screens/admin_timetable_screen.dart';
import 'package:psg_app/features/admin/providers/admin_providers.dart';
import 'package:psg_app/features/admin/data/admin_repository.dart';

class AdminFacultyScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  const AdminFacultyScreen({super.key, this.isEmbedded = false});

  @override
  ConsumerState<AdminFacultyScreen> createState() => _AdminFacultyScreenState();
}

class _AdminFacultyScreenState extends ConsumerState<AdminFacultyScreen> {
  int _bottomNavIndex = 2; // Fixed to 2 for Faculty
  int _selectedChipIndex = 0;
  final List<String> _chips = ['All Staff', 'Teaching', 'Non-Teaching', 'HOD'];

  void _showAddStaffModal(BuildContext context, {Map<String, dynamic>? existingStaff}) async {
    final isEditing = existingStaff != null;
    final nameController = TextEditingController(text: existingStaff?['full_name'] ?? '');
    final employeeIdController = TextEditingController(text: existingStaff?['employee_id'] ?? '');
    final designationController = TextEditingController(text: existingStaff?['designation'] ?? '');
    final emailController = TextEditingController();
    final phoneController = TextEditingController(text: existingStaff?['phone'] ?? '');
    
    String selectedDept = existingStaff?['department_id'] ?? 'd0000000-0000-0000-0000-000000000001'; // Default CSE
    String selectedType = existingStaff?['staff_type'] ?? 'TEACHING';

    if (!['d0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000003'].contains(selectedDept)) {
      selectedDept = 'd0000000-0000-0000-0000-000000000001';
    }
    if (!['TEACHING', 'NON_TEACHING', 'HOD'].contains(selectedType)) {
      selectedType = 'TEACHING';
    }

    showModalBottomSheet(
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
              left: 20,
              right: 20,
              top: 20,
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
                        isEditing ? 'Edit Staff' : 'Add New Staff',
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
                    controller: employeeIdController,
                    decoration: InputDecoration(
                      labelText: 'Employee ID',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: designationController,
                    decoration: InputDecoration(
                      labelText: 'Designation (e.g. Asst. Professor)',
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
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: 'Staff Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'TEACHING', child: Text('Teaching')),
                      DropdownMenuItem(value: 'NON_TEACHING', child: Text('Non-Teaching')),
                      DropdownMenuItem(value: 'HOD', child: Text('HOD')),
                    ],
                    onChanged: (val) => setModalState(() => selectedType = val!),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty || employeeIdController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill required fields')));
                          return;
                        }
                        
                        try {
                          final repo = ref.read(adminRepositoryProvider);
                          
                          if (isEditing) {
                            await repo.updateProfile(existingStaff!['id'], {
                              'full_name': nameController.text,
                              'employee_id': employeeIdController.text,
                              'phone': phoneController.text,
                              'department_id': selectedDept,
                              'designation': designationController.text,
                              'staff_type': selectedType,
                            });
                          } else {
                            await repo.createStaffProfile(
                              id: const Uuid().v4(),
                              fullName: nameController.text,
                              employeeId: employeeIdController.text,
                              email: emailController.text,
                              phone: phoneController.text,
                              departmentId: selectedDept,
                              designation: designationController.text,
                              staffType: selectedType,
                            );
                          }
                          
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Staff updated successfully' : 'Staff added successfully')));
                            ref.invalidate(adminStaffListProvider);
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
                      child: Text(isEditing ? 'Save Changes' : 'Add Staff', style: const TextStyle(color: Colors.white, fontSize: 16)),
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

  void _confirmDeleteStaff(Map<String, dynamic> staff) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Staff'),
        content: Text('Are you sure you want to delete ${staff['full_name']}?'),
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
      await repo.deleteProfile(staff['id']);
      ref.invalidate(adminStaffListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Staff deleted successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(adminStaffListProvider);
    
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
          'Faculty Directory',
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
                  icon: const Icon(Icons.person_add, color: Colors.white, size: 20),
                  onPressed: () => _showAddStaffModal(context),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
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
                        hintText: 'Search faculty by name or dept',
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
                const SizedBox(width: 12),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Color(0xFF64748B)),
                    onPressed: () {
                      // Filter action
                    },
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
          
          // Staff List
          Expanded(
            child: staffAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (staffList) {
                // Filter locally by type if needed
                var filteredStaff = staffList;
                if (_selectedChipIndex == 1) {
                  filteredStaff = staffList.where((s) => s['staff_type'] == 'TEACHING').toList();
                } else if (_selectedChipIndex == 2) {
                  filteredStaff = staffList.where((s) => s['staff_type'] == 'NON_TEACHING').toList();
                } else if (_selectedChipIndex == 3) {
                  filteredStaff = staffList.where((s) => s['staff_type'] == 'HOD').toList();
                }

                if (filteredStaff.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person_off_outlined, size: 48, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 16),
                        Text(
                          'No staff members found',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: filteredStaff.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final staff = filteredStaff[index];
                    final isActive = staff['is_active'] ?? true;
                    final imageUrl = staff['image_url'] ?? 'https://ui-avatars.com/api/?name=${staff['full_name']}';
                    final deptName = staff['departments']?['name'] ?? staff['department'] ?? 'Unknown Dept';
                    final designation = staff['designation'] ?? 'Faculty';
                    
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
                          // Avatar
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFFF1F5F9),
                            backgroundImage: NetworkImage(imageUrl),
                          ),
                          const SizedBox(width: 16),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  staff['full_name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  designation,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  deptName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 14, color: Color(0xFF64748B)),
                                const SizedBox(width: 6),
                                Text(
                                  staff['phone'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Status and More Action
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showAddStaffModal(context, existingStaff: staff);
                              } else if (value == 'delete') {
                                _confirmDeleteStaff(staff);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'edit', child: Text('Edit Staff')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete Staff', style: TextStyle(color: Colors.red))),
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
              }, // end itemBuilder
            ); // end ListView.separated
          }, // end data
        ), // end staffAsync.when
      ), // end Expanded
          
          // Pagination Area
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            color: Colors.white,
            alignment: Alignment.centerLeft,
            child: const Text(
              'Manage Faculty Directory',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
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
          currentIndex: _bottomNavIndex,
          onTap: (index) {
            if (index == 0) {
              // Using popUntil to go back to Dashboard to avoid stacking
              Navigator.popUntil(context, (route) => route.isFirst);
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => const AdminStudentsScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
            } else if (index == 3) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => const AdminTimetableScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
            } else {
              setState(() {
                _bottomNavIndex = index;
              });
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
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Students',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt),
              label: 'Faculty',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Timetable',
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
}
