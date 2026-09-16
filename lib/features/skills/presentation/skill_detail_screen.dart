import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:psg_app/features/skills/domain/models/skill_model.dart';
import 'package:psg_app/features/skills/providers/skill_providers.dart';

class SkillDetailScreen extends ConsumerWidget {
  final String skillId;
  const SkillDetailScreen({super.key, required this.skillId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillAsync = ref.watch(skillDetailProvider(skillId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Skill Detail',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
      ),
      body: skillAsync.when(
        data: (skill) {
          if (skill == null) {
            return _buildNotFound();
          }
          return _buildSkillDetail(context, skill);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _buildError(err),
      ),
    );
  }

  Widget _buildSkillDetail(BuildContext context, SkillModel skill) {
    final difficultyColor = switch (skill.difficultyLevel) {
      'BEGINNER' => const Color(0xFF10B981),
      'INTERMEDIATE' => const Color(0xFFF59E0B),
      'ADVANCED' => const Color(0xFFEF4444),
      _ => const Color(0xFF64748B),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.star, color: Color(0xFF2E63EB), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        skill.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (skill.domain != null) ...[
                  Text(
                     'Domain: ${skill.domain!.name}',
                     style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 12),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: difficultyColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Difficulty: ${skill.difficultyLevel.toLowerCase().toUpperCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: difficultyColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (skill.description != null) ...[
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              skill.description!,
              style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.6),
            ),
            const SizedBox(height: 20),
          ],

          Text(
            'Your Progress',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, child) {
              final progress = skill.studentProgress;
              final competencyLevel = skill.studentCompetencyLevel;

              if (progress == null) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.info_outline, size: 40, color: Color(0xFF94A3B8)),
                      SizedBox(height: 12),
                      Text(
                        'No progress data yet. Complete assessments to track your competency.',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress: ${progress.toInt()}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (competencyLevel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            competencyLevel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E63EB),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(difficultyColor),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Skill not found',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildError(dynamic err) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          Text('Error: $err', style: const TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}
