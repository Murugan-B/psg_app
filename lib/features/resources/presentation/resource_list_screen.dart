import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:psg_app/features/resources/domain/models/learning_resource_model.dart';
import 'package:psg_app/features/resources/providers/resource_providers.dart';
import 'package:psg_app/features/resources/presentation/resource_detail_screen.dart';

class _C {
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const borderLight = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);
  static const green = Color(0xFF10B981);
  static const purple = Color(0xFF8B5CF6);
  static const indigo = Color(0xFF6366F1);
}

class ResourceListScreen extends ConsumerWidget {
  const ResourceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(userResourcesProvider);

    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: _C.surface,
        title: const Text('Learning Resources', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: resourcesAsync.when(
        data: (resources) => _buildContent(context, ref, resources),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err', style: TextStyle(color: _C.textSecondary))),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<LearningResourceModel> resources) {
    if (resources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 64, color: _C.textTertiary),
            SizedBox(height: 16),
            Text('No resources available yet', style: TextStyle(color: _C.textSecondary, fontSize: 16)),
            SizedBox(height: 8),
            Text('New resources are added regularly. Check back soon!',
                style: TextStyle(color: _C.textTertiary, fontSize: 13)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userResourcesProvider);
        ref.invalidate(allResourcesProvider);
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: resources.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildResourceCard(context, resources[index]),
      ),
    );
  }

  Widget _buildResourceCard(BuildContext context, LearningResourceModel resource) {
    final icon = _getResourceIcon(resource);
    final color = _getResourceColor(resource);
    final progress = resource.studentProgress ?? 0;
    final completed = resource.studentCompleted ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ResourceDetailScreen(resourceId: resource.id)),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.borderLight),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(resource.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _C.textPrimary)),
                      if (resource.skill != null) ...[
                        SizedBox(height: 2),
                        Text(resource.skill!.name, style: TextStyle(fontSize: 12, color: _C.textTertiary)),
                      ],
                    ],
                  ),
                ),
                if (completed)
                  const Icon(Icons.check_circle, color: _C.green, size: 20),
              ],
            ),
            if (resource.description != null && resource.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  resource.description!,
                  style: TextStyle(fontSize: 13, color: _C.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (progress > 0)
              Padding(
                padding: EdgeInsets.only(top: resource.description != null ? 8 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 6,
                      backgroundColor: _C.borderLight,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                    SizedBox(height: 4),
                    Text('${progress.toInt()}% completed', style: TextStyle(fontSize: 11, color: _C.textTertiary)),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.only(top: progress > 0 ? 8 : 8),
              child: Row(
                children: [
                  if (resource.resourceType != null)
                    Text(resource.resourceType!.name, style: TextStyle(fontSize: 11, color: _C.textTertiary)),
                  if (resource.estimatedDurationMinutes != null) ...[
                    SizedBox(width: 8),
                    Icon(Icons.access_time, size: 14, color: _C.textTertiary),
                    SizedBox(width: 4),
                    Text('${resource.estimatedDurationMinutes} min', style: TextStyle(fontSize: 11, color: _C.textTertiary)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
}
