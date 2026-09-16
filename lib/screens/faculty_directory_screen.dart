import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psg_app/features/admin/providers/admin_providers.dart';
import 'package:psg_app/screens/faculty_profile_screen.dart';
import 'package:psg_app/widgets/call_panel_bottom_sheet.dart';

class FacultyDirectoryScreen extends ConsumerStatefulWidget {
  final String role;
  final bool isEmbedded;
  const FacultyDirectoryScreen({super.key, this.role = 'faculty', this.isEmbedded = false});

  @override
  ConsumerState<FacultyDirectoryScreen> createState() => _FacultyDirectoryScreenState();
}

class _FacultyDirectoryScreenState extends ConsumerState<FacultyDirectoryScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Computer Science', 'Mathematics', 'Physics', 'Chemistry'];

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
          'Faculty / Staff Directory',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Subtitle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Find and connect with your faculty members',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by name, department or subject',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune, color: Color(0xFF475569)),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Filter Chips
            SizedBox(
              height: 36,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilterIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2E63EB) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Faculty List
            Expanded(
              child: staffAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (staffList) {
                  var filteredList = staffList;
                  if (_selectedFilterIndex != 0) {
                    final filterName = _filters[_selectedFilterIndex];
                    filteredList = staffList.where((staff) {
                      final deptName = staff['departments']?['name'] ?? staff['department'] ?? '';
                      return deptName.toString().toLowerCase().contains(filterName.toLowerCase());
                    }).toList();
                  }

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.contact_mail_outlined, size: 48, color: Color(0xFFCBD5E1)),
                          SizedBox(height: 16),
                          Text(
                            'No faculty members found',
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
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final staff = filteredList[index];
                      final name = staff['full_name'] ?? 'Unknown Staff';
                      final designation = staff['designation'] ?? 'Faculty';
                      final deptName = staff['departments']?['name'] ?? staff['department'] ?? 'Department';
                      final imageUrl = staff['image_url'] ?? 'https://ui-avatars.com/api/?name=$name';

                      return _buildFacultyCard(
                        name: name,
                        department: deptName,
                        role: designation,
                        imageUrl: imageUrl,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildFacultyCard({
    required String name,
    required String role,
    required String department,
    required String imageUrl,
    String? tag,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FacultyProfileScreen(
              name: name,
              role: role,
              department: department,
              imageUrl: imageUrl,
              tag: tag,
            ),
          ),
        );
      },
      child: Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Image
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFF1F5F9),
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (tag != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7), // Light green
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  department,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          
          // Action Button
          GestureDetector(
            onTap: () {
              showCallPanel(context, name, '+91 98765 43210');
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF), // Light blue
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone, color: Color(0xFF2E63EB), size: 20),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
