-- Supabase Database Setup for InternHub
-- Run these commands in your Supabase SQL Editor

-- Enable Row Level Security on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.company ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listing ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.application ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message ENABLE ROW LEVEL SECURITY;

-- Users table policies
CREATE POLICY "Users can view their own data" ON public.users
    FOR SELECT USING (auth.uid() = auth_id);

CREATE POLICY "Users can update their own data" ON public.users
    FOR UPDATE USING (auth.uid() = auth_id);

-- Students table policies
CREATE POLICY "Students can view their own data" ON public.students
    FOR SELECT USING (auth.uid() IN (SELECT auth_id FROM public.users WHERE user_id = students.user_id));

CREATE POLICY "Students can update their own data" ON public.students
    FOR UPDATE USING (auth.uid() IN (SELECT auth_id FROM public.users WHERE user_id = students.user_id));

-- Company table policies
CREATE POLICY "Companies can view their own data" ON public.company
    FOR SELECT USING (auth.uid() IN (SELECT auth_id FROM public.users WHERE user_id = company.user_id));

CREATE POLICY "Companies can update their own data" ON public.company
    FOR UPDATE USING (auth.uid() IN (SELECT auth_id FROM public.users WHERE user_id = company.user_id));

-- Admin table policies
CREATE POLICY "Admins can view all data" ON public.admin
    FOR SELECT USING (auth.uid() IN (SELECT auth_id FROM public.users WHERE role = 'admin'));

CREATE POLICY "Admins can update all data" ON public.admin
    FOR ALL USING (auth.uid() IN (SELECT auth_id FROM public.users WHERE role = 'admin'));

-- Listing table policies
CREATE POLICY "Anyone can view listings" ON public.listing
    FOR SELECT USING (true);

CREATE POLICY "Companies can create listings" ON public.listing
    FOR INSERT WITH CHECK (auth.uid() IN (SELECT auth_id FROM public.users WHERE user_id = listing.company_id));

CREATE POLICY "Companies can update their own listings" ON public.listing
    FOR UPDATE USING (auth.uid() IN (SELECT auth_id FROM public.users WHERE user_id = listing.company_id));

-- Application table policies
CREATE POLICY "Students can view their own applications" ON public.application
    FOR SELECT USING (auth.uid() IN (SELECT auth_id FROM public.users WHERE user_id = application.student_id));

CREATE POLICY "Students can create applications" ON public.application
    FOR INSERT WITH CHECK (auth.uid() IN (SELECT auth_id FROM public.users WHERE user_id = application.student_id));

CREATE POLICY "Companies can view applications for their listings" ON public.application
    FOR SELECT USING (auth.uid() IN (
        SELECT auth_id FROM public.users 
        WHERE user_id IN (
            SELECT company_id FROM public.listing 
            WHERE listing_id = application.listing_id
        )
    ));

-- Message table policies
CREATE POLICY "Users can view their own messages" ON public.message
    FOR SELECT USING (auth.uid() IN (SELECT auth_id FROM public.users WHERE user_id = message.sender_id OR user_id = message.receiver_id));

CREATE POLICY "Users can send messages" ON public.message
    FOR INSERT WITH CHECK (auth.uid() IN (SELECT auth_id FROM public.users WHERE user_id = message.sender_id));

-- Create a function to handle user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- This function will be called when a new user is created in auth.users
    -- The user record will be created in the _signUp function in your Flutter app
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
