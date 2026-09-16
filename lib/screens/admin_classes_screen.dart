import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psg_app/features/admin/providers/admin_providers.dart';
import 'package:psg_app/features/admin/data/admin_repository.dart';

class AdminClassesScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  const AdminClassesScreen({super.key, this.isEmbedded = false});

  @override
  ConsumerState<AdminClassesScreen> createState() => _AdminClassesScreenState();
}

class _AdminClassesScreenState extends ConsumerState<AdminClassesScreen> {
  void _showAddClassModal({Map<String, dynamic>? existingClass}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddClassModal(existingClass: existingClass),
    );
  }

  void _confirmDeleteClass(Map<String, dynamic> classData) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Are you sure you want to delete ${classData['subject_name']}? This will also delete all associated timetable slots.'),
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
      await repo.deleteClass(classData['id']);
      ref.invalidate(adminClassesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class deleted successfully')));
      }
    } catch (e) {
      if (mounted) {
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
        leading: widget.isEmbedded ? null : IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Classes',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: classesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (classes) {
          if (classes.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final c = classes[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '${c['subject_code']} - ${c['subject_name']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showAddClassModal(existingClass: c);
                            } else if (value == 'delete') {
                              _confirmDeleteClass(c);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit Class')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete Class', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        c['department'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E63EB),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.school, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text(
                          'Year: ${c['year']} | Section: ${c['section']}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClassModal,
        backgroundColor: const Color(0xFF2E63EB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.class_outlined, size: 64, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          const Text(
            'No Classes Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to create a new class.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class AddClassModal extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existingClass;
  const AddClassModal({super.key, this.existingClass});

  @override
  ConsumerState<AddClassModal> createState() => _AddClassModalState();
}

class _AddClassModalState extends ConsumerState<AddClassModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _subjectCodeController;
  late TextEditingController _subjectNameController;
  late TextEditingController _departmentController;
  late TextEditingController _yearController;
  late TextEditingController _sectionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subjectCodeController = TextEditingController(text: widget.existingClass?['subject_code'] ?? '');
    _subjectNameController = TextEditingController(text: widget.existingClass?['subject_name'] ?? '');
    _departmentController = TextEditingController(text: widget.existingClass?['department'] ?? '');
    _yearController = TextEditingController(text: widget.existingClass?['year'] ?? '');
    _sectionController = TextEditingController(text: widget.existingClass?['section'] ?? '');
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(adminRepositoryProvider);
      
      if (widget.existingClass == null) {
        await repo.createClass(
          subjectCode: _subjectCodeController.text.trim(),
          subjectName: _subjectNameController.text.trim(),
          department: _departmentController.text.trim(),
          year: _yearController.text.trim(),
          section: _sectionController.text.trim(),
        );
      } else {
        await repo.updateClass(widget.existingClass!['id'], {
          'subject_code': _subjectCodeController.text.trim(),
          'subject_name': _subjectNameController.text.trim(),
          'department': _departmentController.text.trim(),
          'year': _yearController.text.trim(),
          'section': _sectionController.text.trim(),
        });
      }
      
      ref.invalidate(adminClassesProvider);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.existingClass == null ? 'Class created successfully!' : 'Class updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _subjectCodeController.dispose();
    _subjectNameController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingClass != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Class' : 'Create New Class',
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
              const SizedBox(height: 16),
              _buildTextField(label: 'Subject Code', controller: _subjectCodeController),
              const SizedBox(height: 12),
              _buildTextField(label: 'Subject Name', controller: _subjectNameController),
              const SizedBox(height: 12),
              _buildTextField(label: 'Department', controller: _departmentController),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField(label: 'Year', controller: _yearController)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(label: 'Section', controller: _sectionController)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E63EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isEditing ? 'Save Changes' : 'Create Class', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2E63EB)),
            ),
          ),
          validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}
