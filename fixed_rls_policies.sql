-- Fixed RLS policies with proper type casting
-- Update RLS policies for the new fields
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;

-- Policy for students to read their own data
DROP POLICY IF EXISTS "Students can read own data" ON public.students;
CREATE POLICY "Students can read own data" ON public.students
    FOR SELECT USING (auth.uid() = user_id::uuid);

-- Policy for students to update their own data
DROP POLICY IF EXISTS "Students can update own data" ON public.students;
CREATE POLICY "Students can update own data" ON public.students
    FOR UPDATE USING (auth.uid() = user_id::uuid);

-- Policy for companies to read student profiles (for viewing profiles)
DROP POLICY IF EXISTS "Companies can read student profiles" ON public.students;
CREATE POLICY "Companies can read student profiles" ON public.students
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.company 
            WHERE company.user_id = auth.uid()
        )
    );

-- Policy for admins to read all student data
DROP POLICY IF EXISTS "Admins can read all student data" ON public.students;
CREATE POLICY "Admins can read all student data" ON public.students
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.admin 
            WHERE admin.user_id = auth.uid()
        )
    );
