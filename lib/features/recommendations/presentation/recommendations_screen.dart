import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:psg_app/features/recommendations/domain/models/recommendation_model.dart';
import 'package:psg_app/features/recommendations/providers/recommendation_providers.dart';

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
  static const blue = Color(0xFF3B82F6);
  static const orange = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
}

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(activeRecommendationsProvider);

    return Scaffold(
      backgroundColor: _C.background,
      appBar: AppBar(
        backgroundColor: _C.surface,
        title: const Text('Recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: recommendationsAsync.when(
        data: (recommendations) => _buildContent(context, ref, recommendations),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err', style: TextStyle(color: _C.textSecondary))),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<RecommendationModel> recommendations) {
    if (recommendations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.recommend, size: 64, color: _C.textTertiary),
            SizedBox(height: 16),
            Text('No recommendations right now', style: TextStyle(color: _C.textSecondary, fontSize: 16)),
            SizedBox(height: 8),
            Text('We\'ll notify you when new recommendations are available.',
                style: TextStyle(color: _C.textTertiary, fontSize: 13)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(activeRecommendationsProvider),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: recommendations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildRecommendationCard(context, ref, recommendations[index]),
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, WidgetRef ref, RecommendationModel rec) {
    final rule = rec.rule;
    final color = rule != null ? _getColorForRuleType(rule.ruleType) : _C.purple;
    final icon = _getIconForRuleType(rule?.ruleType ?? '');
    final hasScore = rec.score != null;
    final isExpired = rec.validUntil != null && rec.validUntil!.isBefore(DateTime.now());

    return Dismissible(
      key: Key(rec.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: _C.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 24),
      ),
      onDismissed: (direction) {
        ref.read(recommendationActionProvider(rec.id)).dismiss();
        ref.invalidate(activeRecommendationsProvider);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isExpired ? _C.red.withValues(alpha: 0.3) : _C.borderLight, width: isExpired ? 2 : 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rec.title,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _C.textPrimary),
                      ),
                      if (rec.description != null && rec.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            rec.description!,
                            style: TextStyle(fontSize: 12, color: _C.textSecondary, height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                if (hasScore)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _C.indigo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${rec.score!.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _C.indigo),
                    ),
                  ),
              ],
            ),
            if (isExpired)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _C.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Expired', style: TextStyle(fontSize: 11, color: _C.red)),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (rec.skill != null)
                    Text(rec.skill!.name, style: TextStyle(fontSize: 12, color: _C.textTertiary)),
                  if (rec.resource != null)
                    Expanded(
                      child: Text('Resource: ${rec.resource!.title}',
                          style: TextStyle(fontSize: 12, color: _C.textTertiary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  if (rec.assessment != null)
                    Expanded(
                      child: Text('Assessment: ${rec.assessment!.title}',
                          style: TextStyle(fontSize: 12, color: _C.textTertiary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  if (rec.validUntil != null)
                    Text(DateFormat('MMM d').format(rec.validUntil!),
                        style: TextStyle(fontSize: 12, color: _C.textTertiary)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ref.read(recommendationActionProvider(rec.id)).markCompleted();
                      ref.invalidate(activeRecommendationsProvider);
                    },
                    child: Text('Complete', style: TextStyle(fontSize: 12, color: _C.green, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForRuleType(String ruleType) {
    switch (ruleType) {
      case 'SKILL_GAP':
        return _C.indigo;
      case 'LOW_ATTENDANCE':
        return _C.red;
      case 'ASSESSMENT_PERFORMANCE':
        return _C.orange;
      case 'DOMAIN_RECOMMENDED':
        return _C.blue;
      case 'PREREQUISITE_MISSING':
        return _C.purple;
      default:
        return _C.indigo;
    }
  }

  IconData _getIconForRuleType(String ruleType) {
    switch (ruleType) {
      case 'SKILL_GAP':
        return Icons.trending_down;
      case 'LOW_ATTENDANCE':
        return Icons.warning;
      case 'ASSESSMENT_PERFORMANCE':
        return Icons.school;
      case 'DOMAIN_RECOMMENDED':
        return Icons.lightbulb;
      case 'PREREQUISITE_MISSING':
        return Icons.account_tree;
      default:
        return Icons.recommend;
    }
  }
}
