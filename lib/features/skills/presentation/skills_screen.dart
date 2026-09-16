import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:psg_app/features/skills/domain/models/domain_model.dart';
import 'package:psg_app/features/skills/domain/models/skill_model.dart';
import 'package:psg_app/features/skills/providers/skill_providers.dart';

class SkillsScreen extends ConsumerStatefulWidget {
  const SkillsScreen({super.key});

  @override
  ConsumerState<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends ConsumerState<SkillsScreen> {
  String _searchQuery = '';
  String? _selectedDomainId;

  @override
  void initState() {
    super.initState();
    _searchQuery = '';
  }

  @override
  Widget build(BuildContext context) {
    final domainsAsync = ref.watch(domainsProvider);
    final searchQuery = ref.watch(skillSearchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Skills & Development',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              onChanged: (value) {
                ref.read(skillSearchProvider.notifier).setSearch(value);
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Search skills...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2E63EB), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_searchQuery.trim().isEmpty)
            _buildDomainFilter(domainsAsync),
          Expanded(
            child: _searchQuery.trim().isNotEmpty
                ? _buildSearchResults(searchQuery)
                : _buildSkillsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainFilter(AsyncValue<List<DomainModel>> domainsAsync) {
    return domainsAsync.when(
      data: (domains) {
        if (domains.isEmpty) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          height: 56,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            scrollDirection: Axis.horizontal,
            itemCount: domains.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final domain = domains[index];
              final isSelected = _selectedDomainId == domain.id;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDomainId = isSelected ? null : domain.id;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2E63EB) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF2E63EB) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      domain.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSkillsList() {
    if (_selectedDomainId != null) {
      return Consumer(
        builder: (context, ref, child) {
          final skillsAsync = ref.watch(skillsByDomainProvider(_selectedDomainId!));
          return skillsAsync.when(
            data: (skills) => _buildSkillsGrid(skills),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => _buildError(err),
          );
        },
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final domainsAsync = ref.watch(domainsProvider);
        return domainsAsync.when(
          data: (domains) {
            if (domains.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              itemCount: domains.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final domain = domains[index];
                return _buildDomainSection(domain);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => _buildError(err),
        );
      },
    );
  }

  Widget _buildDomainSection(DomainModel domain) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.category_outlined, color: Color(0xFF2E63EB), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    domain.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (domain.description != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                domain.description!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              return Consumer(
                builder: (context, ref, child) {
                  final skillsAsync = ref.watch(skillsByDomainProvider(domain.id));
                  return skillsAsync.when(
                    data: (skills) {
                      if (skills.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No skills in this domain',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: skills.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, index) {
                          return _buildSkillListItem(skills[index]);
                        },
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
                    ),
                    error: (err, _) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error: $err', style: const TextStyle(color: Color(0xFF64748B))),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSkillListItem(SkillModel skill) {
    final difficultyColor = switch (skill.difficultyLevel) {
      'BEGINNER' => const Color(0xFF10B981),
      'INTERMEDIATE' => const Color(0xFFF59E0B),
      'ADVANCED' => const Color(0xFFEF4444),
      _ => const Color(0xFF64748B),
    };

    final progress = skill.studentProgress;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.star, color: Color(0xFF2E63EB), size: 20),
      ),
      title: Text(
        skill.name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            skill.domain?.name ?? 'Unknown domain',
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
          if (progress != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 4,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(difficultyColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(String query) {
    return Consumer(
      builder: (context, ref, child) {
        final skillsAsync = ref.watch(searchedSkillsProvider);
        return skillsAsync.when(
          data: (skills) => _buildSkillsGrid(skills),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => _buildError(err),
        );
      },
    );
  }

  Widget _buildSkillsGrid(List<SkillModel> skills) {
    if (skills.isEmpty) {
      return _buildEmptyState();
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        return _buildSkillCard(skill);
      },
    );
  }

  Widget _buildSkillCard(SkillModel skill) {
    final difficultyColor = switch (skill.difficultyLevel) {
      'BEGINNER' => const Color(0xFF10B981),
      'INTERMEDIATE' => const Color(0xFFF59E0B),
      'ADVANCED' => const Color(0xFFEF4444),
      _ => const Color(0xFF64748B),
    };

    final progress = skill.studentProgress;

    return GestureDetector(
      onTap: () {
        // Navigate to skill detail
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.star, color: Color(0xFF2E63EB), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    skill.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: difficultyColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                skill.difficultyLevel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: difficultyColor,
                ),
              ),
            ),
            if (progress != null && progress > 0) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress / 100,
                minHeight: 6,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(difficultyColor),
              ),
              const SizedBox(height: 4),
              Text(
                '${progress.toInt()}% proficiency',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.trim().isNotEmpty
                ? 'No skills found matching "$_searchQuery"'
                : 'No skills available',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 16),
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
