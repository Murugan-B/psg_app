-- =====================================================================================
-- MASTER RESET SCRIPT - VISHNU MOBILE
-- =====================================================================================
-- WARNING: This will completely wipe the public schema and recreate it!
-- Only run this ONCE.

-- 1. WIPE THE ENTIRE PUBLIC SCHEMA
DO $$ DECLARE
  r RECORD;
BEGIN
  FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
    EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
  END LOOP;
END $$;

-- 2. CREATE BASE PROFILES TABLE
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  role TEXT NOT NULL CHECK (role IN ('student', 'faculty', 'admin')),
  full_name TEXT NOT NULL,
  employee_id TEXT UNIQUE, -- For staff
  roll_number TEXT UNIQUE, -- For students
  department TEXT,
  designation TEXT,
  phone TEXT,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. CREATE DEPARTMENTS
CREATE TABLE public.departments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  code TEXT NOT NULL UNIQUE,
  hod_staff_id UUID REFERENCES public.profiles(id),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. CREATE COURSES
CREATE TABLE public.courses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  subject_code TEXT NOT NULL UNIQUE,
  subject_name TEXT NOT NULL,
  department_id UUID REFERENCES public.departments(id),
  semester TEXT,
  credits NUMERIC,
  subject_type TEXT DEFAULT 'THEORY' CHECK (subject_type IN ('THEORY', 'LAB', 'TUTORIAL', 'ACTIVITY', 'OTHER')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. EXTEND PROFILES
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS staff_type TEXT CHECK (staff_type IN ('TEACHING', 'NON_TEACHING', 'HOD'));
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS joining_date DATE;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS qualification TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS specialization TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS department_id UUID REFERENCES public.departments(id);
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now());

-- 6. CREATE CLASSES
CREATE TABLE public.classes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  subject_code TEXT NOT NULL,
  subject_name TEXT NOT NULL,
  department TEXT NOT NULL,
  year TEXT,
  section TEXT,
  semester TEXT,
  academic_year TEXT,
  class_type TEXT DEFAULT 'Theory',
  faculty_id UUID REFERENCES public.profiles(id),
  student_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  course_id UUID REFERENCES public.courses(id),
  department_id UUID REFERENCES public.departments(id),
  batch TEXT,
  is_active BOOLEAN DEFAULT true,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 7. CREATE TIMETABLE
CREATE TABLE public.timetable (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_id UUID REFERENCES public.classes(id) ON DELETE CASCADE,
  faculty_id UUID REFERENCES public.profiles(id),
  day_of_week TEXT NOT NULL CHECK (day_of_week IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  room TEXT,
  type TEXT DEFAULT 'Theory',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  subject_id UUID REFERENCES public.courses(id),
  session_type TEXT DEFAULT 'THEORY' CHECK (session_type IN ('THEORY', 'LAB', 'TUTORIAL', 'ACTIVITY', 'OTHER')),
  academic_year TEXT,
  semester TEXT,
  is_active BOOLEAN DEFAULT true,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 8. CREATE ATTENDANCE SESSIONS
CREATE TABLE public.attendance_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_id UUID REFERENCES public.classes(id) ON DELETE CASCADE NOT NULL,
  staff_id UUID REFERENCES public.profiles(id) NOT NULL,
  date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  otp_hash TEXT,
  qr_token_hash TEXT,
  status TEXT DEFAULT 'CREATED' CHECK (status IN ('CREATED', 'OPEN', 'CLOSED', 'EXPIRED', 'CANCELLED')),
  expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  closed_at TIMESTAMP WITH TIME ZONE,
  timetable_id UUID REFERENCES public.timetable(id)
);

-- 9. CREATE ATTENDANCE RECORDS
CREATE TABLE public.attendance_records (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID REFERENCES public.attendance_sessions(id) ON DELETE CASCADE NOT NULL,
  student_id UUID REFERENCES public.profiles(id) NOT NULL,
  attendance_method TEXT CHECK (attendance_method IN ('OTP', 'QR', 'MANUAL')),
  status TEXT DEFAULT 'Present' CHECK (status IN ('Present', 'Absent', 'Late')),
  marked_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(session_id, student_id)
);

-- 10. CREATE STAFF-CLASS ASSIGNMENTS
CREATE TABLE public.staff_class_assignments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  staff_id UUID REFERENCES public.profiles(id) NOT NULL,
  class_id UUID REFERENCES public.classes(id) NOT NULL,
  academic_year TEXT NOT NULL,
  semester TEXT NOT NULL,
  is_primary BOOLEAN DEFAULT true,
  is_active BOOLEAN DEFAULT true,
  assigned_by UUID REFERENCES public.profiles(id),
  assigned_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(staff_id, class_id)
);

-- 11. ENABLE RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.timetable ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff_class_assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Viewable by all" ON public.profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "Viewable by all" ON public.departments FOR SELECT TO authenticated USING (true);
CREATE POLICY "Viewable by all" ON public.courses FOR SELECT TO authenticated USING (true);
CREATE POLICY "Viewable by all" ON public.classes FOR SELECT TO authenticated USING (true);
CREATE POLICY "Viewable by all" ON public.timetable FOR SELECT TO authenticated USING (true);
CREATE POLICY "Viewable by all" ON public.attendance_sessions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Viewable by all" ON public.attendance_records FOR SELECT TO authenticated USING (true);
CREATE POLICY "Viewable by all" ON public.staff_class_assignments FOR SELECT TO authenticated USING (true);

-- Insert dummy data (won't conflict since we wiped tables)
INSERT INTO public.departments (id, name, code, is_active) VALUES
  ('d0000000-0000-0000-0000-000000000001', 'Computer Science and Engineering', 'CSE', true),
  ('d0000000-0000-0000-0000-000000000002', 'Information Technology', 'IT', true),
  ('d0000000-0000-0000-0000-000000000003', 'Electronics and Communication Engineering', 'ECE', true);

INSERT INTO public.courses (id, subject_code, subject_name, department_id, semester, credits, subject_type) VALUES
  ('c0000000-0000-0000-0000-000000000001', 'CS301', 'Data Structures', 'd0000000-0000-0000-0000-000000000001', 'III', 3, 'THEORY'),
  ('c0000000-0000-0000-0000-000000000002', 'CS302', 'Operating Systems', 'd0000000-0000-0000-0000-000000000001', 'V', 4, 'THEORY');

-- Tell Supabase to refresh its schema cache
NOTIFY pgrst, 'reload schema';
