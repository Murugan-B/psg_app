import 'package:flutter/material.dart';
import 'package:psg_app/utils/ui_helpers.dart';
import 'package:psg_app/widgets/call_panel_bottom_sheet.dart';

class FacultyProfileScreen extends StatefulWidget {
  final String name;
  final String role;
  final String department;
  final String imageUrl;
  final String? tag;

  const FacultyProfileScreen({
    super.key,
    required this.name,
    required this.role,
    required this.department,
    required this.imageUrl,
    this.tag,
  });

  @override
  State<FacultyProfileScreen> createState() => _FacultyProfileScreenState();
}

class _FacultyProfileScreenState extends State<FacultyProfileScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Generate a placeholder email based on name
    final nameParts = widget.name.replaceAll('Dr. ', '').replaceAll('Prof. ', '').replaceAll('Mr. ', '').replaceAll('Ms. ', '').toLowerCase().split(' ');
    final email = '${nameParts.first.substring(0, 1)}.${nameParts.last}@eduinst.ac.in';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFF6FF), // Light blue to match the top section
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Staff Profile',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF0F172A)),
            onPressed: () => showComingSoonSnackBar(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Header Section (Light Blue Background)
          Container(
            width: double.infinity,
            color: const Color(0xFFEFF6FF),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFE2E8F0),
                        backgroundImage: NetworkImage(widget.imageUrl),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Name and Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              if (widget.tag != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    widget.tag!,
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
                            widget.role,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.department,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Contact Info lines
                          _buildContactInfoLine(Icons.domain, 'Department of CSE'),
                          const SizedBox(height: 6),
                          _buildContactInfoLine(Icons.email_outlined, email),
                          const SizedBox(height: 6),
                          _buildContactInfoLine(Icons.phone_outlined, '+91 98765 43210'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Quote Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.format_quote, color: Color(0xFF2E63EB), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '"Empowering students through technology and curiosity."',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF1E3A8A).withValues(alpha: 0.8),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Content Area
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Tabs
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(child: _buildTab(0, 'About')),
                        Expanded(child: _buildTab(1, 'Subjects')),
                        Expanded(child: _buildTab(2, 'Classes')),
                        Expanded(child: _buildTab(3, 'Availability')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // About Content
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${widget.name} has over 15 years of teaching experience in Computer Science and Engineering. His areas of interest include Data Structures, Algorithms, and Artificial Intelligence.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF475569),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Detail List
                  _buildDetailItem(Icons.school, 'Ph.D. in Computer Science'),
                  const SizedBox(height: 16),
                  _buildDetailItem(Icons.description, '15+ Years of Experience'),
                  const SizedBox(height: 16),
                  _buildDetailItem(Icons.people_alt, 'Head of Department (CSE)'),
                  const SizedBox(height: 16),
                  _buildDetailItem(Icons.location_on, 'Room No. A201, Main Block'),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), // Extra padding for SafeArea
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
        child: SafeArea(
          child: Row(
            children: [
              Expanded(child: _buildActionButton(Icons.phone, 'Call', () {
                showCallPanel(context, widget.name, '+91 98765 43210');
              })),
              const SizedBox(width: 12),
              Expanded(child: _buildActionButton(Icons.email, 'Email', () {})),
              const SizedBox(width: 12),
              Expanded(child: _buildActionButton(Icons.message, 'Message', () {})),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfoLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E63EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: Color(0xFF2E63EB), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2E63EB)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E63EB),
            ),
          ),
        ],
      ),
    );
  }
}
