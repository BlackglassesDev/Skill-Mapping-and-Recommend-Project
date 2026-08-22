# Skill Mapping for Computer Engineering Curriculum

เว็บแอปพลิเคชัน Skill Mapping สำหรับหลักสูตรวิศวกรรมคอมพิวเตอร์ — มหาวิทยาลัยเทคโนโลยีราชมงคลล้านนา เชียงใหม่ (RMUTL)

[Thai Version Content Readme](README.TH.md)

A web application that links **courses**, **skills**, and **careers** for the Computer Engineering curriculum. Students assess their skill levels, compare them against career requirements (Skill Gap analysis), and receive course recommendations, while teachers and admins manage curricula, courses, skills, and users.

## Features

### Students
- Select curriculum, record grades per course (`/home`)
- Skill assessment: achieved skill level is computed as `course_skill_level × (grade_point / 4.0)` (grades `F`/`NOT_TAKEN` excluded)
- Skill Gap analysis against a chosen career, visualized with a Radar Chart and Skill Matrix table (`/assess_skills`)
- Course recommendations to fill missing skills; course info browsing

### Teachers
- Manage courses (CRUD) for their curriculum (`/manage-courses`)
- Map courses to skills with skill levels (`/mapping-skills`)
- Per-course dashboard and CSV report (`/course-dashboard`)

### Admins
- Manage users, curricula, and the global skill repository (SFIA-based master data) (`/manage_users`, `/curriculums_manage`, `/manage_global_skills`)
- System summary dashboard (`/admin_dashboard`)

### Authentication
- Register / login with bcrypt password hashing and JWT session cookie (1 day, httpOnly)
- Password reset via OTP email (nodemailer)

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend & Backend | SvelteKit 2 (Svelte 5), Tailwind CSS 4, Vite 7 |
| Database | MySQL 8 (mysql2 pool, `src/lib/server/db.js`) |
| Auth | bcrypt, jsonwebtoken (JWT in httpOnly cookie) |
| Email | nodemailer (OTP for password reset) |
| Deployment | Docker Compose (app + MySQL + Caddy + phpMyAdmin), `@sveltejs/adapter-node` |

## Project Structure

```text
skill_mapping_project/
├── src/
│   ├── hooks.server.js          # JWT session verify + role-based route guards
│   ├── lib/server/db.js         # MySQL connection pool
│   └── routes/
│       ├── (frontend)/(auth)/   # login, register, reset-password
│       ├── (frontend)/(users)/  # home, assess_skills, info_subject (students)
│       ├── (frontend)/(teacher)/# teacherPage, manage-courses, mapping-skills, course-dashboard
│       ├── (frontend)/(admin)/  # adminPage, manage_users, curriculums_manage, manage_global_skills, admin_dashboard
│       └── api/                 # auth (login/register/logout), job_skill, export-*-csv
├── database/init.sql            # Schema + seed data (curriculums, users, courses, skills, jobs, mappings)
├── Dockerfile                   # node:22-alpine, builds and runs `node build`
├── docker-compose.yml           # app, db, gateway (Caddy), phpmyadmin
└── Caddyfile                    # HTTPS reverse proxy -> app:3000
```

## Database Schema

| Table | Purpose |
|---|---|
| `curriculum` | Curriculums (e.g., Computer Engineering) |
| `users` | Users with role `student` / `teacher` / `admin`, OTP columns |
| `courses` | Courses (code, name, credits, curriculum) |
| `skills` | Skill master data (SFIA codes, standard keywords, description) |
| `job` / `job_skills` | Careers and required skill levels |
| `course_skills` | Course-to-skill mapping with skill level taught |
| `student_grades` | Per-student grades (letter + grade point) |

Access control is enforced in `src/hooks.server.js`: admin, teacher, and student route prefixes are guarded with redirects based on the JWT role.

## Getting Started

### Prerequisites
- Node.js 22+ and npm (local development)
- Docker + Docker Compose (deployment)

### Local Development

```bash
npm install
cp .env.example .env   # fill in values, see below
npm run dev            # http://localhost:5173
```

A local MySQL instance is required; `database/init.sql` creates and seeds the `skill_mapping` database.

### Environment Variables (`.env`)

```env
DB_HOST=
DB_PORT=3306
DB_USER=
DB_PASS=
DB_NAME=
MYSQL_ROOT_PASSWORD=   # used by docker-compose for MySQL init
MYSQL_DATABASE=
APP_SECRET=            # JWT signing secret
MAIL_SKILL_WEB=        # email account for OTP mail
PASS_MAIL=
```

### Deploy with Docker Compose

```bash
docker compose up -d --build
```

Services:
- **app** — SvelteKit Node build, internal port 3000
- **db** — MySQL 8 (Asia/Bangkok timezone), auto-initialized from `database/init.sql`, data persisted in `db_data` volume
- **gateway** — Caddy reverse proxy with automatic HTTPS on ports 80/443
- **phpmyadmin** — database UI on `127.0.0.1:8080` (remove before production)

### Useful Commands

| Command | Description |
|---|---|
| `npm run dev` | Start dev server |
| `npm run build` | Production build |
| `npm run preview` | Preview production build |
| `npm run check` | svelte-check type check |
| `npm run lint` | Prettier + ESLint check |
| `npm run format` | Format code with Prettier |

## Demo Accounts (seed data)

| Username | Role |
|---|---|
| `admin` | admin |
| `teacher` | teacher |
| `user` | student |

## Academic Project

Bachelor's thesis project, Department of Computer Engineering, Rajamangala University of Technology Lanna, Chiang Mai. The skill assessment applies Bloom's Taxonomy levels per course and scales grades (0–4.0) into skill levels for Skill Gap analysis, with skill master data based on SFIA.
