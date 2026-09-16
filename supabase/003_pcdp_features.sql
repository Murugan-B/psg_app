-- =====================================================================================
-- VISHNU MOBILE - PCDP FEATURES EXTENSION (v3)
-- =====================================================================================
-- Adds tables for: Skill Development, Competency Progression, Assessments,
-- Learning Resources, and Recommendation Engine.
-- This migration EXTENDS the existing schema. It does not modify existing tables.

-- =====================================================================================
-- 1. DOMAINS & SKILLS
-- =====================================================================================

CREATE TABLE IF NOT EXISTS public.domains (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  department_id UUID REFERENCES public.departments(id),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.skills (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  domain_id UUID REFERENCES public.domains(id),
  name TEXT NOT NULL,
  description TEXT,
  difficulty_level TEXT DEFAULT 'BEGINNER' CHECK (difficulty_level IN ('BEGINNER','INTERMEDIATE','ADVANCED')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- =====================================================================================
-- 2. COMPETENCY LEVELS & STUDENT COMPETENCY PROGRESS
-- =====================================================================================

CREATE TABLE IF NOT EXISTS public.competency_levels (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  sort_order INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.student_competencies (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id UUID REFERENCES public.profiles(id),
  skill_id UUID REFERENCES public.skills(id),
  competency_level_id UUID REFERENCES public.competency_levels(id),
  progress_percent NUMERIC(5,2) DEFAULT 0,
  score NUMERIC(5,2),
  assessed_at TIMESTAMP WITH TIME ZONE,
  last_assessed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(student_id, skill_id)
);

-- =====================================================================================
-- 3. ASSESSMENTS
-- =====================================================================================

CREATE TABLE IF NOT EXISTS public.assessment_types (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  code TEXT UNIQUE,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.assessments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  assessment_type_id UUID REFERENCES public.assessment_types(id),
  skill_id UUID REFERENCES public.skills(id),
  domain_id UUID REFERENCES public.domains(id),
  max_score NUMERIC(6,2) DEFAULT 100,
  max_attempts INTEGER DEFAULT 1,
  duration_minutes INTEGER,
  due_date TIMESTAMP WITH TIME ZONE,
  is_published BOOLEAN DEFAULT false,
  is_mandatory BOOLEAN DEFAULT true,
  academic_year TEXT,
  semester TEXT,
  created_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.assessment_class_targets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  assessment_id UUID REFERENCES public.assessments(id) ON DELETE CASCADE,
  class_id UUID REFERENCES public.classes(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(assessment_id, class_id)
);

CREATE TABLE IF NOT EXISTS public.questions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  assessment_id UUID REFERENCES public.assessments(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  question_type TEXT NOT NULL CHECK (question_type IN ('MCQ','MULTI_SELECT','SHORT_ANSWER','LONG_ANSWER','CODING','FILE_UPLOAD','NUMERICAL')),
  skill_id UUID REFERENCES public.skills(id),
  order_index INTEGER NOT NULL DEFAULT 0,
  max_marks NUMERIC(6,2) DEFAULT 1,
  difficulty_level TEXT CHECK (difficulty_level IN ('BEGINNER','INTERMEDIATE','ADVANCED')),
  is_required BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.question_options (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  question_id UUID REFERENCES public.questions(id) ON DELETE CASCADE,
  option_text TEXT NOT NULL,
  option_order INTEGER NOT NULL,
  is_correct BOOLEAN DEFAULT false,
  score_override NUMERIC(6,2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.assessment_responses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  assessment_id UUID REFERENCES public.assessments(id),
  question_id UUID REFERENCES public.questions(id),
  student_id UUID REFERENCES public.profiles(id),
  selected_option_id UUID REFERENCES public.question_options(id),
  text_answer TEXT,
  numeric_answer NUMERIC,
  file_url TEXT,
  marks_awarded NUMERIC(6,2),
  is_auto_scored BOOLEAN DEFAULT false,
  scored_by UUID REFERENCES public.profiles(id),
  scored_at TIMESTAMP WITH TIME ZONE,
  attempt_number INTEGER DEFAULT 1,
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(assessment_id, question_id, student_id, attempt_number)
);

CREATE TABLE IF NOT EXISTS public.assessment_scores (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  assessment_id UUID REFERENCES public.assessments(id),
  student_id UUID REFERENCES public.profiles(id),
  score_obtained NUMERIC(6,2),
  max_score NUMERIC(6,2),
  percentage NUMERIC(5,2),
  status TEXT CHECK (status IN ('PASSED','FAILED','PENDING','NOT_ATTEMPTED')),
  attempt_number INTEGER DEFAULT 1,
  submitted_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(assessment_id, student_id, attempt_number)
);

-- =====================================================================================
-- 4. LEARNING RESOURCES
-- =====================================================================================

CREATE TABLE IF NOT EXISTS public.resource_types (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.learning_resources (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  resource_type_id UUID REFERENCES public.resource_types(id),
  url TEXT NOT NULL,
  skill_id UUID REFERENCES public.skills(id),
  domain_id UUID REFERENCES public.domains(id),
  difficulty_level TEXT CHECK (difficulty_level IN ('BEGINNER','INTERMEDIATE','ADVANCED')),
  estimated_duration_minutes INTEGER,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.student_resource_views (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id UUID REFERENCES public.profiles(id),
  resource_id UUID REFERENCES public.learning_resources(id),
  view_duration_seconds INTEGER,
  completed BOOLEAN DEFAULT false,
  viewed_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  completion_percentage NUMERIC(5,2) DEFAULT 0,
  UNIQUE(student_id, resource_id)
);

-- =====================================================================================
-- 5. RECOMMENDATION ENGINE
-- =====================================================================================

CREATE TABLE IF NOT EXISTS public.recommendation_rules (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  rule_type TEXT NOT NULL CHECK (rule_type IN ('SKILL_GAP','LOW_ATTENDANCE','ASSESSMENT_PERFORMANCE','DOMAIN_RECOMMENDED','PREREQUISITE_MISSING')),
  priority INTEGER DEFAULT 10,
  conditions JSONB NOT NULL,
  action JSONB NOT NULL,
  is_active BOOLEAN DEFAULT true,
  ml_model_name TEXT,
  created_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.recommendations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id UUID REFERENCES public.profiles(id),
  rule_id UUID REFERENCES public.recommendation_rules(id),
  skill_id UUID REFERENCES public.skills(id),
  resource_id UUID REFERENCES public.learning_resources(id),
  assessment_id UUID REFERENCES public.assessments(id),
  title TEXT NOT NULL,
  description TEXT,
  score NUMERIC(5,2),
  is_dismissed BOOLEAN DEFAULT false,
  is_completed BOOLEAN DEFAULT false,
  valid_until TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- =====================================================================================
-- 6. TRIGGERS: Auto-update updated_at timestamps
-- =====================================================================================

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_update_updated_at_domains
  BEFORE UPDATE ON public.domains
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trig_update_updated_at_skills
  BEFORE UPDATE ON public.skills
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trig_update_updated_at_student_competencies
  BEFORE UPDATE ON public.student_competencies
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trig_update_updated_at_assessments
  BEFORE UPDATE ON public.assessments
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trig_update_updated_at_questions
  BEFORE UPDATE ON public.questions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trig_update_updated_at_question_options
  BEFORE UPDATE ON public.question_options
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trig_update_updated_at_learning_resources
  BEFORE UPDATE ON public.learning_resources
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trig_update_updated_at_recommendations
  BEFORE UPDATE ON public.recommendations
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trig_update_updated_at_recommendation_rules
  BEFORE UPDATE ON public.recommendation_rules
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trig_update_updated_at_assessment_scores
  BEFORE UPDATE ON public.assessment_scores
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- =====================================================================================
-- 7. ROW LEVEL SECURITY (RLS) FOR NEW TABLES
-- =====================================================================================

ALTER TABLE public.domains ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.competency_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_competencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessment_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessment_class_targets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessment_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessment_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resource_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.learning_resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_resource_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendations ENABLE ROW LEVEL SECURITY;

-- Read-friendly tables (anyone authenticated can read)
CREATE POLICY "Domains viewable by all" ON public.domains FOR SELECT TO authenticated USING (true);
CREATE POLICY "Skills viewable by all" ON public.skills FOR SELECT TO authenticated USING (true);
CREATE POLICY "Competency levels viewable by all" ON public.competency_levels FOR SELECT TO authenticated USING (true);
CREATE POLICY "Assessment types viewable by all" ON public.assessment_types FOR SELECT TO authenticated USING (true);
CREATE POLICY "Resource types viewable by all" ON public.resource_types FOR SELECT TO authenticated USING (true);
CREATE POLICY "Assessments viewable by all" ON public.assessments FOR SELECT TO authenticated USING (true);
CREATE POLICY "Questions viewable by all" ON public.questions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Question options viewable by all" ON public.question_options FOR SELECT TO authenticated USING (true);
CREATE POLICY "Learning resources viewable by all" ON public.learning_resources FOR SELECT TO authenticated USING (true);
CREATE POLICY "Assessment class targets viewable by all" ON public.assessment_class_targets FOR SELECT TO authenticated USING (true);

-- Admin/creator can manage skills, domains, assessments, questions, resources
CREATE POLICY "Admins can insert skills" ON public.skills FOR INSERT TO authenticated WITH CHECK (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admins can update skills" ON public.skills FOR UPDATE TO authenticated USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admins can insert domains" ON public.domains FOR INSERT TO authenticated WITH CHECK (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admins can update domains" ON public.domains FOR UPDATE TO authenticated USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admins can manage assessment types" ON public.assessment_types FOR ALL TO authenticated USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admins can manage resource types" ON public.resource_types FOR ALL TO authenticated USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);

-- Assessments: admin or creator can insert/update
CREATE POLICY "Faculties can create assessments" ON public.assessments FOR INSERT TO authenticated WITH CHECK (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin','faculty'))
);
CREATE POLICY "Faculties can update own assessments" ON public.assessments FOR UPDATE TO authenticated USING (
  created_by = auth.uid() OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "Faculties can create questions" ON public.questions FOR INSERT TO authenticated WITH CHECK (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin','faculty'))
);

CREATE POLICY "Faculties can create resources" ON public.learning_resources FOR INSERT TO authenticated WITH CHECK (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin','faculty'))
);
CREATE POLICY "Faculties can update own resources" ON public.learning_resources FOR UPDATE TO authenticated USING (
  created_by = auth.uid() OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);

-- Student competencies: students can insert their own, faculty can read, admin can manage
CREATE POLICY "Students can insert own competency" ON public.student_competencies FOR INSERT TO authenticated WITH CHECK (
  student_id = auth.uid()
);
CREATE POLICY "Competencies readable by faculty and own" ON public.student_competencies FOR SELECT TO authenticated USING (
  student_id = auth.uid() OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('faculty','admin'))
);
CREATE POLICY "Faculty can update competency" ON public.student_competencies FOR UPDATE TO authenticated USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('faculty','admin'))
);

-- Assessment responses: students insert own, faculty can read, faculty/admin can update scores
CREATE POLICY "Students can insert own responses" ON public.assessment_responses FOR INSERT TO authenticated WITH CHECK (
  student_id = auth.uid()
);
CREATE POLICY "Assessment responses readable by faculty" ON public.assessment_responses FOR SELECT TO authenticated USING (
  student_id = auth.uid() OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('faculty','admin'))
);
CREATE POLICY "Faculty can update assessment scores" ON public.assessment_responses FOR UPDATE TO authenticated USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('faculty','admin'))
);

-- Assessment scores: students read own, faculty read for their assessments, admin full
CREATE POLICY "Students can read own scores" ON public.assessment_scores FOR SELECT TO authenticated USING (
  student_id = auth.uid() OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('faculty','admin'))
);
CREATE POLICY "System can insert scores" ON public.assessment_scores FOR INSERT TO authenticated WITH CHECK (true);

-- Student resource views: students insert/update own
CREATE POLICY "Students can insert own resource views" ON public.student_resource_views FOR INSERT TO authenticated WITH CHECK (
  student_id = auth.uid()
);
CREATE POLICY "Students can update own resource views" ON public.student_resource_views FOR UPDATE TO authenticated USING (
  student_id = auth.uid() OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "Resource views readable by faculty/admin" ON public.student_resource_views FOR SELECT TO authenticated USING (
  student_id = auth.uid() OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('faculty','admin'))
);

-- Recommendation rules: admin can manage, all can read
CREATE POLICY "Recommendation rules readable by all" ON public.recommendation_rules FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage recommendation rules" ON public.recommendation_rules FOR INSERT TO authenticated WITH CHECK (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admins can update recommendation rules" ON public.recommendation_rules FOR UPDATE TO authenticated USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);

-- Recommendations: students read own, system inserts, students can dismiss
CREATE POLICY "Students can read own recommendations" ON public.recommendations FOR SELECT TO authenticated USING (
  student_id = auth.uid() OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('faculty','admin'))
);
CREATE POLICY "Students can update own recommendations" ON public.recommendations FOR UPDATE TO authenticated USING (
  student_id = auth.uid() OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('faculty','admin'))
);
CREATE POLICY "System can insert recommendations" ON public.recommendations FOR INSERT TO authenticated WITH CHECK (true);

-- =====================================================================================
-- 8. DEFAULT DATA
-- =====================================================================================

INSERT INTO public.competency_levels (name, description, sort_order) VALUES
  ('Beginner', 'Foundational understanding with limited practice', 1),
  ('Novice', 'Basic familiarity with some guidance', 2),
  ('Intermediate', 'Competent but requires occasional reference', 3),
  ('Advanced', 'Proficient independently', 4),
  ('Expert', 'Mastery level, can teach and mentor', 5)
ON CONFLICT (name) DO NOTHING;

INSERT INTO public.assessment_types (name, code, description) VALUES
  ('Quiz', 'QUIZ', 'Short timed assessment with auto-grading'),
  ('Assignment', 'ASSIGNMENT', 'Take-home assignment, may include file upload'),
  ('Project', 'PROJECT', 'Multi-part project with manual grading'),
  ('Exam', 'EXAM', 'Final or midterm examination'),
  ('Lab Report', 'LAB', 'Laboratory practical assessment')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.resource_types (name) VALUES
  ('Video'), ('Article'), ('Document'), ('Link'), ('Interactive')
ON CONFLICT (name) DO NOTHING;

INSERT INTO public.domains (name, description) VALUES
  ('Programming Fundamentals', 'Core programming concepts and syntax'),
  ('Data Structures & Algorithms', 'Problem-solving and algorithmic thinking'),
  ('Database Systems', 'Data modeling, SQL, and database design'),
  ('Web Development', 'Frontend and backend web application development'),
  ('Operating Systems', 'System-level concepts and resource management'),
  ('Networking', 'Computer networks and distributed systems'),
  ('Mobile Development', 'Android and iOS application development'),
  ('Soft Skills', 'Communication, teamwork, and professional skills')
ON CONFLICT (name) DO NOTHING;

INSERT INTO public.skills (domain_id, name, description, difficulty_level) VALUES
  ((SELECT id FROM public.domains WHERE name = 'Programming Fundamentals'), 'Variables & Data Types', 'Understanding variables, constants, and data type categories', 'BEGINNER'),
  ((SELECT id FROM public.domains WHERE name = 'Programming Fundamentals'), 'Control Structures', 'Loops, conditionals, and branching logic', 'BEGINNER'),
  ((SELECT id FROM public.domains WHERE name = 'Programming Fundamentals'), 'Functions', 'Modular code design and function composition', 'INTERMEDIATE'),
  ((SELECT id FROM public.domains WHERE name = 'Programming Fundamentals'), 'Error Handling', 'Exception handling and defensive programming', 'INTERMEDIATE'),
  ((SELECT id FROM public.domains WHERE name = 'Data Structures & Algorithms'), 'Arrays & Lists', 'Understanding and manipulating array structures', 'BEGINNER'),
  ((SELECT id FROM public.domains WHERE name = 'Data Structures & Algorithms'), 'Linked Lists', 'Node-based data structures', 'INTERMEDIATE'),
  ((SELECT id FROM public.domains WHERE name = 'Data Structures & Algorithms'), 'Stacks & Queues', 'LIFO and FIFO data structures', 'INTERMEDIATE'),
  ((SELECT id FROM public.domains WHERE name = 'Data Structures & Algorithms'), 'Trees', 'Binary trees, BSTs, and tree traversals', 'ADVANCED'),
  ((SELECT id FROM public.domains WHERE name = 'Data Structures & Algorithms'), 'Graphs', 'Graph representation and algorithms', 'ADVANCED'),
  ((SELECT id FROM public.domains WHERE name = 'Data Structures & Algorithms'), 'Sorting Algorithms', 'Comparative analysis of sorting techniques', 'INTERMEDIATE'),
  ((SELECT id FROM public.domains WHERE name = 'Database Systems'), 'SQL Basics', 'SELECT, INSERT, UPDATE, DELETE operations', 'BEGINNER'),
  ((SELECT id FROM public.domains WHERE name = 'Database Systems'), 'Joins', 'INNER, LEFT, RIGHT, FULL joins', 'INTERMEDIATE'),
  ((SELECT id FROM public.domains WHERE name = 'Database Systems'), 'Normalization', '1NF, 2NF, 3NF normalization forms', 'INTERMEDIATE'),
  ((SELECT id FROM public.domains WHERE name = 'Web Development'), 'HTML & CSS', 'Structure and styling web pages', 'BEGINNER'),
  ((SELECT id FROM public.domains WHERE name = 'Web Development'), 'JavaScript ES6+', 'Modern JavaScript features', 'INTERMEDIATE'),
  ((SELECT id FROM public.domains WHERE name = 'Web Development'), 'React', 'Component-based UI development', 'ADVANCED'),
  ((SELECT id FROM public.domains WHERE name = 'Operating Systems'), 'Process Management', 'Processes, threads, and scheduling', 'INTERMEDIATE'),
  ((SELECT id FROM public.domains WHERE name = 'Operating Systems'), 'Memory Management', 'Virtual memory and paging', 'ADVANCED'),
  ((SELECT id FROM public.domains WHERE name = 'Soft Skills'), 'Technical Communication', 'Writing clear technical documentation', 'BEGINNER'),
  ((SELECT id FROM public.domains WHERE name = 'Soft Skills'), 'Presentation Skills', 'Delivering effective technical presentations', 'INTERMEDIATE')
ON CONFLICT (name) DO NOTHING;

-- Default recommendation rules
INSERT INTO public.recommendation_rules (name, description, rule_type, priority, conditions, action) VALUES
  ('Low Attendance Warning', 'Recommend reviewing missed material when attendance is below 75%', 'LOW_ATTENDANCE', 10,
   '{"threshold": 0.75, "min_sessions": 5}',
   '{"type": "message", "title": "Low Attendance Alert", "description": "Your attendance is below 75%. Please catch up on missed classes and contact your faculty."}'),
  ('Skill Gap Identification', 'Recommend resources for skills with competency below 50%', 'SKILL_GAP', 20,
   '{"min_progress_percent": 50, "min_assessments": 1}',
   '{"type": "recommend_resource", "based_on": "skill_id"}'),
  ('Weak Area Practice', 'Recommend additional practice for poorly performed assessments', 'ASSESSMENT_PERFORMANCE', 15,
   '{"min_percentage": 60}',
   '{"type": "recommend_assessment", "based_on": "skill_id"}');

-- =====================================================================================
-- 9. REALTIME PUBLICATION (for assessment response streaming)
-- =====================================================================================

alter publication supabase_realtime add table public.assessment_responses;
alter publication supabase_realtime add table public.student_competencies;

-- Tell Supabase to refresh its schema cache
NOTIFY pgrst, 'reload schema';
