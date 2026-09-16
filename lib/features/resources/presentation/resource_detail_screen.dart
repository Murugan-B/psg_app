import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:psg_app/features/resources/data/resource_repository.dart';
import 'package:psg_app/features/resources/domain/models/learning_resource_model.dart';
import 'package:psg_app/features/resources/providers/resource_providers.dart';

class ResourceDetailScreen extends ConsumerWidget {
  final String resourceId;

  const ResourceDetailScreen({super.key, required this.resourceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourceAsync = ref.watch(resourceDetailProvider(resourceId));
    final userId = ref.watch(currentUserIdProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Resource', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (userId != null)
            IconButton(
              icon: Icon(Icons.bookmark_border),
              onPressed: () => _recordView(ref, userId),
            ),
        ],
      ),
      body: resourceAsync.when(
        data: (resource) => resource == null
            ? Center(child: Text('Resource not found', style: TextStyle(color: Color(0xFF94A3B8))))
            : _buildContent(context, ref, resource, userId),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err', style: TextStyle(color: Color(0xFF64748B)))),
      ),
    );
  }

  void _recordView(WidgetRef ref, String userId) {
    final repository = ref.read(resourceRepositoryProvider);
    repository.recordResourceView(
      resourceId: resourceId,
      studentId: userId,
      completed: true,
      completionPercentage: 100,
      viewDurationSeconds: 0,
    );
    ref.invalidate(resourceDetailProvider(resourceId));
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, LearningResourceModel resource, String? userId) {
    final icon = _getResourceIcon(resource);
    final color = _getResourceColor(resource);
    final progress = resource.studentProgress ?? 0;
    final completed = resource.studentCompleted ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 44),
          ),
          const SizedBox(height: 20),
          Text(
            resource.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          if (resource.skill != null || resource.domain != null || resource.resourceType != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (resource.skill != null) _buildChip(resource.skill!.name, _C.purple),
                  if (resource.domain != null) _buildChip(resource.domain!.name, _C.indigo),
                  if (resource.resourceType != null) _buildChip(resource.resourceType!.name, _C.blue),
                  if (resource.difficultyLevel != null)
                    _buildChip(resource.difficultyLevel!, _C.orange),
                ],
              ),
            ),
          if (resource.description != null && resource.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(resource.description!, style: TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.5)),
            ),
          const SizedBox(height: 24),
          if (resource.estimatedDurationMinutes != null)
            Row(
              children: [
                Icon(Icons.access_time, size: 20, color: Color(0xFF94A3B8)),
                SizedBox(width: 8),
                Text('${resource.estimatedDurationMinutes} min read', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              ],
            ),
          if (progress > 0)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Your progress', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                      Text(completed ? 'Completed!' : '${progress.toInt()}%',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 8,
                    backgroundColor: Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchUrl(context, resource.url),
              icon: Icon(resource.isVideo ? Icons.play_arrow : Icons.open_in_new, color: Colors.white),
              label: Text(
                resource.isVideo ? 'Watch Now' : 'Open Resource',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color)),
    );
  }

  IconData _getResourceIcon(LearningResourceModel resource) {
    if (resource.isVideo) return Icons.play_circle;
    if (resource.isArticle) return Icons.article;
    if (resource.isDocument) return Icons.description;
    if (resource.isInteractive) return Icons.quiz;
    return Icons.link;
  }

  Color _getResourceColor(LearningResourceModel resource) {
    if (resource.isVideo) return Color(0xFFEF4444);
    if (resource.isArticle) return _C.indigo;
    if (resource.isDocument) return Color(0xFFF59E0B);
    if (resource.isInteractive) return _C.purple;
    return Color(0xFF3B82F6);
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        throw Exception('Could not launch URL');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open resource: $e'), backgroundColor: _C.red),
      );
    }
  }
}

class _C {
  static const purple = Color(0xFF8B5CF6);
  static const indigo = Color(0xFF6366F1);
  static const blue = Color(0xFF3B82F6);
  static const orange = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
}
