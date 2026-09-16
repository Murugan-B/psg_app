import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:psg_app/core/auth/auth_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String role;
  const RegisterScreen({super.key, required this.role});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Role specific controllers
  final _rollNumberController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _departmentController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rollNumberController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      
      final result = await authRepo.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        role: widget.role,
        rollNumber: widget.role == 'student' ? _rollNumberController.text.trim() : null,
        employeeId: widget.role == 'faculty' ? _employeeIdController.text.trim() : null,
        department: (widget.role == 'student' || widget.role == 'faculty') ? _departmentController.text.trim() : null,
      );

      if (mounted) {
        if (result.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          // Wait for trigger to create profile, then go to login or main
          _navigateToRoleHome(widget.role);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration failed.')),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToRoleHome(String role) {
    switch (role) {
      case 'student':
        context.go('/student_main');
        break;
      case 'faculty':
        context.go('/faculty_main');
        break;
      case 'admin':
        context.go('/admin_main');
        break;
      default:
        context.go('/student_main');
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleDisplay = switch (widget.role) {
      'faculty' => 'Faculty',
      'admin' => 'Admin',
      _ => 'Student',
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0F172A), size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F347F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Edu',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F347F),
                              ),
                            ),
                            TextSpan(
                              text: 'Track',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E63EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create $roleDisplay Account',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Full Name
                Text('Full Name', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  decoration: _inputDecoration('Enter your full name', Icons.person_outline),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter your full name' : null,
                ),
                const SizedBox(height: 16),

                // Email
                Text('Email Address', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Enter your email', Icons.mail_outline),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter your email' : null,
                ),
                const SizedBox(height: 16),

                // Password
                Text('Password', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF94A3B8)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: const Color(0xFF94A3B8),
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E63EB), width: 2)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  validator: (value) => value != null && value.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 16),

                // Role Specific Fields
                if (widget.role == 'student') ...[
                  Text('Roll Number', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _rollNumberController,
                    decoration: _inputDecoration('Enter your roll number', Icons.badge_outlined),
                  ),
                  const SizedBox(height: 16),
                ],

                if (widget.role == 'faculty') ...[
                  Text('Employee ID', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _employeeIdController,
                    decoration: _inputDecoration('Enter your employee ID', Icons.badge_outlined),
                  ),
                  const SizedBox(height: 16),
                ],

                if (widget.role == 'student' || widget.role == 'faculty') ...[
                  Text('Department', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _departmentController,
                    decoration: _inputDecoration('E.g. CSE, ECE, IT', Icons.business_outlined),
                  ),
                  const SizedBox(height: 32),
                ],

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E63EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E63EB), width: 2)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }
}
