-- =====================================================================================
-- VISHNU MOBILE - SEED DATA (DEVELOPMENT ONLY)
-- =====================================================================================
-- WARNING: Do not run this on production if you don't want mock data.

-- Note: We assume auth.users already exists for these profiles. If not, the application
-- might fail if foreign key constraints strictly require auth.users IDs. For Supabase,
-- profiles.id must match auth.users.id.
-- For local testing, we will create dummy UUIDs for profiles, but in a real environment
-- you should create users via Supabase Auth first, then link them.

-- 1. Departments
INSERT INTO public.departments (id, name, code, is_active)
VALUES
  ('d0000000-0000-0000-0000-000000000001', 'Computer Science and Engineering', 'CSE', true),
  ('d0000000-0000-0000-0000-000000000002', 'Information Technology', 'IT', true),
  ('d0000000-0000-0000-0000-000000000003', 'Electronics and Communication Engineering', 'ECE', true)
ON CONFLICT (code) DO NOTHING;

-- 2. Courses / Subjects
INSERT INTO public.courses (id, subject_code, subject_name, department_id, semester, credits, subject_type)
VALUES
  ('c0000000-0000-0000-0000-000000000001', 'CS301', 'Data Structures', 'd0000000-0000-0000-0000-000000000001', 'III', 3, 'THEORY'),
  ('c0000000-0000-0000-0000-000000000002', 'CS302', 'Operating Systems', 'd0000000-0000-0000-0000-000000000001', 'V', 4, 'THEORY'),
  ('c0000000-0000-0000-0000-000000000003', 'CS303', 'Database Management Systems', 'd0000000-0000-0000-0000-000000000001', 'IV', 4, 'THEORY'),
  ('c0000000-0000-0000-0000-000000000004', 'CS301L', 'Data Structures Lab', 'd0000000-0000-0000-0000-000000000001', 'III', 2, 'LAB')
ON CONFLICT (subject_code) DO NOTHING;

-- 3. Mock Profiles (Only insert if you are absolutely sure it won't break your Auth integration)
-- If the profiles table has a strict foreign key to auth.users, these inserts will FAIL unless
-- these UUIDs exist in auth.users.
-- Assuming we want to demonstrate the relationships safely, we'll skip inserting into profiles
-- unless requested. The user should use their own authenticated user ID for testing.

-- 4. Classes (Course Offerings)
INSERT INTO public.classes (id, course_id, subject_code, subject_name, department, department_id, year, section, semester, academic_year, batch, class_type, student_count)
VALUES
  ('b0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'CS301', 'Data Structures', 'CSE', 'd0000000-0000-0000-0000-000000000001', 'II', 'A', 'III', '2023-2024', '2022-2026', 'THEORY', 60),
  ('b0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'CS301', 'Data Structures', 'CSE', 'd0000000-0000-0000-0000-000000000001', 'II', 'B', 'III', '2023-2024', '2022-2026', 'THEORY', 58)
ON CONFLICT (id) DO NOTHING;

-- Note: 
-- staff_class_assignments and timetable entries should be created via the Admin UI 
-- or manually mapped to the ACTUAL auth.uid() of the logged-in staff member.
