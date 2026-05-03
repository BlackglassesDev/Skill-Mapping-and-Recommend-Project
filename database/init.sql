SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
SET character_set_connection = utf8mb4;

CREATE DATABASE IF NOT EXISTS skill_mapping CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE skill_mapping;

-- หลักสูตร
CREATE TABLE curriculum (
    curriculum_id INT PRIMARY KEY AUTO_INCREMENT,
    curriculum_name VARCHAR(255) NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT INTO curriculum (curriculum_name)
VALUES ('วิศวกรรมคอมพิวเตอร์'),('วิศวกรรมไฟฟ้า');

-- ข้อมูลผู้ใช้
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255),
    username VARCHAR(100) UNIQUE,
    email VARCHAR(150) UNIQUE,
    password VARCHAR(255),
    role ENUM('student', 'teacher', 'admin') DEFAULT 'student',
    curriculum_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    otp_code VARCHAR(6),
    otp_expires DATETIME,
    FOREIGN KEY (curriculum_id) REFERENCES curriculum(curriculum_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ตารางรายวิชา
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(20) NOT NULL,
    course_name VARCHAR(255) NOT NULL,
    credits INT NOT NULL,
    description TEXT,
    curriculum_id INT,
    FOREIGN KEY (curriculum_id) REFERENCES curriculum(curriculum_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT INTO courses (course_code, course_name, credits, curriculum_id)
-- รหัสวิชา   ชื่อวิชา   หน่วยกิต  ไอดีหลักสูตร
VALUES ('CPE101', 'Computer Programming', 3, 1),
    ('CPE102', 'Digital Logic Design', 3, 1),
    ('IT201', 'Database Systems', 3, 1),
    ('GEN101', 'English for Communication', 2, 1),

    ('GEN101', 'test for Communication', 3, 2);

CREATE TABLE job (
    job_id INT AUTO_INCREMENT,
    name_job VARCHAR(255) NOT NULL,
    curriculum_id INT,
    PRIMARY KEY (job_id),
    FOREIGN KEY (curriculum_id) REFERENCES curriculum(curriculum_id)
)ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT INTO job (name_job, curriculum_id) VALUE
    ('วิศวกรปัญญาประดิษฐ์และข้อมูล', 1),
    ('วิศวกรสมองกลฝังตัวและไอโอที', 1),
    ('ผู้ดูแลระบบเครือข่ายและคลาวด์', 1),
    ('นักพัฒนาซอฟต์แวร์', 1),
    ('วิศวกรรมคอมพิวเตอร์', 1);

-- ตารางเก็บชื่อทักษะหลัก (Master Data)
CREATE TABLE skills (
    skill_id INT AUTO_INCREMENT PRIMARY KEY,
    skill_name VARCHAR(255) NOT NULL UNIQUE, -- ใส่ UNIQUE กันชื่อซ้ำ
    curriculum_id INT,
    FOREIGN KEY (curriculum_id) REFERENCES curriculum(curriculum_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT INTO skills (skill_name, curriculum_id) VALUE
-- ชื่อสกิล    ไอดีหลักสูตร
    ('1test skill', 1),
    ('2test skill', 1),
    ('3test skill', 1),
    ('4test skill', 1),
    ('5test skill', 1),
    ('6test skill', 1);

CREATE TABLE job_skills (
    job_id INT,
    skill_id INT,
    level_skill INT, -- เก็บ Level ที่ต้องการสำหรับอาชีพนี้
    PRIMARY KEY (job_id, skill_id), -- ป้องกันการใส่สกิลเดิมซ้ำในอาชีพเดียวกัน
    FOREIGN KEY (job_id) REFERENCES job(job_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT INTO job_skills (job_id, skill_id, level_skill) VALUE
    (1, 3, 4),
    (1, 1, 3),
    (2, 1, 1),
    (2, 2, 2),
    (3, 4, 4),
    (4, 5, 1),
    (5, 6, 2);

-- ตารางเชื่อมโยง รายวิชา - ทักษะ
CREATE TABLE course_skills (
    course_id INT,
    skill_id INT,
    skill_level INT, -- ระดับทักษะที่วิชานี้สอน (เช่น 1-5)
    PRIMARY KEY (course_id, skill_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT INTO course_skills(couse_id, skill_id, skill_level) VALUE
    (1, 5, 4),
    (2, 6, 4),
    (2, 1, 3),
    (1, 1, 4),
    (3, 3, 4);

CREATE TABLE student_grades (
    user_id INT,
    course_id INT,
    grade FLOAT NOT NULL, -- เก็บเป็นแต้ม 4.0, 3.5, 3.0...
    PRIMARY KEY (user_id, course_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;