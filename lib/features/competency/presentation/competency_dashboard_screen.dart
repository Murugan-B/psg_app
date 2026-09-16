import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:psg_app/features/competency/domain/models/student_competency_model.dart';
import 'package:psg_app/features/competency/providers/competency_providers.dart';

class _C {
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const borderLight = Color(0xFFF1F5F9);
  static const textTertiary = Color(0xFF94A3B8);
  static const green = Color(0xFF10B981);
  static const orange = Color(0xFFF59E0B);
  static const blue = Color(0xFF3B82F6);
  static const red = Color(0xFFEF4444);
  static const indigo = Color(0xFF6366F1);
}

class CompetencyDashboardScreen extends ConsumerWidget {
  const CompetencyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final competenciesAsync = ref.watch(myCompetenciesProvider);

    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: _C.surface,
        elevation: 0,
        title: const Text(
          'My Competency Progress',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: competenciesAsync.when(
        data: (competencies) => _buildContent(context, ref, competencies),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _buildError(err),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<StudentCompetencyModel> competencies) {
    if (competencies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 64, color: Color(0xFFCBD5E1)),
            SizedBox(height: 16),
            Text('No competency data yet', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
            SizedBox(height: 8),
            Text('Complete assessments to track your progress',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
          ],
        ),
      );
    }

    final totalSkills = competencies.length;
    final completedSkills = competencies.where((c) => (c.progressPercent ?? 0) > 0).length;
    final avgProgress = competencies.isEmpty
        ? 0.0
        : competencies.fold<double>(0, (sum, c) => sum + (c.progressPercent ?? 0)) / totalSkills;
    final overallPercent = (completedSkills / totalSkills * 100).clamp(0, 100).toDouble();

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myCompetenciesProvider),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Progress Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF2E63EB)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${overallPercent.toInt()}%',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Overall Competency',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: overallPercent / 100,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completedSkills of $totalSkills skills with progress',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Average progress info
            if (avgProgress > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Average progress: ${avgProgress.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
              ),

            // Competency by Level
            Text('By Competency Level', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ..._buildLevelBreakdown(competencies),

            const SizedBox(height: 24),
            Text('All Skills', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: competencies.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildCompetencyCard(context, competencies[index]),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLevelBreakdown(List<StudentCompetencyModel> competencies) {
    final levelCounts = <String, int>{};
    for (final c in competencies) {
      final level = c.competencyLevel?.name ?? 'Unassessed';
      levelCounts[level] = (levelCounts[level] ?? 0) + 1;
    }

    return levelCounts.entries.map((entry) {
      final color = switch (entry.key) {
        'Beginner' => _C.indigo,
        'Novice' => _C.green,
        'Intermediate' => _C.orange,
        'Advanced' => _C.blue,
        'Expert' => _C.red,
        _ => _C.textTertiary,
      };

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                Text('${entry.value} skills', style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: entry.value / competencies.length,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildCompetencyCard(BuildContext context, StudentCompetencyModel competency) {
    final level = competency.competencyLevel;
    final progress = competency.progressPercent ?? 0;

    final levelColor = level?.name != null
        ? switch (level!.name) {
            'Beginner' => _C.indigo,
            'Novice' => _C.green,
            'Intermediate' => _C.orange,
            'Advanced' => _C.blue,
            'Expert' => _C.red,
            _ => _C.textTertiary,
          }
        : _C.textTertiary;

    final lastAssessed = competency.lastAssessedAt != null
        ? DateFormat('MMM d, yyyy').format(competency.lastAssessedAt!)
        : 'Not yet assessed';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.borderLight),
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
              Expanded(
                child: Text(
                  competency.skill?.name ?? 'Unknown Skill',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ),
              if (level != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    level.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: levelColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${competency.skill?.domain?.name ?? 'Unknown Domain'} • ${competency.skill?.difficultyLevel.toLowerCase() ?? ''}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress / 100,
            minHeight: 8,
            backgroundColor: _C.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(levelColor),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$progress% proficiency', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              Text('Last assessed: $lastAssessed', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ],
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
