import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:psg_app/features/assessments/data/assessment_repository.dart';
import 'package:psg_app/features/assessments/domain/models/question_model.dart';
import 'package:psg_app/features/assessments/providers/assessment_providers.dart';

class _C {
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const borderLight = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);
  static const green = Color(0xFF10B981);
  static const red = Color(0xFFEF4444);
  static const progressBg = Color(0xFFF1F5F9);
}

class AssessmentResultsScreen extends ConsumerStatefulWidget {
  final String assessmentId;
  final String? scoreId;

  const AssessmentResultsScreen({super.key, required this.assessmentId, this.scoreId});

  @override
  ConsumerState<AssessmentResultsScreen> createState() => _AssessmentResultsScreenState();
}

class _AssessmentResultsScreenState extends ConsumerState<AssessmentResultsScreen> {
  @override
  Widget build(BuildContext context) {
    final assessmentAsync = ref.watch(assessmentDetailProvider(widget.assessmentId));
    final questionsAsync = ref.watch(assessmentQuestionsProvider(widget.assessmentId));

    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: _C.surface,
        title: const Text('Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: assessmentAsync.when(
        data: (assessment) {
          if (assessment == null) {
            return Center(child: Text('Assessment not found', style: TextStyle(color: _C.textSecondary)));
          }

          return FutureBuilder(
            future: _loadScore(),
            builder: (context, scoreSnapshot) {
              final scoreModel = scoreSnapshot.data;

              return questionsAsync.when(
                data: (questions) {
                  final percentage = scoreModel?.percentage ?? 0.0;
                  final isPassed = scoreModel?.isPassed ?? false;
                  final color = isPassed ? _C.green : _C.red;
                  final icon = isPassed ? Icons.check_circle : Icons.error;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: color.withValues(alpha: 0.15),
                                child: Icon(icon, size: 44, color: color),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isPassed ? 'Passed!' : 'Needs Review',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _C.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                scoreModel?.displayScore ?? 'Not scored',
                                style: TextStyle(fontSize: 15, color: _C.textSecondary),
                              ),
                              if (scoreModel?.submittedAt != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Submitted: ${DateFormat('MMM d, yyyy h:mm a').format(scoreModel!.submittedAt!)}',
                                    style: TextStyle(fontSize: 12, color: _C.textTertiary),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 10,
                          backgroundColor: _C.progressBg,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0%', style: TextStyle(fontSize: 12, color: _C.textTertiary)),
                            Text('60% to pass', style: TextStyle(fontSize: 12, color: _C.textTertiary)),
                            Text('100%', style: TextStyle(fontSize: 12, color: _C.textTertiary)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (questions.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Question Review', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 12),
                              ...questions.map((q) => _buildQuestionReview(context, q)),
                            ],
                          ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<dynamic> _loadScore() async {
    final repository = ref.read(assessmentRepositoryProvider);
    final userId = repository.currentUserId;
    if (userId == null) return null;

    final score = await repository.getStudentScore(widget.assessmentId, userId);
    return score;
  }

  Widget _buildQuestionReview(BuildContext context, QuestionModel question) {
    final userResponses = ref.watch(assessmentResponseProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.questionText,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          ...?question.options?.map((option) {
            final isCorrect = option.isCorrect;
            final isSelected = userResponses.any((r) => r.questionId == question.id && r.selectedOptionId == option.id);

            Color? bgColor;
            if (isCorrect) {
              bgColor = _C.green.withValues(alpha: 0.1);
            }
            if (isSelected && !isCorrect) {
              bgColor = _C.red.withValues(alpha: 0.1);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCorrect
                      ? _C.green.withValues(alpha: 0.5)
                      : isSelected
                          ? _C.red.withValues(alpha: 0.5)
                          : _C.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCorrect
                        ? Icons.check_circle
                        : isSelected
                            ? Icons.cancel
                            : Icons.circle_outlined,
                    color: isCorrect ? _C.green : isSelected ? _C.red : _C.textTertiary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      option.optionText,
                      style: TextStyle(
                        fontSize: 13,
                        color: isCorrect ? _C.green : _C.textPrimary,
                        fontWeight: isCorrect || isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
