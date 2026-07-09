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

INSERT INTO users (full_name, username, email, password, role, curriculum_id) VALUES
('ชโนดม อองกุลนะ','admin','admin@demo.com','$2b$10$qhqxvABMbQRNjJsLWq4g.ufRSd5GKsD3Mr8PKv.VhYbx6ZHJhEqkW','admin',null),
('จิดาภา กันทวงศ์','teacher','teacher@demo.com','$2b$10$2iJgQEBRfBueH4XPJme0gOw8rDCFiIRsO1h3v98VvgwbHY7K8ji6m','teacher',null),
('อรนุช ลุงหลิ่ง','user','user@demo.com','$2b$10$PkYhLV5y3qiRapzLWV8T9.u2/1zhCZ9Dv6HNHkhL57K5CIZhXvL46','student',1);


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
VALUES ('ENGCC304', 'Computer Programming', 3, 1),
    ('ENGEE105', 'Fundamental of Engineering Training', 1, 1),
    ('ENGEE106', 'Electrical Instruments and Measurements', 3, 1),
    ('ENGEE160', 'Engineering Electronics', 3, 1),
    ('ENGEE161', 'Digital Circuits and Logic Design', 3, 1),
    ('ENGEE501', 'Electric Circuits', 3, 1),
    ('ENGCE106', 'Data Communication and Networks', 3, 1),
    ('ENGCE110', 'Computer and Data Security', 3, 1),
    ('ENGCE117', 'Computer Programming for Computer Engineer', 3, 1),
    ('ENGCE120', 'Basic Computer Engineering Skills', 2, 1),
    ('ENGCE121', 'Computer Architecture and Organization', 3, 1),
    ('ENGCE122', 'Microprocessors and Interface', 3, 1),
    ('ENGCE123', 'Embedded Systems and Internet of Everything', 3, 1),
    ('ENGCE124', 'Data Structures and Algorithms', 3, 1),
    ('ENGCE125', 'Operating Systems', 3, 1),
    ('ENGCE126', 'Database Systems', 3, 1),
    ('ENGCE127', 'System Analysis and Design', 3, 1),
    ('ENGCE200', 'Digital Systems Design', 3, 1),
    ('ENGCE400', 'Introduction to Artificial Intelligence and Machine Learning', 3, 1),
    ('ENGCE109', 'Computer Networks', 3, 1),
    ('ENGCE134', 'Network Security', 3, 1),
    ('ENGCE174', 'Object-Oriented Programming', 3, 1),
    ('ENGCE301', 'Software Design and Development', 3, 1),
    ('ENGCE306', 'Web Programming', 3, 1),
    ('ENGCE309', 'Cloud Computing', 3, 1),
    ('ENGCE310', 'Cloud Application Development', 3, 1),

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

INSERT INTO course_skills(course_id, skill_id, skill_level) VALUE
    (1, 5, 4),
    (2, 6, 4),
    (2, 1, 3),
    (1, 1, 4),
    (3, 3, 4);

CREATE TABLE student_grades (
    user_id INT,
    course_id INT,
    grade_letter VARCHAR(5) NOT NULL,  -- เก็บเกรดตัวอักษร เช่น 'A', 'B+', 'C+'
    grade_point DECIMAL(3,2) NOT NULL, -- เก็บแต้มตัวเลข เช่น 4.00, 3.50, 2.50
    PRIMARY KEY (user_id, course_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

