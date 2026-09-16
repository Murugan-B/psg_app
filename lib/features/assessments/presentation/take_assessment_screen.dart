import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:psg_app/features/assessments/data/assessment_repository.dart';
import 'package:psg_app/features/assessments/domain/models/assessment_response_model.dart';
import 'package:psg_app/features/assessments/domain/models/question_model.dart';
import 'package:psg_app/features/assessments/providers/assessment_providers.dart';
import 'package:psg_app/features/assessments/presentation/assessment_results_screen.dart';

class _C {
  static const primary = Color(0xFF2E63EB);
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const border = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);
  static const red = Color(0xFFEF4444);
  static const progressBg = Color(0xFFF1F5F9);
}

class TakeAssessmentScreen extends ConsumerStatefulWidget {
  final String assessmentId;

  const TakeAssessmentScreen({super.key, required this.assessmentId});

  @override
  ConsumerState<TakeAssessmentScreen> createState() => _TakeAssessmentScreenState();
}

class _TakeAssessmentScreenState extends ConsumerState<TakeAssessmentScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  int? _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final questionsAsync = ref.read(assessmentQuestionsProvider(widget.assessmentId));
      questionsAsync.whenOrNull(
        data: (questions) {
          if (questions.isNotEmpty) {
            final assessmentAsync = ref.read(assessmentDetailProvider(widget.assessmentId));
            assessmentAsync.whenOrNull(
              data: (assessment) {
                if (assessment != null && assessment.durationMinutes != null) {
                  setState(() {
                    _remainingSeconds = assessment.durationMinutes! * 60;
                  });
                  _startTimer();
                }
              },
            );
          }
        },
      );
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = _remainingSeconds;
      if (current == null || current <= 0) {
        timer.cancel();
        _submitAssessment();
        return;
      }
      setState(() {
        _remainingSeconds = current - 1;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins : $secs';
  }

  Future<void> _submitAssessment() async {
    final questionsAsync = ref.read(assessmentQuestionsProvider(widget.assessmentId));
    if (!questionsAsync.hasValue || questionsAsync.value!.isEmpty) return;

    final questions = questionsAsync.value!;
    final responses = ref.read(assessmentResponseProvider);
    final repository = ref.read(assessmentRepositoryProvider);
    final userId = repository.currentUserId;
    if (userId == null) return;

    final nextAttempt = await ref.read(nextAttemptProvider((widget.assessmentId, userId)).future);

    final missing = questions.where((q) => q.isRequired && !responses.any((r) => r.questionId == q.id));
    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please answer all required questions (${missing.length} remaining)'), backgroundColor: _C.red),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: _C.surface,
        content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Text('Submitting...')]),
      ),
    );

    try {
      double totalScore = 0;

      for (final question in questions) {
        final response = responses.firstWhere(
          (r) => r.questionId == question.id,
          orElse: () => AssessmentResponseModel(
            id: '',
            assessmentId: widget.assessmentId,
            questionId: question.id,
            studentId: userId,
            attemptNumber: nextAttempt,
            submittedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        );

        if (question.isMcq && response.selectedOptionId != null) {
          final options = question.options ?? [];
          if (options.isNotEmpty) {
            final correctOption = options.firstWhere((o) => o.isCorrect, orElse: () => options.first);
            if (response.selectedOptionId == correctOption.id) {
              totalScore += question.maxMarks;
            }
          }
        } else if (question.isMultiSelect) {
          final correctOptions = question.options?.where((o) => o.isCorrect).toList() ?? [];
          if (response.selectedOptionId != null) {
            final selectedId = response.selectedOptionId!;
            if (correctOptions.any((o) => o.id == selectedId)) {
              totalScore += question.maxMarks;
            }
          }
        }

        await repository.upsertResponse(
          assessmentId: widget.assessmentId,
          questionId: question.id,
          studentId: userId,
          selectedOptionId: response.selectedOptionId,
          textAnswer: response.textAnswer,
          numericAnswer: response.numericAnswer,
          attemptNumber: nextAttempt,
        );
      }

      final scoreModel = await repository.submitAssessment(
        assessmentId: widget.assessmentId,
        studentId: userId,
        attemptNumber: nextAttempt,
        scoreObtained: totalScore,
      );

      ref.invalidate(assessmentResponseProvider);
      ref.invalidate(myScoresProvider);

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AssessmentResultsScreen(
            assessmentId: widget.assessmentId,
            scoreId: scoreModel?.id,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting: $e'), backgroundColor: _C.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final assessmentAsync = ref.watch(assessmentDetailProvider(widget.assessmentId));
    final questionsAsync = ref.watch(assessmentQuestionsProvider(widget.assessmentId));
    final responses = ref.watch(assessmentResponseProvider);

    return assessmentAsync.when(
      data: (assessment) {
        if (assessment == null) {
          return Scaffold(body: Center(child: Text('Assessment not found', style: TextStyle(color: _C.textSecondary))));
        }
        return Scaffold(
          backgroundColor: _C.background,
          appBar: AppBar(
            backgroundColor: _C.surface,
            title: Text(assessment.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              if (_remainingSeconds != null)
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  alignment: Alignment.center,
                  child: Text(
                    _formatTime(_remainingSeconds!),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _remainingSeconds! < 60 ? _C.red : _C.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
          body: questionsAsync.when(
            data: (questions) {
              if (questions.isEmpty) {
                return const Center(child: Text('No questions available'));
              }
              return Column(
                children: [
                  LinearProgressIndicator(
                    value: (_currentPage + 1) / questions.length,
                    minHeight: 6,
                    backgroundColor: _C.progressBg,
                    valueColor: const AlwaysStoppedAnimation<Color>(_C.primary),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: questions.length,
                      onPageChanged: (index) => setState(() => _currentPage = index),
                      itemBuilder: (context, index) => _buildQuestionCard(context, questions[index], responses),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err', style: TextStyle(color: _C.textSecondary))),
          ),
          bottomNavigationBar: questionsAsync.whenOrNull(
            data: (questions) => questions.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (_currentPage > 0)
                          Expanded(
                            child: TextButton(
                              onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                              child: const Text('Previous', style: TextStyle(color: _C.textSecondary)),
                            ),
                          ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_remainingSeconds != null && _remainingSeconds! <= 0) return;
                              if (_currentPage < questions.length - 1) {
                                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                              } else {
                                _submitAssessment();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _C.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              _currentPage < questions.length - 1 ? 'Next' : 'Submit Assessment',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err', style: TextStyle(color: _C.textSecondary)))),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    QuestionModel question,
    List<AssessmentResponseModel> responses,
  ) {
    final response = responses.firstWhere(
      (r) => r.questionId == question.id,
      orElse: () => AssessmentResponseModel(
        id: '',
        assessmentId: widget.assessmentId,
        questionId: question.id,
        studentId: '',
        attemptNumber: 1,
        submittedAt: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: _C.primary.withValues(alpha: 0.1),
                child: Text('${_currentPage + 1}', style: TextStyle(color: _C.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Question ${_currentPage + 1}',
                  style: TextStyle(fontSize: 14, color: _C.textSecondary),
                ),
              ),
              if (question.isRequired)
                const Icon(Icons.star, size: 14, color: Color(0xFFFFD700)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question.questionText,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 20),
          ..._buildAnswerInput(context, question, response),
        ],
      ),
    );
  }

  List<Widget> _buildAnswerInput(BuildContext context, QuestionModel question, AssessmentResponseModel response) {
    if (!question.hasOptions) {
      if (question.isTextAnswer) {
        return [
          TextField(
            maxLines: question.questionType == 'LONG_ANSWER' ? 5 : 2,
            decoration: InputDecoration(
              hintText: 'Type your answer here...',
              hintStyle: TextStyle(color: _C.textTertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _C.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _C.primary),
              ),
            ),
            onChanged: (value) {
              ref.read(assessmentResponseProvider.notifier).updateResponse(
                question.id,
                textAnswer: value,
              );
            },
          ),
        ];
      }
      if (question.isNumerical) {
        return [
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Enter a number...',
              hintStyle: TextStyle(color: _C.textTertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _C.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _C.primary),
              ),
            ),
            onChanged: (value) {
              ref.read(assessmentResponseProvider.notifier).updateResponse(
                question.id,
                numericAnswer: double.tryParse(value),
              );
            },
          ),
        ];
      }
    }

    final options = question.options;
    if (options == null || options.isEmpty) {
      return [Text('No options available', style: TextStyle(color: _C.textTertiary))];
    }

    final isMulti = question.isMultiSelect;

    return options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final isSelected = response.selectedOptionId == option.id;
      final labels = isMulti ? 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' : null;

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: () {
            ref.read(assessmentResponseProvider.notifier).updateResponse(
              question.id,
              selectedOptionId: isMulti
                  ? (isSelected ? null : option.id)
                  : option.id,
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? _C.primary.withValues(alpha: 0.1) : _C.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? _C.primary : _C.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                if (isMulti)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(labels![index], style: TextStyle(color: _C.textSecondary, fontWeight: FontWeight.bold)),
                  ),
                Expanded(
                  child: Text(option.optionText, style: TextStyle(color: _C.textPrimary)),
                ),
                if (isMulti)
                  Icon(
                    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: isSelected ? _C.primary : _C.textTertiary,
                    size: 20,
                  )
                else
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.circle_outlined,
                    color: isSelected ? _C.primary : _C.textTertiary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
