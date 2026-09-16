import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:psg_app/features/assessments/domain/models/assessment_model.dart';
import 'package:psg_app/features/assessments/domain/models/assessment_score_model.dart';
import 'package:psg_app/features/assessments/providers/assessment_providers.dart';
import 'package:psg_app/features/assessments/presentation/assessment_results_screen.dart';
import 'package:psg_app/features/assessments/presentation/take_assessment_screen.dart';

class _C {
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const borderLight = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);
  static const green = Color(0xFF10B981);
  static const orange = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
  static const indigo = Color(0xFF6366F1);
  static const blue = Color(0xFF3B82F6);
  static const purple = Color(0xFF8B5CF6);
}

class AssessmentListScreen extends ConsumerStatefulWidget {
  const AssessmentListScreen({super.key});

  @override
  ConsumerState<AssessmentListScreen> createState() => _AssessmentListScreenState();
}

class _AssessmentListScreenState extends ConsumerState<AssessmentListScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final assessmentsAsync = ref.watch(publishedAssessmentsProvider);
    final scoresAsync = ref.watch(myScoresProvider);

    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: _C.surface,
        title: const Text('Assessments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'attempted', child: Text('Attempted')),
            ],
          ),
        ],
      ),
      body: assessmentsAsync.when(
        data: (assessments) => scoresAsync.when(
          data: (scores) => _buildList(assessments, scores),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err', style: TextStyle(color: _C.textSecondary))),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err', style: TextStyle(color: _C.textSecondary))),
      ),
    );
  }

  Widget _buildList(List<AssessmentModel> assessments, List<AssessmentScoreModel> scores) {
    final scoreMap = {for (final s in scores) s.assessmentId: s};

    final filtered = assessments.where((a) {
      final score = scoreMap[a.id];
      switch (_filter) {
        case 'pending':
          return score == null || score.isPending || score.isNotAttempted;
        case 'attempted':
          return score != null && (score.isPassed || score.isFailed);
        default:
          return true;
      }
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 64, color: _C.textTertiary),
            SizedBox(height: 16),
            Text(
              _filter == 'all' ? 'No assessments available' : 'No assessments match the filter',
              style: TextStyle(color: _C.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(publishedAssessmentsProvider);
        ref.invalidate(myScoresProvider);
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: filtered.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildAssessmentCard(context, ref, filtered[index], scoreMap[filtered[index].id]),
      ),
    );
  }

  Widget _buildAssessmentCard(
    BuildContext context,
    WidgetRef ref,
    AssessmentModel assessment,
    AssessmentScoreModel? score,
  ) {
    final statusColor = score == null
        ? _C.indigo
        : score.isPassed
            ? _C.green
            : score.isFailed
                ? _C.red
                : _C.orange;

    final statusText = score == null
        ? 'Not attempted'
        : score.isPassed
            ? 'Passed'
            : score.isFailed
                ? 'Failed'
                : score.status;

    final dueDate = assessment.dueDate;
    final isOverdue = dueDate != null && dueDate.isBefore(DateTime.now());

    return GestureDetector(
      onTap: () async {
        final canAttempt = await ref.read(canAttemptProvider(assessment.id).future);
        final hasScore = score != null && (score.isPassed || score.isFailed);

        if (hasScore) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AssessmentResultsScreen(assessmentId: assessment.id),
            ),
          );
        } else if (canAttempt) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TakeAssessmentScreen(assessmentId: assessment.id),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You have used all ${assessment.maxAttempts} attempt(s) for this assessment.'),
              backgroundColor: _C.red,
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.borderLight),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    assessment.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ),
              ],
            ),
            if (assessment.description != null && assessment.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  assessment.description!,
                  style: TextStyle(fontSize: 13, color: _C.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (assessment.domain != null)
                  _buildChip(assessment.domain!.name, _C.blue),
                if (assessment.skill != null) ...[
                  const SizedBox(width: 8),
                  _buildChip(assessment.skill!.name, _C.purple),
                ],
                if (assessment.assessmentType != null) ...[
                  const SizedBox(width: 8),
                  _buildChip(assessment.assessmentType!.name, _C.indigo),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (dueDate != null)
                  Text(
                    'Due: ${DateFormat('MMM d, yyyy').format(dueDate)}${isOverdue ? ' (Overdue)' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? _C.red : _C.textSecondary,
                      fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                if (assessment.durationMinutes != null)
                  Text(
                    '${assessment.durationMinutes} min',
                    style: TextStyle(fontSize: 12, color: _C.textTertiary),
                  ),
                if (assessment.isMandatory)
                  const Icon(Icons.star, size: 14, color: Color(0xFFFFD700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }
}
