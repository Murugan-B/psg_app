import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _selectedRole = 'student'; // Default selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 24.0),
            child: Center(
              child: Text(
                'Step 1 of 2',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'Select Your Role',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Choose how you want to continue',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Role Cards
                        _buildRoleCard(
                          roleId: 'student',
                          title: 'Student',
                          description: 'Mark attendance, view timetable,\ntrack your progress',
                          icon: Icons.school,
                        ),
                        const SizedBox(height: 16),
                        
                        _buildRoleCard(
                          roleId: 'faculty',
                          title: 'Faculty / Staff',
                          description: 'Generate OTP, manage attendance,\nview class details',
                          icon: Icons.people_alt,
                        ),
                        const SizedBox(height: 16),
                        
                        _buildRoleCard(
                          roleId: 'admin',
                          title: 'Institute Admin',
                          description: 'Manage timetable, staff, attendance\nand more',
                          icon: Icons.account_balance,
                        ),
                        
                        const Spacer(),
                        const SizedBox(height: 16),
                        
                        // Continue Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              context.push('/login', extra: _selectedRole);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E63EB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String roleId,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == roleId;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = roleId;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF475569),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isSelected ? const Color(0xFF60A5FA) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
