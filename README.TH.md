# Skill Mapping สำหรับหลักสูตรวิศวกรรมคอมพิวเตอร์

เว็บแอปพลิเคชัน Skill Mapping สำหรับหลักสูตรวิศวกรรมคอมพิวเตอร์ — มหาวิทยาลัยเทคโนโลยีราชมงคลล้านนา เชียงใหม่ (RMUTL)

เว็บแอปพลิเคชันที่เชื่อมโยง **รายวิชา**, **ทักษะ** และ **สายอาชีพ** สำหรับหลักสูตรวิศวกรรมคอมพิวเตอร์ นักศึกษาสามารถประเมินระดับทักษะของตนเอง เปรียบเทียบกับทักษะที่แต่ละสายอาชีพต้องการ (การวิเคราะห์ Skill Gap) และรับคำแนะนำรายวิชา ขณะที่อาจารย์และผู้ดูแลระบบสามารถจัดการหลักสูตร รายวิชา ทักษะ และผู้ใช้งานได้

## คุณสมบัติของระบบ

### นักศึกษา
- เลือกหลักสูตรและบันทึกเกรดรายวิชา (`/home`)
- การประเมินทักษะ: ระดับทักษะที่ได้รับจะคำนวณจาก `course_skill_level × (grade_point / 4.0)` โดยไม่นำเกรด `F` / `NOT_TAKEN` มาคำนวณ
- การวิเคราะห์ Skill Gap เปรียบเทียบกับสายอาชีพที่เลือก แสดงผลด้วย Radar Chart และตาราง Skill Matrix (`/assess_skills`)
- แนะนำรายวิชาเพื่อเติมเต็มทักษะที่ขาด และเรียกดูข้อมูลรายวิชา

### อาจารย์
- จัดการรายวิชา (CRUD) สำหรับหลักสูตรของตนเอง (`/manage-courses`)
- เชื่อมโยงรายวิชากับทักษะพร้อมกำหนดระดับทักษะ (`/mapping-skills`)
- Dashboard รายวิชาและรายงาน CSV (`/course-dashboard`)

### ผู้ดูแลระบบ
- จัดการผู้ใช้งาน หลักสูตร และคลังทักษะส่วนกลาง (ข้อมูลหลักอิงตาม SFIA) (`/manage_users`, `/curriculums_manage`, `/manage_global_skills`)
- Dashboard สรุปข้อมูลระบบ (`/admin_dashboard`)

### การยืนยันตัวตน
- สมัครสมาชิก / เข้าสู่ระบบด้วยการเข้ารหัสรหัสผ่านด้วย bcrypt และ JWT session cookie (อายุ 1 วัน, `httpOnly`)
- รีเซ็ตรหัสผ่านผ่าน OTP ทางอีเมล (nodemailer)

## เทคโนโลยีที่ใช้

| ชั้นระบบ | เทคโนโลยี |
|---|---|
| Frontend & Backend | SvelteKit 2 (Svelte 5), Tailwind CSS 4, Vite 7 |
| ฐานข้อมูล | MySQL 8 (mysql2 pool, `src/lib/server/db.js`) |
| การยืนยันตัวตน | bcrypt, jsonwebtoken (JWT ใน `httpOnly` cookie) |
| อีเมล | nodemailer (OTP สำหรับรีเซ็ตรหัสผ่าน) |
| การ Deploy | Docker Compose (app + MySQL + Caddy + phpMyAdmin), `@sveltejs/adapter-node` |

## โครงสร้างโปรเจกต์

```text
skill_mapping_project/
├── src/
│   ├── hooks.server.js          # ตรวจสอบ JWT session + ควบคุมสิทธิ์ตาม Role
│   ├── lib/server/db.js         # MySQL connection pool
│   └── routes/
│       ├── (frontend)/(auth)/   # login, register, reset-password
│       ├── (frontend)/(users)/  # home, assess_skills, info_subject (นักศึกษา)
│       ├── (frontend)/(teacher)/# teacherPage, manage-courses, mapping-skills, course-dashboard
│       ├── (frontend)/(admin)/  # adminPage, manage_users, curriculums_manage, manage_global_skills, admin_dashboard
│       └── api/                 # auth (login/register/logout), job_skill, export-*-csv
├── database/init.sql            # Schema + seed data (curriculums, users, courses, skills, jobs, mappings)
├── Dockerfile                   # node:22-alpine, build และรัน `node build`
├── docker-compose.yml           # app, db, gateway (Caddy), phpmyadmin
└── Caddyfile                    # HTTPS reverse proxy -> app:3000
```

## โครงสร้างฐานข้อมูล

| ตาราง | วัตถุประสงค์ |
|---|---|
| `curriculum` | หลักสูตร (เช่น วิศวกรรมคอมพิวเตอร์) |
| `users` | ผู้ใช้งาน พร้อม Role `student` / `teacher` / `admin` และข้อมูล OTP |
| `courses` | รายวิชา (รหัสวิชา, ชื่อวิชา, หน่วยกิต, หลักสูตร) |
| `skills` | ข้อมูลหลักของทักษะ (รหัส SFIA, คำศัพท์มาตรฐาน, คำอธิบาย) |
| `job` / `job_skills` | สายอาชีพและระดับทักษะที่จำเป็น |
| `course_skills` | การเชื่อมโยงรายวิชากับทักษะพร้อมระดับทักษะที่สอน |
| `student_grades` | เกรดของนักศึกษาแต่ละรายวิชา (เกรดตัวอักษร + grade point) |

การควบคุมสิทธิ์การเข้าถึงดำเนินการใน `src/hooks.server.js` โดย Route ของ admin, teacher และ student จะถูกป้องกันด้วยการ Redirect ตาม Role ที่อยู่ใน JWT

## การเริ่มต้นใช้งาน

### สิ่งที่ต้องติดตั้ง
- Node.js 22+ และ npm (สำหรับการพัฒนาในเครื่อง)
- Docker + Docker Compose (สำหรับการ Deploy)

### การพัฒนาในเครื่อง

```bash
npm install
cp .env.example .env   # กำหนดค่า ดูรายละเอียดด้านล่าง
npm run dev            # http://localhost:5173
```

จำเป็นต้องมี MySQL สำหรับการพัฒนาในเครื่อง โดย `database/init.sql` จะสร้างและใส่ข้อมูลเริ่มต้นให้กับฐานข้อมูล `skill_mapping`

### ตัวแปรสภาพแวดล้อม (`.env`)

```env
DB_HOST=
DB_PORT=3306
DB_USER=
DB_PASS=
DB_NAME=
MYSQL_ROOT_PASSWORD=   # ใช้โดย docker-compose สำหรับการเริ่มต้น MySQL
MYSQL_DATABASE=
APP_SECRET=            # JWT signing secret
MAIL_SKILL_WEB=        # บัญชีอีเมลสำหรับส่ง OTP
PASS_MAIL=
```

### Deploy ด้วย Docker Compose

```bash
docker compose up -d --build
```

Services:
- **app** — SvelteKit Node build, พอร์ตภายใน 3000
- **db** — MySQL 8 (เขตเวลา Asia/Bangkok), เริ่มต้นอัตโนมัติจาก `database/init.sql` และเก็บข้อมูลถาวรใน Volume `db_data`
- **gateway** — Caddy reverse proxy พร้อม HTTPS อัตโนมัติบนพอร์ต 80/443
- **phpmyadmin** — เครื่องมือจัดการฐานข้อมูลที่ `127.0.0.1:8080` (ควรถอดออกก่อนใช้งาน Production)

### คำสั่งที่ใช้บ่อย

| คำสั่ง | คำอธิบาย |
|---|---|
| `npm run dev` | เริ่ม Development Server |
| `npm run build` | สร้าง Production Build |
| `npm run preview` | Preview Production Build |
| `npm run check` | ตรวจสอบด้วย svelte-check |
| `npm run lint` | ตรวจสอบ Prettier + ESLint |
| `npm run format` | จัดรูปแบบโค้ดด้วย Prettier |

## บัญชีสำหรับทดลองใช้งาน (ข้อมูล Seed)

| Username | Role |
|---|---|
| `admin` | admin |
| `teacher` | teacher |
| `user` | student |

## ข้อมูลโครงงานทางวิชาการ

โครงงานปริญญานิพนธ์ระดับปริญญาตรี สาขาวิศวกรรมคอมพิวเตอร์ มหาวิทยาลัยเทคโนโลยีราชมงคลล้านนา เชียงใหม่ โดยระบบประเมินทักษะใช้ระดับของ Bloom's Taxonomy ในแต่ละรายวิชา และแปลงเกรด (0–4.0) เป็นระดับทักษะสำหรับการวิเคราะห์ Skill Gap โดยข้อมูลหลักของทักษะอ้างอิงจาก SFIA
