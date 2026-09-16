-- =====================================================================================
-- VISHNU MOBILE - AUTO PROFILE CREATION TRIGGER (v4)
-- =====================================================================================
-- When a new user signs up via Supabase Auth, automatically create their profile
-- from the user_metadata stored during signUpWithEmail().
-- This allows the sign-up flow to work end-to-end.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, role, full_name, employee_id, roll_number, department, phone, created_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'role', 'student'),
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'full_name', 'New User'),
    NEW.raw_user_meta_data->>'employee_id',
    NEW.raw_user_meta_data->>'roll_number',
    NEW.raw_user_meta_data->>'department',
    NEW.raw_user_meta_data->>'phone',
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Tell Supabase to refresh its schema cache
NOTIFY pgrst, 'reload schema';
