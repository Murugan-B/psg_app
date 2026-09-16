## Objective
- Implement PCDP-inspired features (skills, competency, assessments, resources, recommendations) on existing Flutter + Supabase vishnu_mobile_flutter project

## Important Details
- Use existing Supabase project at `https://vjkwttjcgczdzixymsqs.supabase.co`; extend schema with `003_pcdp_features.sql`, do NOT replace core infra
- Feature-first architecture: `lib/features/{module}/{data,domain,presentation}/`; existing `lib/screens/` and `lib/features/{staff,admin}/` preserved for now, migrate in Phase 8
- Real Supabase Auth (email+password + Google OAuth via `redirectTo` param) replacing mock login
- Riverpod 3.3.2 (StateProvider deprecated → use `NotifierProvider`), GoRouter 17.0.0 (use `state.pathParameters`, `matchedLocation`), Supabase 2.15.4
- `google_fonts: ^6.3.2` and `url_launcher: ^6.3.2` added to pubspec.yaml
- Material 3 theme standardized in `lib/core/theme/app_theme.dart`
- DB schema: domains, skills, competency_levels, student_competencies, assessment_types, assessments, assessment_class_targets, questions, question_options, assessment_responses, assessment_scores, resource_types, learning_resources, student_resource_views, recommendation_rules, recommendations

## Work State
### Completed
- **Phase 1**: Auth infrastructure — `auth_repository.dart` (email+Google sign-in, role-based), `auth_gate.dart`, `auth_state_provider.dart` (AuthStateNotifier + ChangeNotifier), `role_provider.dart`; `main.dart` updated (AuthGate + AppTheme + ProviderScope); `pubspec.yaml` updated (google_fonts); `app_theme.dart` (Material 3 + Google Fonts); `app_router.dart` (auth redirect, `_AuthRefreshNotifier`)
- **Phase 1**: Auth screens — `landing_screen.dart`, `login_screen.dart`, `role_selection_screen.dart` in `lib/features/auth/presentation/`
- **Phase 2**: `supabase/003_pcdp_features.sql` — 16 new tables, triggers, RLS policies, seed data, realtime publications; `url_launcher: ^6.3.2` added to pubspec
- **Phase 2**: Skills feature — `domain_model.dart`, `skill_model.dart`, `skill_repository.dart`, `skill_providers.dart`, `skills_screen.dart`, `skill_detail_screen.dart`
- **Phase 2**: Competency feature — `competency_level_model.dart`, `student_competency_model.dart`, `competency_repository.dart`, `competency_providers.dart`, `competency_dashboard_screen.dart`
- **Phase 4**: Assessment System — `assessment_type_model.dart`, `assessment_model.dart`, `question_model.dart`, `question_option_model.dart`, `assessment_response_model.dart`, `assessment_score_model.dart`, `assessment_repository.dart`, `assessment_providers.dart`, `assessment_list_screen.dart`, `take_assessment_screen.dart`, `assessment_results_screen.dart`; routes wired in `app_router.dart`
- **Phase 5**: Learning Resources — `resource_type_model.dart`, `learning_resource_model.dart`, `student_resource_view_model.dart`, `resource_repository.dart`, `resource_providers.dart`, `resource_list_screen.dart`, `resource_detail_screen.dart`; routes wired in `app_router.dart`
- **Phase 6**: Recommendation Engine — `recommendation_rule_model.dart`, `recommendation_model.dart`, `recommendation_repository.dart`, `recommendation_providers.dart`, `recommendations_screen.dart`; route wired in `app_router.dart`
- **Verify**: `flutter analyze lib/` — zero errors, zero warnings in new code (all remaining issues are pre-existing `info`/`warning` lints in old `lib/screens/` and `lib/features/admin|staff/` files)

### In Progress
- Phase 7: Integrate assessment/competency/resource/recommendation access into role-based main screens (student_main, faculty_main, admin_main)

### Pending
- Phase 7: Wire new feature screens into student/faculty/admin main screen navigation
- Phase 8: Migrate existing `lib/screens/` into feature-first architecture

## Next Move
1. Phase 7: Add navigation entries for Assessments, Resources, Recommendations, and Competency Progress to the role-based main screens (StudentMainScreen, FacultyMainScreen, AdminMainScreen)
2. Run full `flutter analyze lib/` to verify Phase 7 changes

## Relevant Files
- Auth: `lib/core/auth/auth_repository.dart`, `auth_gate.dart`, `auth_state_provider.dart`, `role_provider.dart`
- Core: `lib/core/router/app_router.dart`, `lib/core/theme/app_theme.dart`, `lib/main.dart`
- Auth screens: `lib/features/auth/presentation/`
- Skills: `lib/features/skills/{data,domain,providers,presentation}/`
- Competency: `lib/features/competency/{data,domain,providers,presentation}/`
- Assessments: `lib/features/assessments/{data,domain,providers,presentation}/`
- Resources: `lib/features/resources/{data,domain,providers,presentation}/`
- Recommendations: `lib/features/recommendations/{data,domain,providers,presentation}/`
- Migration: `supabase/003_pcdp_features.sql`
- Config: `pubspec.yaml` (added google_fonts: ^6.3.2, url_launcher: ^6.3.2)
- Credentials: `.env` (SUPABASE_URL, SUPABASE_ANON_KEY)
