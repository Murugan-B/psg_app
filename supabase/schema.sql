-- =====================================================================================
-- VISHNU MOBILE - SUPABASE SCHEMA & RLS POLICIES
-- =====================================================================================

-- 1. Profiles (extends auth.users)
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

-- 2. Classes
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
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Timetable
CREATE TABLE public.timetable (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_id UUID REFERENCES public.classes(id) ON DELETE CASCADE,
  faculty_id UUID REFERENCES public.profiles(id),
  day_of_week TEXT NOT NULL CHECK (day_of_week IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  room TEXT,
  type TEXT DEFAULT 'Theory',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Attendance Sessions
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
  closed_at TIMESTAMP WITH TIME ZONE
);

-- 5. Attendance Records
CREATE TABLE public.attendance_records (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID REFERENCES public.attendance_sessions(id) ON DELETE CASCADE NOT NULL,
  student_id UUID REFERENCES public.profiles(id) NOT NULL,
  attendance_method TEXT CHECK (attendance_method IN ('OTP', 'QR', 'MANUAL')),
  status TEXT DEFAULT 'Present' CHECK (status IN ('Present', 'Absent', 'Late')),
  marked_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(session_id, student_id) -- Duplicate attendance protection
);

-- 6. Substitute Requests
CREATE TABLE public.substitute_requests (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_id UUID REFERENCES public.classes(id) ON DELETE CASCADE,
  timetable_id UUID REFERENCES public.timetable(id),
  original_staff_id UUID REFERENCES public.profiles(id) NOT NULL,
  substitute_staff_id UUID REFERENCES public.profiles(id) NOT NULL,
  date DATE NOT NULL,
  time_slot TEXT NOT NULL,
  status TEXT DEFAULT 'REQUESTED' CHECK (status IN ('REQUESTED', 'APPROVED', 'REJECTED', 'CANCELLED', 'COMPLETED')),
  requested_by UUID REFERENCES public.profiles(id) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);


-- =====================================================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.timetable ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.substitute_requests ENABLE ROW LEVEL SECURITY;

-- Profiles: Anyone authenticated can read profiles (needed for directory). Users can update own profile.
CREATE POLICY "Profiles are viewable by authenticated users" ON public.profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id);

-- Classes: Anyone authenticated can view classes.
CREATE POLICY "Classes are viewable by authenticated users" ON public.classes FOR SELECT TO authenticated USING (true);

-- Timetable: Anyone authenticated can view timetable.
CREATE POLICY "Timetable is viewable by authenticated users" ON public.timetable FOR SELECT TO authenticated USING (true);

-- Attendance Sessions:
-- Staff can create sessions for their classes.
-- Everyone can view open sessions (so students can mark attendance).
-- Staff can view all sessions they created or for their classes.
CREATE POLICY "Sessions viewable by all" ON public.attendance_sessions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Staff can insert own sessions" ON public.attendance_sessions FOR INSERT TO authenticated WITH CHECK (auth.uid() = staff_id);
CREATE POLICY "Staff can update own sessions" ON public.attendance_sessions FOR UPDATE TO authenticated USING (auth.uid() = staff_id);

-- Attendance Records:
-- Students can insert their own attendance.
-- Staff can view attendance for their sessions.
CREATE POLICY "Students can insert own attendance" ON public.attendance_records FOR INSERT TO authenticated WITH CHECK (auth.uid() = student_id);
CREATE POLICY "Attendance records viewable by everyone" ON public.attendance_records FOR SELECT TO authenticated USING (true);

-- Substitute Requests:
-- Staff can create and view substitute requests.
CREATE POLICY "Substitute requests viewable by staff" ON public.substitute_requests FOR SELECT TO authenticated USING (true);
CREATE POLICY "Staff can insert substitute requests" ON public.substitute_requests FOR INSERT TO authenticated WITH CHECK (auth.uid() = requested_by);
CREATE POLICY "Staff can update own substitute requests" ON public.substitute_requests FOR UPDATE TO authenticated USING (auth.uid() = requested_by);

-- Create a realtime publication for live attendance
begin;
  drop publication if exists supabase_realtime;
  create publication supabase_realtime;
commit;
alter publication supabase_realtime add table public.attendance_records;
