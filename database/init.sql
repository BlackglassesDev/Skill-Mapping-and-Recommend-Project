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
VALUES ('ENGCC301', 'เขียนแบบวิศวกรรม', 3, 1),
    ('ENGCC304', 'การเขียนโปรแกรมคอมพิวเตอร์', 3, 1),
    ('ENGEE501', 'วงจรไฟฟ้า', 3, 1),
    ('ENGEE502', 'คณิตศาสตร์วิศวกรรมไฟฟ้า', 3, 1),
    ('ENGEE105', 'การฝึกเบื้องต้นทางวิศวกรรม', 1, 1),
    ('ENGEE106', 'เครื่องมือวัดและการวัดทางไฟฟ้า', 3, 1),
    ('ENGEE160', 'อิเล็กทรอนิกส์วิศวกรรม', 3, 1),
    ('ENGEE161', 'วงจรดิจิทัลและการออกแบบลอจิก', 3, 1),
    ('ENGCE120', 'งานฝึกพื้นฐานทางวิศวกรรมคอมพิวเตอร์', 2, 1),
    ('ENGCE121', 'โครงสร้างและสถาปัตยกรรมคอมพิวเตอร์', 3, 1),
    ('ENGCE122', 'ไมโครโพรเซสเซอร์และการอินเตอร์เฟส', 3, 1),
    ('ENGCE123', 'ระบบสมองกลฝังตัวและอินเทอร์เน็ตในทุกสรรพสิ่ง', 3, 1),
    ('ENGCE200', 'การออกแบบระบบดิจิทัล', 3, 1),
    ('ENGCE106', 'การสื่อสารข้อมูลและเครือข่าย', 3, 1),
    ('ENGCE118', 'คณิตศาสตร์ดิสครีตสำหรับวิศวกรรมคอมพิวเตอร์', 3, 1),
    ('ENGCE119', 'ความน่าจะเป็นและสถิติในงานวิศวกรรม', 3, 1),
    ('ENGCE124', 'โครงสร้างข้อมูลและขั้นตอนวิธี', 3, 1),
    ('ENGCE125', 'ระบบปฏิบัติการ', 3, 1),
    ('ENGCE400', 'ปัญญาประดิษฐ์และการเรียนรู้ของเครื่องเบื้องต้น', 3, 1),
    ('ENGCE110', 'ความมั่นคงปลอดภัยของคอมพิวเตอร์และข้อมูล', 3, 1),
    ('ENGCE117', 'การเขียนโปรแกรมสำหรับวิศวกรคอมพิวเตอร์', 3, 1),
    ('ENGCE126', 'ระบบฐานข้อมูล', 3, 1),
    ('ENGCE127', 'การวิเคราะห์และออกแบบระบบ', 3, 1),
    ('ENGCE109', 'เครือข่ายคอมพิวเตอร์', 3, 1),
    ('ENGCE130', 'การติดตั้งและบำรุงรักษาสายสัญญาณเครือข่ายคอมพิวเตอร์', 3, 1),
    ('ENGCE131', 'การสื่อสารเชิงดิจิทัล', 3, 1),
    ('ENGCE133', 'การวัดทดสอบและประเมินประสิทธิภาพของระบบเครือข่าย', 3, 1),
    ('ENGCE134', 'การรักษาความปลอดภัยบนระบบเครือข่าย', 3, 1),
    ('ENGCE135', 'การออกแบบและวางแผนการจัดการระบบเครือข่าย', 3, 1),
    ('ENGCE136', 'การใช้งานเครือข่ายโดยกำหนดจากซอฟต์แวร์', 3, 1),
    ('ENGCE137', 'การดูแลระบบยูนิกซ์', 3, 1),
    ('ENGCE138', 'การสื่อสารข้อมูลมัลติมีเดียบนระบบเครือข่าย', 3, 1),
    ('ENGCE161', 'การประมวลผลสัญญาณดิจิทัล', 3, 1),
    ('ENGCE162', 'สัญาณและระบบ', 3, 1),
    ('ENGCE201', 'การคำนวณสมรรถนะสูงและสถาปัตยกรรมแบบคลาวด์', 3, 1),
    ('ENGCE202', 'การสั่งงานด้วยอุปกรณ์เคลื่อนที่แบบพกพา', 3, 1),
    ('ENGCE203', 'การโปรแกรมแบบขนานสำหรับระบบคลัสเตอร์คอมพิวเตอร์', 3, 1),
    ('ENGCE204', 'วิทยาการหุ่นยนต์ขนาดเล็ก', 3, 1),
    ('ENGCE205', 'ระบบอัตโนมัติเบื้องต้น', 3, 1),
    ('ENGCE206', 'โครงสร้างพื้นฐานแบบกลุ่มเมฆ', 3, 1),
    ('ENGCE207', 'หัวข้อความก้าวล้ำในงานวิศวกรรมคอมพิวเตอร์', 3, 1),
    ('ENGCE156', 'การโต้ตอบระหว่างคอมพิวเตอร์กับมนุษย์', 3, 1),
    ('ENGCE173', 'การวิเคราะห์และออกแบบเชิงวัตถุ', 3, 1),
    ('ENGCE174', 'การเขียนโปรแกรมเชิงวัตถุ', 3, 1),
    ('ENGCE177', 'หัวข้อความก้าวล้ำในงานวิศวกรรมซอฟต์แวร์', 3, 1),
    ('ENGCE186', 'สถาปัตยกรรมซอฟต์แวร์', 3, 1),
    ('ENGCE301', 'การออกแบบและพัฒนาซอฟต์แวร์', 3, 1),
    ('ENGCE302', 'การกำหนดความต้องการและการออกแบบทางซอฟต์แวร์', 3, 1),
    ('ENGCE303', 'การตรวจสอบความสมเหตุสมผลและการทวนสอบซอฟต์แวร์', 3, 1),
    ('ENGCE304', 'กระบวนการซอฟต์แวร์และการประกันคุณภาพ', 3, 1),
    ('ENGCE305', 'การบริหารจัดการโครงการซอฟต์แวร์', 3, 1),
    ('ENGCE306', 'การเขียนโปรแกรมบนเว็บ', 3, 1),
    ('ENGCE307', 'การพัฒนาโปรแกรมประยุกต์สำหรับอุปกรณ์เคลื่อนที่', 3, 1),
    ('ENGCE308', 'การพัฒนาเกมสำหรับอุปกรณ์เคลื่อนที่', 3, 1),
    ('ENGCE309', 'การประมวลผลแบบคลาวด์', 3, 1),
    ('ENGCE310', 'การพัฒนาโปรแกรมบนระบบคลาวด์', 3, 1),
    ('ENGCE311', 'วิทยาการข้อมูลและการวิเคราะห์', 3, 1),
    ('ENGCE312', 'การสร้างและทำการตลาดสินค้าดิจิทัล', 3, 1),
    ('ENGCE313', 'เทคโนโลยีบล็อคเชน', 3, 1),
    ('ENGCE401', 'ฟัซซีเซตเบื้องต้น', 3, 1),
    ('ENGCE402', 'คอมพิวเตอร์กราฟิกส์', 3, 1),
    ('ENGCE403', 'การประมวลผลภาพดิจิทัล และการมองเห็นโดยคอมพิวเตอร์', 3, 1),
    ('ENGCE404', 'การทำเหมืองข้อมูลขนาดใหญ่', 3, 1),
    ('ENGCE405', 'การเรียนรู้เชิงลึกเบื้องต้น', 3, 1),
    ('ENGCE406', 'การประมวลภาษาธรรมชาติเบื้องต้น', 3, 1),
    ('ENGCE407', 'หัวข้อความก้าวล้ำในงานวิศวกรรมปัญญาประดิษฐ์', 3, 1),
    ('ENGCE408', 'ความรู้เบื้องต้นในการรู้จำรูปแบบ', 3, 1),
    ('ENGCE409', 'โครงข่ายประสาทเทียม', 3, 1),
    ('ENGCE410', 'อัลกอริทึมเชิงวิวัฒนาการ', 3, 1),
    ('ENGCE411', 'เทคโนโลยีความจริงเสมือน', 3, 1),

    ('GEN101', 'test for Communication', 3, 2);

CREATE TABLE job (
    job_id INT AUTO_INCREMENT,
    name_job VARCHAR(255) NOT NULL,
    curriculum_id INT,
    PRIMARY KEY (job_id),
    FOREIGN KEY (curriculum_id) REFERENCES curriculum(curriculum_id)
)ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT INTO job (name_job, curriculum_id) VALUE
    ('วิศวกรคอมพิวเตอร์', 1),
    ('นักวิชาการคอมพิวเตอร์', 1),
    ('นักวิเคราะห์ระบบคอมพิวเตอร์', 1),
    ('นักพัฒนาซอฟต์แวร์', 1),
    ('โปรแกรมเมอร์', 1),
    ('ผู้ดูแลระบบเครือข่าย', 1),
    ('ผู้จัดการโครงการคอมพิวเตอร์', 1),
    ('นักพัฒนาเว็บไซต์และสื่อผสม', 1),
    ('วิศกรเครือข่าย', 1),
    ('วิศวกรปัญญาประดิษฐ์', 1);

-- ตารางเก็บชื่อทักษะหลัก (Master Data)
CREATE TABLE skills (
    skill_id INT AUTO_INCREMENT PRIMARY KEY,
    skill_name VARCHAR(255) NOT NULL UNIQUE, -- ใส่ UNIQUE กันชื่อซ้ำ
    curriculum_id INT,
    FOREIGN KEY (curriculum_id) REFERENCES curriculum(curriculum_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT INTO skills (skill_name, curriculum_id) VALUE
-- ชื่อสกิล    ไอดีหลักสูตร
    ('Frontend', 1),
    ('Node Backend', 1),
    ('Python Backend', 1),
    ('Java Backend', 1),
    ('.NET Backend', 1),
    ('PHP Backend', 1),
    ('Systems (C/C++)', 1),
    ('Mobile', 1),
    ('Scripting', 1),
    ('Functional', 1),
    ('Game/Graphics', 1),
    ('Desktop', 1),
    ('Machine Learning', 1),
    ('Data Engineering', 1),
    ('SQL DB', 1),
    ('NoSQL DB', 1),
    ('Cloud', 1),
    ('DevOps', 1),
    ('Build Tools', 1),
    ('Messaging', 1),
    ('GPU/Compute', 1),
    ('Embedded/IoT', 1);

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

