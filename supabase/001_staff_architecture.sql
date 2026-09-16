-- =====================================================================================
-- VISHNU MOBILE - STAFF ARCHITECTURE EXTENSION
-- =====================================================================================

-- 1. DEPARTMENTS
CREATE TABLE IF NOT EXISTS public.departments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  code TEXT NOT NULL UNIQUE,
  hod_staff_id UUID, -- Will reference profiles(id)
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. COURSES / SUBJECTS
CREATE TABLE IF NOT EXISTS public.courses (
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

-- 3. PROFILES EXTENSION (Staff Details)
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS staff_type TEXT CHECK (staff_type IN ('TEACHING', 'NON_TEACHING', 'HOD'));
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS joining_date DATE;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS qualification TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS specialization TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS department_id UUID REFERENCES public.departments(id);
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now());

-- Add foreign key constraint for HOD now that profiles exists
ALTER TABLE public.departments ADD CONSTRAINT fk_departments_hod FOREIGN KEY (hod_staff_id) REFERENCES public.profiles(id);

-- 4. CLASSES EXTENSION (Course Offerings/Sections)
ALTER TABLE public.classes ADD COLUMN IF NOT EXISTS course_id UUID REFERENCES public.courses(id);
ALTER TABLE public.classes ADD COLUMN IF NOT EXISTS department_id UUID REFERENCES public.departments(id);
ALTER TABLE public.classes ADD COLUMN IF NOT EXISTS batch TEXT;
ALTER TABLE public.classes ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE public.classes ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now());

-- 5. STAFF-CLASS ASSIGNMENTS
CREATE TABLE IF NOT EXISTS public.staff_class_assignments (
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

-- 6. CLASS-STUDENTS ENROLLMENT
CREATE TABLE IF NOT EXISTS public.class_students (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_id UUID REFERENCES public.classes(id) NOT NULL,
  student_id UUID REFERENCES public.profiles(id) NOT NULL,
  academic_year TEXT NOT NULL,
  semester TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(class_id, student_id)
);

-- 7. TIMETABLE EXTENSION
ALTER TABLE public.timetable ADD COLUMN IF NOT EXISTS subject_id UUID REFERENCES public.courses(id);
ALTER TABLE public.timetable ADD COLUMN IF NOT EXISTS session_type TEXT DEFAULT 'THEORY' CHECK (session_type IN ('THEORY', 'LAB', 'TUTORIAL', 'ACTIVITY', 'OTHER'));
ALTER TABLE public.timetable ADD COLUMN IF NOT EXISTS academic_year TEXT;
ALTER TABLE public.timetable ADD COLUMN IF NOT EXISTS semester TEXT;
ALTER TABLE public.timetable ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE public.timetable ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now());

-- 8. ATTENDANCE SESSIONS EXTENSION
ALTER TABLE public.attendance_sessions ADD COLUMN IF NOT EXISTS timetable_id UUID REFERENCES public.timetable(id);

-- =====================================================================================
-- TIMETABLE CONFLICT VALIDATION (TRIGGER)
-- =====================================================================================

CREATE OR REPLACE FUNCTION check_timetable_conflict()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if the staff member is already assigned to a different class at overlapping time
  IF EXISTS (
    SELECT 1 FROM public.timetable
    WHERE staff_id = NEW.staff_id
      AND day_of_week = NEW.day_of_week
      AND is_active = true
      AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid)
      AND (
        (NEW.start_time >= start_time AND NEW.start_time < end_time) OR
        (NEW.end_time > start_time AND NEW.end_time <= end_time) OR
        (NEW.start_time <= start_time AND NEW.end_time >= end_time)
      )
  ) THEN
    RAISE EXCEPTION 'Timetable conflict: This faculty member already has a class during this time.';
  END IF;

  -- Check if the class already has a different subject at overlapping time
  IF EXISTS (
    SELECT 1 FROM public.timetable
    WHERE class_id = NEW.class_id
      AND day_of_week = NEW.day_of_week
      AND is_active = true
      AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid)
      AND (
        (NEW.start_time >= start_time AND NEW.start_time < end_time) OR
        (NEW.end_time > start_time AND NEW.end_time <= end_time) OR
        (NEW.start_time <= start_time AND NEW.end_time >= end_time)
      )
  ) THEN
    RAISE EXCEPTION 'Timetable conflict: This class already has a schedule during this time.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS validate_timetable_overlap ON public.timetable;
CREATE TRIGGER validate_timetable_overlap
BEFORE INSERT OR UPDATE ON public.timetable
FOR EACH ROW
EXECUTE FUNCTION check_timetable_conflict();

-- =====================================================================================
-- ROW LEVEL SECURITY (RLS) FOR NEW TABLES
-- =====================================================================================

ALTER TABLE public.departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff_class_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.class_students ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Departments viewable by all" ON public.departments FOR SELECT TO authenticated USING (true);
CREATE POLICY "Courses viewable by all" ON public.courses FOR SELECT TO authenticated USING (true);
CREATE POLICY "Staff Class Assignments viewable by all" ON public.staff_class_assignments FOR SELECT TO authenticated USING (true);
CREATE POLICY "Class Students viewable by all" ON public.class_students FOR SELECT TO authenticated USING (true);

-- Allow admin role full access (Assuming RLS policies will be bypassed by Service Role, but we can explicitly add Admin rules if needed)
-- Example: CREATE POLICY "Admins can manage departments" ON public.departments USING (auth.jwt() ->> 'role' = 'admin');
