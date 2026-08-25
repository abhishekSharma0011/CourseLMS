# UMAT-101 LMS v2 — real backend scaffold


## Stack
- Next.js
- React
- Supabase Auth
- Supabase PostgreSQL
- Supabase Storage (to be wired in the next feature pass)

## Run locally
1. Install Node.js 20+.
2. Create a Supabase project.
3. Copy `.env.example` to `.env.local`.
4. Put your Supabase project URL and anon key in `.env.local`.
5. In Supabase SQL Editor, run `supabase/schema.sql`.
6. `npm install`
7. `npm run dev`
8. Open http://localhost:3000

## Create the first users
Create users in Supabase Authentication, then insert matching rows into `profiles` with:
- S. Balasubramanian -> instructor - Abhishek Sharma -> ta
- CH Ramanjaneyulu -> ta
- Students -> student

## Current scope
Authentication + database-backed dashboard/module loading are wired.
PDF storage, assignment submission, grading UI and full staff CRUD are the next implementation layer.

Do not put the Supabase service-role key in browser/client code.


## The screnshot of the site
![Dashboard of the lms site]("./images/UMAT-101-COURSE.png")
