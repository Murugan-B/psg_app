# Codebase Analysis: Vishnu Mobile (Flutter)

## 1. Project Overview

**Project Name:** vishnu_mobile (Flutter)
**Purpose:** Campus attendance management app (student, faculty, admin roles) with OTP-based attendance tracking.
**Migration Context:** Port of an existing React Native app ("EduTrack"). Per `docs/migration_plan.md`, the migration follows a "Zero-Difference" philosophy — Flutter UI should be indistinguishable from the React Native source. The Flutter project is the primary codebase; no React Native source is present locally.

---

## 2. Folder Structure

```
vishnu_mobile_flutter/
├── lib/                              # Application source (Flutter)
│   ├── main.dart                     # App entry point. Loads .env, initializes Supabase, runs MaterialApp.router
│   ├── core/                         # Core infrastructure
│   │   ├── config/env.dart           # Env class: reads SUPABASE_URL & SUPABASE_ANON_KEY from dotenv
│   │   ├── providers/supabase_provider.dart  # Global SupabaseClient provider (Riverpod)
│   │   └── router/app_router.dart    # GoRouter config (8 routes)
│   ├── features/                     # Feature modules (data/domain/providers)
│   │   ├── admin/
│   │   │   ├── data/admin_repository.dart       # CRUD for staff, students, classes, timetable, substitutes
│   │   │   └── providers/admin_providers.dart   # FutureProviders: staff list, student list, classes, timetable(family)
│   │   └── staff/
│   │       ├── data/attendance_repository.dart  # OTP gen, session creation, live attendance stream
│   │       ├── data/staff_repository.dart       # Get my classes, today/weekly timetable (with legacy fallback)
│   │       ├── domain/models/
│   │       │   ├── attendance_session_model.dart
│   │       │   ├── class_model.dart
│   │       │   ├── staff_model.dart
│   │       │   └── timetable_model.dart
│   │       └── providers/staff_providers.dart   # myClasses, todayTimetable, weeklyTimetable, selectedClass
│   ├── screens/                      # 23 screen files (UI layer)
│   ├── utils/ui_helpers.dart         # showComingSoonSnackBar helper
│   └── widgets/
│       └── call_panel_bottom_sheet.dart  # showCallPanel() — bottom sheet for calling a contact
├── supabase/
│   ├── schema.sql                    # Base schema + RLS policies (6 base tables: profiles, classes, timetable, attendance_sessions, attendance_records, substitute_requests)
│   ├── 001_staff_architecture.sql    # Extension migration: departments, courses, staff_class_assignments, class_students; timetable/extensions; conflict trigger
│   ├── 002_seed_data.sql             # Dev seed data (departments, courses, classes)
│   └── master_reset.sql              # Full wipe + recreate script (authoritative schema)
├── docs/                             # 24 documentation files (migration plan, inventories, maps)
├── assets/
│   ├── icons/                        # 15 SVG icons
│   ├── animations/
│   ├── fonts/
│   └── images/
├── test/widget_test.dart             # Default Flutter counter test (stale/unused)
├── generate_placeholders.dart        # One-off script to scaffold placeholder screens (stale, points to non-existent paths)
├── .env / .env.example               # Supabase credentials
├── pubspec.yaml                      # Dependencies
├── analysis_options.yaml             # Standard flutter_lints
└── kilo.json                         # (not present)
```

---

## 3. Dependencies (pubspec.yaml)

| Dependency | Version | Purpose |
|---|---|---|
| flutter | sdk | Framework |
| cupertino_icons | ^1.0.8 | iOS-style icons |
| supabase_flutter | ^2.15.4 | Backend/auth/realtime |
| flutter_riverpod | ^3.3.2 | State management |
| flutter_dotenv | ^5.1.0 | Env variable loading |
| go_router | ^17.0.0 | Declarative navigation |
| shared_preferences | ^2.5.3 | Local key-value storage |
| dio | ^5.10.0 | HTTP client |
| mobile_scanner | ^7.4.0 | QR/barcode scanning |
| pdf | ^3.11.3 | PDF generation |
| printing | ^5.14.3 | Print/PDF export |
| excel | ^4.0.6 | Excel export |
| path_provider | ^2.1.5 | File system paths |
| permission_handler | ^12.0.3 | Runtime permissions |
| cached_network_image | ^3.4.1 | Cached image loading |
| flutter_svg | ^2.2.3 | SVG rendering |
| intl | ^0.20.2 | Internationalization/date formatting |
| connectivity_plus | ^7.3.1 | Network status |
| qr_flutter | ^4.1.0 | QR code generation |
| uuid | ^4.6.0 | UUID generation |

**Note:** `dio`, `mobile_scanner`, `pdf`, `printing`, `excel`, `path_provider`, `permission_handler`, `cached_network_image`, `flutter_svg`, `connectivity_plus`, `qr_flutter`, and `uuid` are declared but **not yet used** in `lib/` source. They are pre-added for upcoming features (QR attendance, PDF/Excel export, etc.).

---

## 4. Navigation Logic (GoRouter — `lib/core/router/app_router.dart`)

| Route | Screen | Notes |
|---|---|---|
| `/` | LandingScreen | Splash-style landing with "Get Started" button → `/role_selection` |
| `/role_selection` | RoleSelectionScreen | 3 role cards: Student, Faculty/Staff, Admin. Continue → `/login` with role extra |
| `/login` | LoginScreen | Receives `role` via `state.extra`. Sign In navigates to role-specific main (no real auth) |
| `/student_main` | StudentMainScreen | 5-tab bottom nav: Home, Timetable, Attendance, Faculty, More |
| `/admin_main` | AdminMainScreen | 5-tab bottom nav: Dashboard, Students, Faculty, Timetable, More |
| `/staff_main` | FacultyMainScreen | 5-tab bottom nav: Home, Classes, Timetable, Faculty, More |
| `/staff/attendance/create` | FacultyGenerateOtpScreen | OTP generation for attendance sessions |

**Auth redirect:** Defined as commented-out code. Not yet implemented. Login is mock — navigates directly without Supabase auth validation.

---

## 5. Feature & Data Layer Logic

### 5.1 Supabase Schema (authoritative: `master_reset.sql`)

**Core tables:**
- `profiles` — user profiles (id → auth.users FK, role, full_name, employee_id/roll_number, department, etc.)
- `classes` — class/course offerings (subject_code, subject_name, department, year, section, batch, faculty_id, student_count)
- `timetable` — weekly schedule (class_id, faculty_id, day_of_week, start_time, end_time, room, type, subject_id, session_type, is_active)
- `attendance_sessions` — OTP/QR attendance windows (class_id, staff_id, date, start/end_time, otp_hash, qr_token_hash, status, expires_at)
- `attendance_records` — per-student attendance marks (session_id, student_id, attendance_method, status, marked_at; UNIQUE(session_id, student_id))
- `substitute_requests` — faculty substitution requests (class_id, timetable_id, original_staff_id, substitute_staff_id, date, time_slot, status)

**Extension tables (from `001_staff_architecture.sql`):**
- `departments` — (id, name, code, hod_staff_id, is_active)
- `courses` — (id, subject_code, subject_name, department_id, semester, credits, subject_type)
- `staff_class_assignments` — (staff_id, class_id, academic_year, semester, is_primary, is_active)
- `class_students` — (class_id, student_id, academic_year, semester)

**RLS:** All tables have RLS enabled. Most policies allow all authenticated users to read. Staff can manage their own attendance sessions/substitutes. Students can insert their own attendance records.

**Real-time:** `attendance_records` table added to `supabase_realtime` publication for live attendance streaming.

### 5.2 AdminRepository (`features/admin/data/admin_repository.dart`)

Methods:
- `getAllStaff()` — SELECT from profiles WHERE role IN (faculty, staff, admin), joined with departments
- `createStaffProfile()` — INSERT into profiles (NOTE: hardcodes role='faculty' regardless of staffType param)
- `getAllStudents()` — SELECT from profiles WHERE role='student'
- `createStudentProfile()` — INSERT into profiles
- `assignStaffToClass()` — UPSERT into staff_class_assignments
- `createTimetableEntry()` — INSERT into timetable (uses `session_type`, `staff_id` columns — **inconsistent with actual schema which uses `type`, `faculty_id`**)
- `getClasses()` — SELECT from classes
- `getAvailableFaculty()` — queries timetable with `faculty_id` column (matches schema), filters busy via timetable conflicts + substitute conflicts
- `assignSubstitute()` — INSERT into substitute_requests (passes substituteStaffId as BOTH original_staff_id and substitute_staff_id — workaround for NOT NULL constraint)
- `createClass()` — INSERT into classes
- `getTimetableForClass()` — SELECT from timetable joined with faculty (uses `faculty:faculty_id` join)
- `assignTimetableSlot()` — SELECT existing slot, then UPDATE or INSERT (uses `type` column, `faculty_id`)
- `deleteTimetableSlot()` — DELETE from timetable
- `updateClass()` / `deleteClass()` — UPDATE/DELETE on classes
- `updateProfile()` / `deleteProfile()` — UPDATE/DELETE on profiles

**Providers:** `adminStaffListProvider`, `adminStudentListProvider`, `adminClassesProvider`, `adminTimetableProvider` (family by classId)

### 5.3 StaffRepository (`features/staff/data/staff_repository.dart`)

Methods:
- `currentStaffId` — getter from `supabase.auth.currentUser?.id`
- `getMyClasses()` — SELECT from staff_class_assignments joined with classes; **has legacy fallback** to classes WHERE faculty_id = staffId
- `getTodayTimetable()` — SELECT from timetable for current day; **has legacy fallback**
- `getWeeklyTimetable()` — SELECT all timetable entries for staff; **has legacy fallback**

**Providers:** `myClassesProvider`, `todayTimetableProvider`, `weeklyTimetableProvider`, `selectedClassProvider` (Notifier)

### 5.4 AttendanceRepository (`features/staff/data/attendance_repository.dart`)

Methods:
- `generateOtp()` — 6-digit random string
- `createSession()` — INSERT into attendance_sessions, returns AttendanceSessionModel
- `getLiveAttendance(sessionId)` — **Stream** of attendance_records (realtime via Supabase realtime)
- `closeSession()` — UPDATE attendance_sessions status to 'CLOSED'

### 5.5 Models

- `ClassModel` — id, subjectCode, subjectName, department, year, section, semester, academicYear, classType, facultyId, studentCount
- `StaffModel` — id, fullName, employeeId, department, designation, phone, imageUrl, role
- `AttendanceSessionModel` — id, classId, staffId, date, startTime, endTime, otpHash, qrTokenHash, status, expiresAt, createdAt, closedAt
- `TimetableEntry` — id, classId, staffId, subjectId, dayOfWeek, startTime, endTime, room, type, sessionType, academicYear, semester + joined subjectCode/subjectName/classSection/classBatch

---

## 6. Screen-by-Screen Logic Summary

### Auth / Landing
- **LandingScreen** (`screens/landing_screen.dart`): Full-screen background image with gradient overlay, tagline "Smarter Attendance Brighter Tomorrows", Get Started button → `/role_selection`
- **RoleSelectionScreen** (`screens/role_selection_screen.dart`): 3 role cards (Student, Faculty/Staff, Admin). Selected role passed as extra to `/login`
- **LoginScreen** (`screens/login_screen.dart`): Email/roll/staff-ID + password fields, remember me checkbox, Google sign-in button (stub), "Create an account" link (stub). Sign In navigates directly to role-based main screen (no real Supabase auth)

### Student Role
- **StudentMainScreen**: IndexedStack with 5 tabs: Dashboard, Timetable, Attendance, Faculty Directory, More
- **StudentDashboardScreen**: Welcome header, motivational banner, 4 quick-action cards (Mark Attendance → StudentAttendanceScreen, View Timetable → StudentTimetableScreen, Attendance Status stub, Study Resources stub), "Today's Classes" (always empty state), motivational quote
- **StudentAttendanceScreen**: OTP entry (6-digit pin field), class info card with hardcoded "CS301 - Data Structures", status bar "Attendance is open", submit button has TODO (no logic)
- **StudentTimetableScreen**: Weekly timetable grid (6 time slots × 6 days), class dropdown, Week View/Subject View toggle, legend. Reuse of `AssignTimetableSlotModal` — **students shouldn't have this capability in a real app**; currently the grid cells are read-only (no onTap for students but the modal is imported)

### Faculty/Staff Role
- **FacultyMainScreen**: IndexedStack with 5 tabs: Dashboard, Classes, Timetable, Faculty, More
- **FacultyDashboardScreen**: Profile header (hardcoded "Dr. R. Sharma"), banner, 6 action cards (Generate OTP → FacultyGenerateOtpScreen, My Classes → FacultyClassesScreen, View Timetable → FacultyTimetableScreen, Attendance Reports stub, Request Substitute stub, OTP History stub), "Today's Classes" list from `todayTimetableProvider`
- **FacultyClassesScreen**: Semester toggle (Current Semester / All Semesters), list of classes from `myClassesProvider`, class card with color bar, info card at bottom. Tapping a class sets `selectedClassProvider` and navigates to `FacultyClassDetailsScreen`
- **FacultyClassDetailsScreen**: Class header card, tabs (Mark Attendance, Students, Class Info), "Generate OTP" button → FacultyGenerateOtpScreen, recent OTPs list (hardcoded), attendance report button (stub)
- **FacultyGenerateOtpScreen**: Shows selected class info, "Generate Session OTP" button (creates attendance session via AttendanceRepository), 6-digit OTP display in boxes, 10-minute countdown timer, live attendance stream from Supabase realtime, records list
- **FacultyTimetableScreen**: Weekly timetable grid using `adminClassesProvider` (not `myClassesProvider` — **uses admin's class list**), class dropdown, Week View/Subject View toggle, legend, AssignTimetableSlotModal for assigning faculty to slots (tap on empty cell). **Note: This screen mixes admin-level class fetching with staff UI; the bottom nav shows admin-style labels (Students, Faculty)**

### Admin Role
- **AdminMainScreen**: IndexedStack with 5 tabs: Dashboard, Students, Faculty, Timetable, More
- **AdminDashboardScreen**: Profile header, gradient banner, 4 stat cards (Students, Faculty Members, Classes, Avg. Attendance — all hardcoded "0"), "Today's Overview" with 4 items (hardcoded values), "View Detailed Reports" (stub)
- **AdminStudentsScreen**: Search bar, year filter chips (All, I-IIIII Year), students list from `adminStudentListProvider`, FAB to add student, inline student CRUD modal
- **AdminFacultyScreen**: Search bar, filter button, type filter chips (All Staff, Teaching, Non-Teaching, HOD), staff list from `adminStaffListProvider`, FAB to add staff, inline staff CRUD modal
- **AdminTimetableScreen**: Weekly timetable grid (same as FacultyTimetableScreen but with admin bottom nav), includes "Export PDF" (stub) and "Assign Substitute" button → AdminRequestSubstituteScreen
- **AdminRequestSubstituteScreen**: Class dropdown, date picker, time slot dropdown, available faculty list (from `getAvailableFaculty`), assign button. Uses hardcoded department UUIDs.

### Shared
- **MoreScreen**: Single "Log Out" button that signs out from Supabase and navigates to `/role_selection`

---

## 7. Key Observations & Issues

### 7.1 Functional Gaps
1. **Student OTP submission is a TODO** (`student_attendance_screen.dart:237-238`): The submit button has no logic — students cannot actually mark attendance even though faculty can generate OTPs.
2. **No real authentication**: LoginScreen navigates directly to role-based home without Supabase auth sign-in. No auth state persistence or redirect.
3. **No QR-based attendance UI**: `qr_flutter`, `mobile_scanner`, `cached_network_image` are declared but unused. Only OTP-based attendance exists.
4. **No attendance records/history for students**: "Attendance Status" card on student dashboard is a stub.

### 7.2 Schema/Repository Inconsistencies
5. **`createTimetableEntry`** in `admin_repository.dart` uses column names `session_type` and `staff_id` for the timetable insert, but the actual schema (`master_reset.sql`) uses `type` and `faculty_id` (with `session_type` being a separate column). This method is **not called anywhere** in screens — `assignTimetableSlot` is used instead, which uses the correct `type`/`faculty_id` columns.
6. **`getAvailableFaculty`** in `admin_repository.dart` queries `timetable` with `.eq('start_time', startTimeStr)` where `startTimeStr` is derived from the timeSlot string, but the timeSlot format parsing is fragile. Also hardcodes time slot string matching.
7. **`createStaffProfile`** hardcodes `role: 'faculty'` regardless of the `staffType` parameter passed in — staff type is stored but role is not differentiated.
8. **`assignSubstitute`** passes `substituteStaffId` as both `original_staff_id` and `substitute_staff_id` (workaround noted in code comments for NOT NULL constraint on `original_staff_id`).

### 7.3 UI/UX Issues
9. **Hardcoded data**: Names ("Dr. R. Sharma", "Kavin"), dates ("Mon, Sep 8, 2025"), counts (0, 6, 18, 24), OTPs (472918, etc.), phone numbers (+91 98765 43210) are all hardcoded mock values.
10. **Duplicate `AssignTimetableSlotModal` class**: Defined in both `faculty_timetable_screen.dart` and `admin_timetable_screen.dart` — identical code. Should be extracted to a shared widget.
11. **Inconsistent bottom navigation**: `FacultyDashboardScreen` has `currentIndex: 3` hardcoded for a non-embedded bottom nav that uses admin-style labels (Dashboard, Students, Faculty, Timetable, More). `FacultyTimetableScreen` similarly uses admin-style bottom nav labels.
12. **StudentTimetableScreen uses adminProviders**: It watches `adminClassesProvider` and `adminTimetableProvider` rather than staff/student-specific providers — students shouldn't access admin data scopes.
13. **`.withValues(alpha: ...)`** used throughout — requires Flutter 3.7+ (the project uses SDK ^3.8.1, so this is fine).
14. **Stale test**: `test/widget_test.dart` is the default Flutter counter test, references `find.text('0')` which won't match the actual app (no counter exists).
15. **Stale script**: `generate_placeholders.dart` references paths like `lib/features/admin/presentation/screens/` which don't exist (actual screens are in `lib/screens/`).

### 7.4 Architecture & Code Quality
16. **No auth state management** despite using Riverpod — there's no `authProvider` or auth state notifier. The router redirect is commented out.
17. **No error boundary / global error handling**: Errors in Supabase calls print to console and return empty data.
18. **Print statements**: `print()` used for error logging throughout repositories instead of a proper logging solution.
19. **No separation of presentation layer**: All screens are in `lib/screens/` flat — the docs/reference materials suggest a `features/*/presentation/screens/` structure (`generate_placeholders.dart`, `screen_inventory.md`) but the actual implementation uses a flat `screens/` directory.
20. **No reusable component library** extracted yet — UI helpers (`ui_helpers.dart`) only contain `showComingSoonSnackBar`.

---

## 8. Theme & Design System

- **Colors**: Hardcoded `Color(0xFF...)` values throughout. No centralized theme tokens (docs reference `theme_tokens.md` but it only contains the migration plan's Phase 02.5 note — not yet extracted from source).
- **Primary color**: `Color(0xFF2E63EB)` (blue) used for buttons, accents.
- **Text styles**: Inline `TextStyle` in each widget. No `TextTheme` usage.
- **Font**: `Inter` family declared in `ThemeData` but no custom font assets are present in `assets/fonts/`.
- **No Material 3** usage — defaults to Material 2 styling via `primarySwatch`.

---

## 9. Current State Assessment

The app is in an **early-mid development state**:
- Core infrastructure is set up (Supabase, Riverpod, GoRouter, env config)
- Authentication is **not** implemented (mock navigation only)
- Student attendance **submission** is not implemented (faculty OTP generation works)
- Admin CRUD for students/faculty/classes works against Supabase
- Timetable grid is functional (assign/edit/delete slots)
- Substitute request flow is functional
- All data is live from Supabase (no mock repositories as the migration docs suggest)
- The UI is fully hand-coded with hardcoded mock data for display values

---

## 10. Recommended Next Implementation Priorities

Based on the gap analysis:

1. **Implement real Supabase authentication** — sign-in flow, auth state in Riverpod, router redirect based on session
2. **Implement student OTP attendance submission** — the core missing piece (StudentAttendanceScreen submit button)
3. **Extract shared `AssignTimetableSlotModal`** to `lib/widgets/` to eliminate duplication
4. **Wire up QR-based attendance** (using `qr_flutter`, `mobile_scanner`) — for scanning QR codes displayed by faculty
5. **Fix schema/repository inconsistencies** — ensure all repository methods use correct column names
6. **Remove hardcoded mock data** — fetch real user profiles, dates, counts from Supabase
7. **Add real tests** — replace the stale counter test with widget/integration tests
8. **Centralize theme tokens** — extract colors/spacing into a theme file
