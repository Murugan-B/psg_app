-- Add the end_otp_hash column to attendance_sessions
ALTER TABLE public.attendance_sessions
ADD COLUMN IF NOT EXISTS end_otp_hash TEXT;

-- Update the check constraint for attendance_records status to include Present (Start) and Present (Full)
ALTER TABLE public.attendance_records DROP CONSTRAINT IF EXISTS attendance_records_status_check;
ALTER TABLE public.attendance_records ADD CONSTRAINT attendance_records_status_check CHECK (status IN ('Present', 'Absent', 'Late', 'Present (Start)', 'Present (Full)'));

-- Add missing RLS policies that were wiped
DROP POLICY IF EXISTS "Students can insert own attendance" ON public.attendance_records;
DROP POLICY IF EXISTS "Students can update own attendance" ON public.attendance_records;
DROP POLICY IF EXISTS "Staff can insert sessions" ON public.attendance_sessions;
DROP POLICY IF EXISTS "Staff can update sessions" ON public.attendance_sessions;

CREATE POLICY "Students can insert own attendance" ON public.attendance_records FOR INSERT TO authenticated WITH CHECK (auth.uid() = student_id);
CREATE POLICY "Students can update own attendance" ON public.attendance_records FOR UPDATE TO authenticated USING (auth.uid() = student_id);

CREATE POLICY "Staff can insert sessions" ON public.attendance_sessions FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Staff can update sessions" ON public.attendance_sessions FOR UPDATE TO authenticated USING (true);

-- Refresh schema cache
NOTIFY pgrst, 'reload schema';
