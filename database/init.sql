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
    skill_code VARCHAR(20) NOT NULL,
    skill_name VARCHAR(255) NOT NULL, -- ใส่ UNIQUE กันชื่อซ้ำ
    standard_skills TEXT,
    description TEXT,  -- เพิ่มคำอธิบายทักษะ
    curriculum_id INT,
    FOREIGN KEY (curriculum_id) REFERENCES curriculum(curriculum_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT INTO skills (skill_code,skill_name,standard_skills,description, curriculum_id) VALUE
-- รหัสสกิล      ชื่อสกิล    คำศัพท์จากรุ่นพี่    ไอดีหลักสูตร
    ('ASMG','Asset management','Capacity Planning, Performance, Scalability','การบริหารจัดการทรัพย์สินต่างๆ ตลอดอายุการใช้งาน ตั้งแต่เริ่มจัดหา นำมาใช้งาน บำรุงรักษา ไปจนถึงการปลดระวาง',1),
    ('BENM','Benefits management','Process Automation, User Experience','การคาดการณ์ วางแผน และติดตามเพื่อให้มั่นใจว่าโปรเจกต์หรือแผนงานต่างๆ จะสร้างผลประโยชน์ได้จริงตามที่ตั้งเป้าไว้',1),
    ('BSMO','Business modelling','','การสร้างโมเดลหรือภาพจำลองของสถานการณ์ทางธุรกิจ เพื่อให้เห็นภาพรวมของกระบวนการ ข้อมูล และบทบาทต่างๆ ซึ่งจะช่วยเสริมการวิเคราะห์และตัดสินใจ',1),
    ('BUSA','Business situation analysis','Agile, Analytical, Application Debugging, Application Resiliency, Capacity Planning, Communication Skills, Cross Browser, Database Performance Tuning, Database Recovery Plan, Decision Making, Interpersonal Skills, Methodologies, Performance, Predictive Modelling, Predictive Software Development, Problem Solving, Process Automation, Relational Database Design, Relational Oltp Queries, Replication, Scalability, Scrum, System Troubleshooting, Team Player, Time Management Skills, User Experience','การวิเคราะห์เจาะลึกสถานการณ์ทางธุรกิจ เพื่อหาจุดที่ควรปรับปรุงและเสนอแนวทางแก้ไข',1),
    ('CHMG','Change control','CI/CD, Cfengine, Chef, Cobbler, Deployment Validation, DevOps, Docker, Eks, Foreman, Gerrit, Git, Gitlab Ci, Gke, Infrastructure As Code, Jenkins, Kubernetes, Mercurial, Openshift, Puppet, Svn, Version Control','การประเมินความเสี่ยงและควบคุมการเปลี่ยนแปลงต่างๆ ในระบบหรือผลิตภัณฑ์ เพื่อให้มั่นใจว่าการทำงานร่วมกันเป็นไปอย่างเป็นระเบียบ',1),
    ('CFMG','Configuration management','CI/CD, Cfengine, Chef, Cobbler, Deployment Validation, DevOps, Docker, Eks, Foreman, Gerrit, Git, Gitlab Ci, Gke, Infrastructure As Code, Jenkins, Kubernetes, Mercurial, Openshift, Puppet, Svn, Version Control','การวางแผน ระบุ ควบคุม และตรวจสอบการตั้งค่าของระบบ รวมถึงจัดการความสัมพันธ์ระหว่างส่วนประกอบต่างๆ',1),
    ('COPL','Continuity management','Datadog, Grafana, Prometheus','การพัฒนา นำไปใช้งาน และทดสอบกรอบความต่อเนื่องทางธุรกิจ เพื่อให้ระบบยังสามารถทำงานต่อไปได้แม้อยู่ในสถานการณ์ฉุกเฉิน',1),
    ('DENG','Data engineering','Athena, Big Data, Bigquery, Data Mining, Database, Dynamodb, Elasticsearch, Glue, Lake Formation, Mongodb, Mssql, Mysql, Nosql, Oracle, Postgresql, Rds, Redis, Redshift, Spark, Sql','การออกแบบ สร้าง ดูแล และรักษาความปลอดภัยของระบบท่อส่งข้อมูล และคลังข้อมูล เพื่อให้ประมวลผลข้อมูลได้แบบเรียลไทม์ เสถียร และรองรับการขยายตัว',1),
    ('DEMG','Delivery management','Agile, Analytical, Application Debugging, Application Resiliency, Capacity Planning, Communication Skills, Cross Browser, Database Performance Tuning, Database Recovery Plan, Decision Making, Interpersonal Skills, Methodologies, Performance, Predictive Modelling, Predictive Software Development, Problem Solving, Process Automation, Relational Database Design, Relational Oltp Queries, Replication, Scalability, Scrum, System Troubleshooting, Team Player, Time Management Skills, User Experience','การเป็นผู้นำและทำงานร่วมกันเพื่อส่งมอบผลิตภัณฑ์หรือบริการใหม่ๆ ให้สำเร็จตามรอบเวลาที่กำหนดไว้',1),
    ('DEPL','Deployment','CI/CD, Cfengine, Chef, Cobbler, Deployment Validation, DevOps, Docker, Eks, Foreman, Gerrit, Git, Gitlab Ci, Gke, Infrastructure As Code, Jenkins, Kubernetes, Mercurial, Openshift, Puppet, Svn, Version Control','การนำซอฟต์แวร์ที่พัฒนาเสร็จแล้วไปติดตั้งเพื่อเปิดใช้งานจริง โดยต้องจัดการความเสี่ยงเพื่อให้ระบบทำงานได้ตามที่ออกแบบไว้',1),
    ('EMRG','Emerging technology monitoring','Cloud Computing',' การค้นหา ติดตาม และประเมินเทคโนโลยี ผลิตภัณฑ์ หรือวิธีการทำงานใหม่ๆ ที่กำลังมาแรง',1),
    ('DCMA','Facilities management','Capacity Planning, Performance, Scalability','การวางแผน ออกแบบ และบริหารจัดการพื้นที่ อาคาร และสิ่งอำนวยความสะดวกต่างๆ ที่รวมกันเป็นโครงสร้างพื้นฐานทางไอทีขององค์กร',1),
    ('FEAS','Feasibility assessment','','การกำหนดและประเมินความเป็นไปได้ของการเปลี่ยนแปลงทางธุรกิจ ทั้งในแง่การเงิน เทคนิค และความสอดคล้องกับเป้าหมายเชิงกลยุทธ์',1),
    ('RSCH','Formal research','Classic Image Processing Techniques, Computer Vision, Distributed Systems, Faster Rcnn, Grid Computing, Image Processing, Instance Segmentation, Mask Rcnn, Matlab, Mobile Net, Object Detection, Opencv, R, Semantic Segmentation, Single Shot Multibox Detector Ssd','การสร้างองค์ความรู้ใหม่ๆ อย่างเป็นระบบ ผ่านการเก็บข้อมูล สร้างนวัตกรรม ทดลอง และประเมินผล',1),
    ('TEST','Functional testing','Automated Testing, Automated Unit Testing, Chrome Inspector, Exploratory Testing, Firebug, Jasmine, Manual Testing, Progression/Regression Testing, Protractor, Pyunit, Testing, Unit Testing','การตรวจสอบและทดสอบระบบ ผลิตภัณฑ์ หรือบริการ ว่าสามารถทำงานได้จริงตามฟังก์ชันที่ระบุไว้หรือไม่',1),
    ('HPCC','High-performance computing','Classic Image Processing Techniques, Computer Vision, Distributed Systems, Faster Rcnn, Grid Computing, Image Processing, Instance Segmentation, Mask Rcnn, Matlab, Mobile Net, Object Detection, Opencv, R, Semantic Segmentation, Single Shot Multibox Detector Ssd','การใช้ระบบคอมพิวเตอร์ขั้นสูงและเทคนิคการเขียนโปรแกรมแบบพิเศษ เพื่อนำมาแก้ปัญหาที่ต้องคำนวณซับซ้อนมากๆ',1),
    ('IFDN','Infrastructure design','AWS EC2, Apache, Cloud Computing, Cloud Environments, Cloud Infrastructure, Cloudify, Containers, Iaas, Linux, Microsoft Iis, Mule, Openam, Paas, Tomcat, Urban Code, Vms, Windows Os','การออกแบบโครงสร้างพื้นฐานด้านเทคโนโลยีให้ตอบโจทย์ธุรกิจ โดยต้องรับประกันความสามารถในการขยายระบบ ความเสถียร ความปลอดภัย และตรงตามเป้าหมายขององค์กร',1),
    ('ITOP','Infrastructure operations','AWS EC2, Apache, Cloud Computing, Cloud Environments, Cloud Infrastructure, Cloudify, Containers, Iaas, Linux, Microsoft Iis, Mule, Openam, Paas, Tomcat, Urban Code, Vms, Windows Os','การจัดหา ติดตั้ง ตั้งค่า และดูแลระบบโครงสร้างพื้นฐานไอทีให้ทำงานอย่างเต็มประสิทธิภาพ ทั้งในรูปแบบเซิร์ฟเวอร์จริง ระบบจำลอง หรือบนคลาวด์',1),
    ('MLNG','Machine learning','Amazon Sagemaker, Artificial Neural Network Ann, Convolutional Neural Networks, Deep Learning, Keras, Machine Learning, Numpy, Pytorch, Scikit Learn, Tensorflow','การพัฒนาระบบที่สามารถเรียนรู้ได้จากข้อมูลและประสบการณ์ เพื่อเพิ่มความแม่นยำและปรับตัวเข้ากับสภาพแวดล้อมที่เปลี่ยนแปลงไปได้',1),
    ('NTDS','Network design','Concurrency, Dns, F5 Load Balancers, HTTP API, Http, Networking, Ntp, Tcp/Ip, Threading','การออกแบบระบบเครือข่ายสื่อสารให้ตอบโจทย์ธุรกิจ รองรับการขยายตัว เสถียร ปลอดภัย และตรงตามกลยุทธ์',1),
    ('NTAS','Network support','Concurrency, Dns, F5 Load Balancers, HTTP API, Http, Networking, Ntp, Tcp/Ip, Threading','การให้บริการบำรุงรักษาและสนับสนุนการทำงานของระบบเครือข่ายการสื่อสาร',1),
    ('NFTS','Non-functional testing','Automated Testing, Automated Unit Testing, Chrome Inspector, Exploratory Testing, Firebug, Jasmine, Manual Testing, Progression/Regression Testing, Protractor, Pyunit, Testing, Unit Testing','การทดสอบระบบในแง่มุมอื่นๆ ที่ไม่ใช่แค่ฟังก์ชันการทำงาน เช่น ทดสอบความเร็ว ความปลอดภัย หรือการขยายตัวของระบบ',1),
    ('NUAN','Numerical analysis','Classic Image Processing Techniques, Computer Vision, Distributed Systems, Faster Rcnn, Grid Computing, Image Processing, Instance Segmentation, Mask Rcnn, Matlab, Mobile Net, Object Detection, Opencv, R, Semantic Segmentation, Single Shot Multibox Detector Ssd','การสร้าง วิเคราะห์ และทดสอบอัลกอริทึม เพื่อนำมาใช้แก้ปัญหาทางคณิตศาสตร์ด้วยการคำนวณตัวเลข',1),
    ('POMG','Portfolio management','Process Automation, User Experience','การสร้างและใช้กรอบการบริหารจัดการ เพื่อกำหนดและส่งมอบกลุ่มของโปรเจกต์หรือบริการให้เป็นไปในทิศทางเดียวกัน',1),
    ('PROF','Portfolio, programme and project support','Process Automation, User Experience','การให้คำแนะนำและสนับสนุนด้านกระบวนการ ขั้นตอน เครื่องมือ และเทคนิคสำหรับบริหารกลุ่มโปรเจกต์',1),
    ('PGMG','Programme management','Process Automation, User Experience','การหาความต้องการ วางแผน และประสานงานกลุ่มโปรเจกต์ที่เกี่ยวข้องกัน เพื่อให้บรรลุเป้าหมายเชิงกลยุทธ์ทางธุรกิจ',1),
    ('PROG','Programming/software development','Angular, Bash, Bootstrap, C#, C++, C/C++, CSS, Cocoa Touch, Django, Flask, Flutter, Go, Groovy, HTML, Java, JavaScript, Jquery, Less, Node.js, Objective C, Perl, Php, Postcss, Python, React, React / Angular, Ruby, Sass, Scala, Vue.js, Wordpress, Xml/Xslt, Zend','การพัฒนาส่วนประกอบของซอฟต์แวร์เพื่อสร้างประโยชน์และมูลค่าให้กับผู้ใช้งานหรือผู้มีส่วนได้ส่วนเสีย',1),
    ('PRMG','Project management','Agile, Analytical, Application Debugging, Application Resiliency, Capacity Planning, Communication Skills, Cross Browser, Database Performance Tuning, Database Recovery Plan, Decision Making, Interpersonal Skills, Methodologies, Performance, Predictive Modelling, Predictive Software Development, Problem Solving, Process Automation, Relational Database Design, Relational Oltp Queries, Replication, Scalability, Scrum, System Troubleshooting, Team Player, Time Management Skills, User Experience','การส่งมอบผลลัพธ์ของโปรเจกต์ให้สำเร็จ โดยใช้เทคนิคการบริหาร ความเป็นผู้นำ และการจัดการให้เหมาะสมกับบริบทขององค์กร',1),
    ('RESD','Real-time/embedded systems development','API, API Development, Adaptive Design, Algorithms, Design Patterns, Edge, Graphql, Mvc, Object Oriented Programming, REST API, Responsive Design, Responsive Ui, Rpc, Single Page Application Spa','การออกแบบและพัฒนาซอฟต์แวร์ที่ต้องประมวลผลแบบเรียลไทม์และมีความเสถียรสูง ซึ่งมักฝังอยู่ในตัวอุปกรณ์ (Embedded systems)',1),
    ('RELM','Release management','Process Automation, User Experience','การบริหารจัดการการปล่อยบริการใหม่หรืออัปเดตขึ้นสู่ระบบจริง ให้สอดคล้องกับเป้าหมายธุรกิจและได้มาตรฐาน',1),
    ('REQM','Requirements definition and management','Agile, Analytical, Application Debugging, Application Resiliency, Capacity Planning, Communication Skills, Cross Browser, Database Performance Tuning, Database Recovery Plan, Decision Making, Interpersonal Skills, Methodologies, Performance, Predictive Modelling, Predictive Software Development, Problem Solving, Process Automation, Relational Database Design, Relational Oltp Queries, Replication, Scalability, Scrum, System Troubleshooting, Team Player, Time Management Skills, User Experience','การจัดการความต้องการของระบบให้ครอบคลุมตลอดทั้งวงจรการส่งมอบและการใช้งานจริง',1),
    ('SFEN','Safety engineering','Process Automation, User Experience','การใช้วิธีการที่เหมาะสมเพื่อรับประกันความปลอดภัยของระบบในทุกขั้นตอนของการพัฒนา',1),
    ('SCMO','Scientific modelling','Classic Image Processing Techniques, Computer Vision, Distributed Systems, Faster Rcnn, Grid Computing, Image Processing, Instance Segmentation, Mask Rcnn, Matlab, Mobile Net, Object Detection, Opencv, R, Semantic Segmentation, Single Shot Multibox Detector Ssd','การใช้คอมพิวเตอร์จำลองสถานการณ์หรือการคำนวณ เพื่อใช้แก้ปัญหาโลกจริงในแวดวงวิทยาศาสตร์',1),
    ('SLMO','Service level management','Datadog, Grafana, Prometheus','การตกลงเป้าหมาย ประเมิน ติดตาม และบริหารจัดการเพื่อให้การให้บริการเป็นไปตามมาตรฐาน (SLA) ที่ตกลงกันไว้',1),
    ('SWDN','Software design','API, API Development, Adaptive Design, Algorithms, Design Patterns, Edge, Graphql, Mvc, Object Oriented Programming, REST API, Responsive Design, Responsive Ui, Rpc, Single Page Application Spa','การออกแบบสถาปัตยกรรมซอฟต์แวร์ให้ตรงตามความต้องการ และยึดตามหลักการหรือมาตรฐานที่ตั้งไว้',1),
    ('TECH','Specialist advice','Communication Skills, Interpersonal Skills','การให้คำปรึกษา คำแนะนำ และทิศทางอย่างมืออาชีพในสาขาที่มีความเชี่ยวชาญเฉพาะทาง',1),
    ('RLMT','Stakeholder relationship management','Communication Skills, Interpersonal Skills','การวิเคราะห์และบริหารความสัมพันธ์กับผู้ที่มีส่วนได้ส่วนเสียอย่างเป็นระบบและมีโครงสร้างชัดเจน เพื่อให้เกิดประโยชน์ร่วมกันทั้งสองฝ่าย',1),
    ('STMG','Storage management','Capacity Planning, Performance, Scalability','การเตรียมการ ตั้งค่า และปรับแต่งระบบจัดเก็บข้อมูล ทั้งแบบใช้งานในออฟฟิศและบนคลาวด์ เพื่อให้ข้อมูลปลอดภัยและสอดคล้องกับธุรกิจ',1),
    ('SUPP','Supplier management','Communication Skills, Interpersonal Skills','การบริหารจัดการและควบคุมผลงานของคู่ค้า ให้สอดคล้องกับกลยุทธ์ โดยต้องรักษาสมดุลระหว่างต้นทุน ประสิทธิภาพ และคุณภาพของบริการ',1),
    ('SYSP','System software administration','AWS EC2, Apache, Cloud Computing, Cloud Environments, Cloud Infrastructure, Cloudify, Containers, Iaas, Linux, Microsoft Iis, Mule, Openam, Paas, Tomcat, Urban Code, Vms, Windows Os','การติดตั้ง จัดการ และบำรุงรักษาระบบปฏิบัติการ (OS) ซอฟต์แวร์จัดการข้อมูล และโปรแกรมเสริมต่างๆ ในระบบโครงสร้างพื้นฐาน',1),
    ('DESN','Systems design','API, API Development, Adaptive Design, Algorithms, Design Patterns, Edge, Graphql, Mvc, Object Oriented Programming, REST API, Responsive Design, Responsive Ui, Rpc, Single Page Application Spa','การออกแบบระบบให้ตรงกับความต้องการและสถาปัตยกรรมระบบที่ได้ตกลงกันไว้',1),
    ('HSIN','Systems installation and removal','AWS, Azure, Azure Functions, Gcp, Kafka, Kineses','การติดตั้งและทดสอบการทำงาน หรือการปลดระวางและถอดถอนส่วนประกอบต่างๆ ของระบบ',1),
    ('SINT','Systems integration and build','AWS, Azure, Azure Functions, Gcp, Kafka, Kineses','การวางแผนและควบคุมกิจกรรมในการนำระบบย่อยหรือส่วนประกอบต่างๆ มาเชื่อมต่อและประกอบเข้าด้วยกัน เพื่อสร้างเป็นระบบหรือผลิตภัณฑ์ที่พร้อมใช้งาน',1);

CREATE TABLE job_skills (
    job_id INT,
    skill_id INT,
    level_skill INT, -- เก็บ Level ที่ต้องการสำหรับอาชีพนี้
    PRIMARY KEY (job_id, skill_id), -- ป้องกันการใส่สกิลเดิมซ้ำในอาชีพเดียวกัน
    FOREIGN KEY (job_id) REFERENCES job(job_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT INTO job_skills (job_id, skill_id, level_skill) VALUE
    (1, 17, 2),(1, 18, 1),(1, 40, 2),(1, 43, 2),(1, 20, 2),(1, 21, 1),(1, 6, 2),(1, 41, 2),(1, 15, 1),
    (2, 33, 4),(2, 23, 4),(2, 16, 4),(2, 14, 2),
    (3, 4, 2),(3, 3, 2),(3, 13, 2),(3, 31, 2),(3, 37, 4),
    (4, 27, 2),(4, 35, 2),(4, 43, 2),(4, 15, 1),(4, 29, 2),(4, 6, 2),(4, 31, 2),(4, 32, 2),
    (5, 27, 2),(5, 35, 2),(5, 43, 2),(5, 15, 1),(5, 29, 2),(5, 6, 2),(5, 31, 2),(5, 32, 2),
    (6, 18, 1),(6, 6, 2),(6, 7, 2),(6, 5, 2),(6, 1, 2),(6, 34, 2),(6, 12, 2),(6, 39, 2),
    (7, 28, 4),(7, 26, 6),(7, 9, 3),(7, 24, 5),(7, 37, 4),(7, 2, 3),
    (8, 27, 2),(8, 15, 1),(8, 31, 2),(8, 30, 2),(8, 10, 2),
    (9, 20, 2),(9, 17, 2),(9, 41, 2),(9, 11, 4),(9, 36, 4),
    (10, 19, 2),(10, 8, 2),(10, 27, 2);

-- ตารางเชื่อมโยง รายวิชา - ทักษะ
CREATE TABLE course_skills (
    course_id INT,
    skill_id INT,
    skill_level INT, -- ระดับทักษะที่วิชานี้สอน (เช่น 1-5)
    PRIMARY KEY (course_id, skill_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- แมปรายวิชา -> ทักษะ (อ้างอิง CLO จากเล่มหลักสูตร วศ.บ.วิศวกรรมคอมพิวเตอร์ ฉบับปรับปรุง พ.ศ. 2570)
-- เชื่อมโยงด้วย "รหัสรายวิชาเดิม" ของรายวิชาในระบบกับรายวิชาในเล่มหลักสูตร
-- วิชาที่ถูกตัด/รวมในหลักสูตร 2570 (ไม่มี CLO ของตัวเอง): แมปจาก CLO วิชาใหม่ที่สืบทอดเนื้อหา และชื่อ/เนื้อหารายวิชา
-- ครบทั้ง 2 ทิศทาง: ทุกวิชามีสกิล และทุกสกิลมีอย่างน้อย 1 วิชาที่สอน
-- skill_level: 1=รู้จักเบื้องต้น 2=เข้าใจ/อธิบายได้ 3=ใช้งาน/ปฏิบัติได้ 4=วิเคราะห์ ออกแบบ พัฒนา ประเมินได้
INSERT INTO course_skills (course_id, skill_id, skill_level) VALUE
    -- ENGCC301 เขียนแบบวิศวกรรม (รหัสใหม่ BECC0011)
    (1, 41, 2), -- DESN: CLO4-5 ออกแบบ/เขียนแบบตามมาตรฐานด้วย CAD
    -- ENGCC304 การเขียนโปรแกรมคอมพิวเตอร์ (รหัสใหม่ BECC0013)
    (2, 27, 2), -- PROG: CLO2 เขียนโปรแกรมโครงสร้างพื้นฐาน
    (2, 35, 1), -- SWDN: CLO3 สร้างอัลกอริทึม/ผังงาน
    -- ENGEE501 วงจรไฟฟ้า (ไม่มี CLO ในหลักสูตร 2570)
    (3, 41, 2), -- DESN: CLO ของ BECP0101: วิเคราะห์และออกแบบวงจรไฟฟ้าเบื้องต้น
    (3, 42, 1), -- HSIN: CLO ของ BECP0101: ใช้เครื่องมือวัดตรวจสอบวงจร
    -- ENGEE502 คณิตศาสตร์วิศวกรรมไฟฟ้า (รหัสใหม่ BECP0002)
    (4, 23, 3), -- NUAN: CLO1-2 คำนวณเมทริกซ์/การแปลง
    (4, 33, 2), -- SCMO: ใช้เครื่องมือคอมพิวเตอร์จำลองแนวคิด
    -- ENGEE105 การฝึกเบื้องต้นทางวิศวกรรม (ไม่มี CLO ในหลักสูตร 2570)
    (5, 42, 2), -- HSIN: ฝึกปฏิบัติงานเครื่องมือช่าง/ประกอบชิ้นงาน (คล้าย BECP0001)
    (5, 18, 1), -- ITOP: ใช้คอมพิวเตอร์จัดทำเอกสารและนำเสนองาน
    -- ENGEE106 เครื่องมือวัดและการวัดทางไฟฟ้า (ไม่มี CLO ในหลักสูตร 2570)
    (6, 42, 2), -- HSIN: CLO ของ BECP0101: ใช้เครื่องมือวัดทดสอบวงจร
    (6, 15, 1), -- TEST: การวัดและประเมินผลการทดสอบระบบ
    -- ENGEE160 อิเล็กทรอนิกส์วิศวกรรม (ไม่มี CLO ในหลักสูตร 2570)
    (7, 41, 2), -- DESN: CLO ของ BECP0101: วิเคราะห์และออกแบบวงจรอิเล็กทรอนิกส์
    (7, 42, 2), -- HSIN: อ่านและประกอบวงจรอิเล็กทรอนิกส์
    -- ENGEE161 วงจรดิจิทัลและการออกแบบลอจิก (รหัสใหม่ BECP0102)
    (8, 41, 3), -- DESN: CLO2 ออกแบบวงจรคอมบิเนชัน/ซีเควนเชียล
    (8, 42, 2), -- HSIN: CLO3 ประกอบและทดสอบวงจร
    -- ENGCE120 งานฝึกพื้นฐานทางวิศวกรรมคอมพิวเตอร์ (รหัสใหม่ BECP0001)
    (9, 42, 2), -- HSIN: CLO1 อ่าน/ประกอบวงจรอิเล็กทรอนิกส์
    (9, 18, 1), -- ITOP: CLO3 ใช้คอมพิวเตอร์ทำงานเอกสาร/นำเสนอ
    -- ENGCE121 โครงสร้างและสถาปัตยกรรมคอมพิวเตอร์ (รหัสใหม่ BECP0103)
    (10, 17, 2), -- IFDN: CLO1-2 โครงสร้าง/สถาปัตยกรรมคอมพิวเตอร์
    (10, 1, 2), -- ASMG: CLO3 ประเมินประสิทธิภาพระบบ
    -- ENGCE122 ไมโครโพรเซสเซอร์และการอินเตอร์เฟส (รหัสใหม่ BECP0104)
    (11, 29, 3), -- RESD: CLO1 เขียนโปรแกรมควบคุมด้วยไมโครคอนโทรลเลอร์
    (11, 27, 2), -- PROG: โปรแกรมคอมพิวเตอร์ฝังตัว
    (11, 42, 2), -- HSIN: CLO3 เชื่อมต่ออุปกรณ์ I/O ในระบบจริง
    -- ENGCE123 ระบบสมองกลฝังตัวและอินเทอร์เน็ตในทุกสรรพสิ่ง (รหัสใหม่ BECP0105)
    (12, 29, 4), -- RESD: CLO1 ออกแบบพัฒนาระบบฝังตัว IoT
    (12, 21, 2), -- NTAS: CLO2 สื่อสารไร้สาย/เชื่อมต่อคลาวด์
    (12, 43, 3), -- SINT: CLO3 เชื่อมต่ออุปกรณ์ด้วยโปรโตคอลมาตรฐาน
    -- ENGCE200 การออกแบบระบบดิจิทัล (รหัสใหม่ BECP0106)
    (13, 41, 3), -- DESN: CLO2-3 ออกแบบวงจรดิจิทัลอย่างเป็นระบบ
    (13, 29, 2), -- RESD: หน่วยความจำ/วงจรควบคุมสำหรับระบบดิจิทัล
    -- ENGCE106 การสื่อสารข้อมูลและเครือข่าย (รหัสใหม่ BECP0201)
    (14, 20, 2), -- NTDS: CLO1-2 หลักการเครือข่าย/TCP-IP/Subnet
    (14, 21, 3), -- NTAS: CLO3 ติดตั้งตั้งค่าเราเตอร์/สวิตช์
    -- ENGCE118 คณิตศาสตร์ดิสครีตสำหรับวิศวกรรมคอมพิวเตอร์ (รหัสใหม่ BECP0003)
    (15, 23, 2), -- NUAN: CLO1-2 ตรรกศาสตร์/การนับ/ความน่าจะเป็น
    (15, 33, 2), -- SCMO: CLO3 กราฟ/อัลกอริทึม จำลองด้วยซอฟต์แวร์
    -- ENGCE119 ความน่าจะเป็นและสถิติในงานวิศวกรรม (รหัสใหม่ BECP0004)
    (16, 23, 2), -- NUAN: CLO1 ทฤษฎีความน่าจะเป็น/สถิติ
    (16, 8, 2), -- DENG: CLO2-3 วิเคราะห์ข้อมูล/จำลองข้อมูลด้วยเครื่องมือคอมพิวเตอร์
    -- ENGCE124 โครงสร้างข้อมูลและขั้นตอนวิธี (รหัสใหม่ BECP0302)
    (17, 27, 3), -- PROG: CLO1 ใช้โครงสร้างข้อมูลในการเขียนโปรแกรม
    (17, 35, 2), -- SWDN: CLO2-3 เปรียบเทียบ/ประเมินขั้นตอนวิธี
    -- ENGCE125 ระบบปฏิบัติการ (รหัสใหม่ BECP0303)
    (18, 40, 3), -- SYSP: CLO1-3 โครงสร้าง OS/การจัดการทรัพยากร/คำสั่ง Unix-Linux
    -- ENGCE400 ปัญญาประดิษฐ์และการเรียนรู้ของเครื่องเบื้องต้น (รหัสใหม่ BECP0401)
    (19, 19, 3), -- MLNG: CLO2-3 สร้าง/ประเมินโมเดลจำแนก-พยากรณ์
    (19, 27, 2), -- PROG: พัฒนาโปรแกรมปัญญาประดิษฐ์
    -- ENGCE110 ความมั่นคงปลอดภัยของคอมพิวเตอร์และข้อมูล (รหัสใหม่ BECP0203)
    (20, 32, 2), -- SFEN: CLO2-3 ระบุภัยคุกคาม/ป้องกันระบบ
    (20, 40, 2), -- SYSP: ควบคุมการเข้าถึง/พิสูจน์ตัวตนระบบงานจริง
    -- ENGCE117 การเขียนโปรแกรมสำหรับวิศวกรคอมพิวเตอร์ (ไม่มี CLO ในหลักสูตร 2570)
    (21, 27, 3), -- PROG: เขียนโปรแกรมประยุกต์สำหรับงานวิศวกรรม
    (21, 35, 2), -- SWDN: ออกแบบโครงสร้างโปรแกรมแก้ปัญหา
    -- ENGCE126 ระบบฐานข้อมูล (รหัสใหม่ BECP0304)
    (22, 8, 3), -- DENG: CLO1-3 ออกแบบฐานข้อมูล/SQL/ประยุกต์ใช้
    -- ENGCE127 การวิเคราะห์และออกแบบระบบ (รหัสใหม่ BECP0305)
    (23, 31, 3), -- REQM: CLO1 วิเคราะห์ความต้องการระบบ
    (23, 41, 3), -- DESN: CLO2-3 สร้างแบบจำลอง UML/DFD
    (23, 3, 2), -- BSMO: แบบจำลองกระบวนการทำงานของระบบ
    (23, 37, 2), -- RLMT: CLO1 การเก็บความต้องการและประสานงานกับผู้มีส่วนได้ส่วนเสียของระบบ
    -- ENGCE109 เครือข่ายคอมพิวเตอร์ (รหัสใหม่ BECP0202)
    (24, 20, 3), -- NTDS: CLO1 วิเคราะห์ออกแบบเครือข่ายระดับองค์กร
    (24, 21, 3), -- NTAS: CLO2 ติดตั้งบริการเซิร์ฟเวอร์ DNS/Mail/Web
    (24, 7, 2), -- COPL: CLO3 วางแผนสำรองระบบ/ความทนทานต่อความผิดพลาด
    -- ENGCE130 การติดตั้งและบำรุงรักษาสายสัญญาณเครือข่ายคอมพิวเตอร์ (รหัสใหม่ BECP0209)
    (25, 21, 3), -- NTAS: CLO3 วินิจฉัยแก้ไขระบบสายสัญญาณ
    (25, 42, 3), -- HSIN: CLO2 ติดตั้งหัวต่อและทดสอบการเชื่อมต่อ
    (25, 12, 2), -- DCMA: CLO1 โครงสร้างระบบสายสัญญาณ/ตู้แร็ค
    -- ENGCE131 การสื่อสารเชิงดิจิทัล (รหัสใหม่ BECP0208)
    (26, 20, 2), -- NTDS: CLO1-2 หลักการสื่อสารดิจิทัล/ประสิทธิภาพระบบ
    (26, 33, 2), -- SCMO: CLO3 จำลอง/ออกแบบระบบสื่อสาร
    -- ENGCE133 การวัดทดสอบและประเมินประสิทธิภาพของระบบเครือข่าย (ไม่มี CLO ในหลักสูตร 2570)
    (27, 21, 3), -- NTAS: วัดทดสอบและวินิจฉัยระบบเครือข่าย
    (27, 22, 2), -- NFTS: ประเมินประสิทธิภาพระบบเครือข่าย
    (27, 1, 2), -- ASMG: วิเคราะห์ performance/capacity ของระบบ
    -- ENGCE134 การรักษาความปลอดภัยบนระบบเครือข่าย (รหัสใหม่ BECP0207)
    (28, 20, 3), -- NTDS: CLO1 วิเคราะห์นโยบายความปลอดภัยเครือข่าย
    (28, 21, 3), -- NTAS: CLO2 ติดตั้งระบบควบคุมการเข้าถึง
    (28, 32, 2), -- SFEN: CLO3 ใช้งาน Firewall/IDS-IPS/VPN
    -- ENGCE135 การออกแบบและวางแผนการจัดการระบบเครือข่าย (ไม่มี CLO ในหลักสูตร 2570)
    (29, 20, 3), -- NTDS: ออกแบบและวางแผนการจัดการระบบเครือข่าย
    (29, 34, 2), -- SLMO: การจัดการบริการตามมาตรฐานของระบบเครือข่าย
    -- ENGCE136 การใช้งานเครือข่ายโดยกำหนดจากซอฟต์แวร์ (ไม่มี CLO ในหลักสูตร 2570)
    (30, 20, 3), -- NTDS: ออกแบบเครือข่ายโดยกำหนดจากซอฟต์แวร์ (SDN)
    (30, 27, 2), -- PROG: เขียนโปรแกรมควบคุมการทำงานของเครือข่าย
    (30, 11, 2), -- EMRG: เทคโนโลยีเครือข่ายยุคใหม่ SDN
    -- ENGCE137 การดูแลระบบยูนิกซ์ (ไม่มี CLO ในหลักสูตร 2570)
    (31, 40, 3), -- SYSP: ดูแลและบริหารจัดการระบบยูนิกซ์ (ต่อเนื่องจาก BECP0210 ลินุกซ์)
    (31, 18, 2), -- ITOP: ติดตั้ง/ตั้งค่าบริการบนระบบยูนิกซ์
    -- ENGCE138 การสื่อสารข้อมูลมัลติมีเดียบนระบบเครือข่าย (ไม่มี CLO ในหลักสูตร 2570)
    (32, 20, 2), -- NTDS: หลักการสื่อสารข้อมูลมัลติมีเดียบนเครือข่าย
    (32, 21, 2), -- NTAS: ส่งผ่านข้อมูลมัลติมีเดียบนระบบเครือข่าย
    -- ENGCE161 การประมวลผลสัญญาณดิจิทัล (ไม่มี CLO ในหลักสูตร 2570)
    (33, 33, 3), -- SCMO: ประมวลผลและจำลองสัญญาณดิจิทัล
    (33, 23, 2), -- NUAN: คณิตศาสตร์การประมวลผลสัญญาณ
    (33, 19, 2), -- MLNG: พื้นฐานการประมวลผลสัญญาณสำหรับการเรียนรู้ของเครื่อง
    -- ENGCE162 สัญาณและระบบ (ไม่มี CLO ในหลักสูตร 2570)
    (34, 23, 2), -- NUAN: คณิตศาสตร์สัญญาณและระบบ (Fourier/Laplace)
    (34, 33, 2), -- SCMO: สร้างแบบจำลองระบบ
    -- ENGCE201 การคำนวณสมรรถนะสูงและสถาปัตยกรรมแบบคลาวด์ (ไม่มี CLO ในหลักสูตร 2570)
    (35, 16, 3), -- HPCC: การคำนวณสมรรถนะสูง
    (35, 17, 3), -- IFDN: CLO ของ BECP0316: สถาปัตยกรรมระบบคลาวด์
    -- ENGCE202 การสั่งงานด้วยอุปกรณ์เคลื่อนที่แบบพกพา (ไม่มี CLO ในหลักสูตร 2570)
    (36, 27, 2), -- PROG: เขียนโปรแกรมสั่งงานผ่านอุปกรณ์พกพา
    (36, 29, 2), -- RESD: ควบคุมอุปกรณ์/ระบบฝังตัวผ่านอุปกรณ์เคลื่อนที่
    (36, 43, 2), -- SINT: เชื่อมต่ออุปกรณ์เคลื่อนที่เข้ากับระบบ
    -- ENGCE203 การโปรแกรมแบบขนานสำหรับระบบคลัสเตอร์คอมพิวเตอร์ (ไม่มี CLO ในหลักสูตร 2570)
    (37, 16, 3), -- HPCC: โปรแกรมแบบขนานสำหรับระบบคลัสเตอร์
    (37, 27, 3), -- PROG: พัฒนาโปรแกรมแบบขนาน
    -- ENGCE204 วิทยาการหุ่นยนต์ขนาดเล็ก (รหัสใหม่ BECP0109)
    (38, 29, 3), -- RESD: CLO2-3 สร้าง/ควบคุมหุ่นยนต์ด้วยไมโครคอนโทรลเลอร์
    (38, 27, 2), -- PROG: เขียนโปรแกรมควบคุมหุ่นยนต์
    (38, 43, 3), -- SINT: บูรณาการเซนเซอร์-โมดูล-การเคลื่อนที่
    -- ENGCE205 ระบบอัตโนมัติเบื้องต้น (รหัสใหม่ BECP0107)
    (39, 29, 3), -- RESD: CLO2 ออกแบบวงจรควบคุม/ใช้เซนเซอร์ไมโครคอนโทรลเลอร์
    (39, 21, 2), -- NTAS: CLO3 สื่อสารข้อมูล IoT ไปคลาวด์
    (39, 33, 2), -- SCMO: CLO1 องค์ประกอบระบบควบคุมอัตโนมัติ
    -- ENGCE206 โครงสร้างพื้นฐานแบบกลุ่มเมฆ (ไม่มี CLO ในหลักสูตร 2570)
    (40, 17, 3), -- IFDN: โครงสร้างพื้นฐานแบบกลุ่มเมฆ (ต่อเนื่องจาก BECP0316-0317)
    (40, 18, 3), -- ITOP: ติดตั้งและดูแลบริการบนคลาวด์
    (40, 38, 2), -- STMG: การจัดการที่เก็บข้อมูลบนคลาวด์
    -- ENGCE207 หัวข้อความก้าวล้ำในงานวิศวกรรมคอมพิวเตอร์ (รหัสใหม่ BECP0011)
    (41, 11, 3), -- EMRG: CLO1-3 ติดตาม/วิเคราะห์/สร้างแนวคิดเทคโนโลยีใหม่
    (41, 13, 2), -- FEAS: CLO2 วิเคราะห์ความเป็นไปได้การประยุกต์ใช้
    -- ENGCE156 การโต้ตอบระหว่างคอมพิวเตอร์กับมนุษย์ (ไม่มี CLO ในหลักสูตร 2570)
    (42, 4, 2), -- BUSA: วิเคราะห์พฤติกรรมและความต้องการผู้ใช้ (ต่อเนื่องจาก BECP0314 UX/UI)
    (42, 35, 2), -- SWDN: ออกแบบส่วนติดต่อผู้ใช้ (UI/UX)
    -- ENGCE173 การวิเคราะห์และออกแบบเชิงวัตถุ (ไม่มี CLO ในหลักสูตร 2570)
    (43, 35, 3), -- SWDN: วิเคราะห์และออกแบบเชิงวัตถุ
    (43, 41, 3), -- DESN: CLO ของ BECP0305: แบบจำลองระบบเชิงวัตถุ UML
    (43, 3, 2), -- BSMO: แบบจำลองกระบวนการเชิงธุรกิจ
    -- ENGCE174 การเขียนโปรแกรมเชิงวัตถุ (รหัสใหม่ BECP0301)
    (44, 27, 3), -- PROG: CLO2 พัฒนาโปรแกรมเชิงวัตถุ
    (44, 35, 3), -- SWDN: CLO3 ออกแบบโครงสร้างโปรแกรมใช้ซ้ำได้
    -- ENGCE177 หัวข้อความก้าวล้ำในงานวิศวกรรมซอฟต์แวร์ (ไม่มี CLO ในหลักสูตร 2570)
    (45, 11, 3), -- EMRG: ติดตามและวิเคราะห์เทคโนโลยีซอฟต์แวร์ใหม่
    (45, 35, 3), -- SWDN: หัวข้อก้าวหน้าการออกแบบซอฟต์แวร์ (ต่อเนื่องจาก BECP0308/0318)
    -- ENGCE186 สถาปัตยกรรมซอฟต์แวร์ (รหัสใหม่ BECP0308)
    (46, 35, 4), -- SWDN: CLO1-3 เปรียบเทียบ/ออกแบบ/ประเมินสถาปัตยกรรม-Design Patterns
    -- ENGCE301 การออกแบบและพัฒนาซอฟต์แวร์ (รหัสใหม่ BECP0306)
    (47, 35, 3), -- SWDN: CLO2 ออกแบบสถาปัตยกรรมซอฟต์แวร์
    (47, 15, 3), -- TEST: CLO3 การทดสอบซอฟต์แวร์
    (47, 5, 2), -- CHMG: CLO3 การจัดการเวอร์ชัน
    (47, 30, 2), -- RELM: CLO3 การส่งมอบซอฟต์แวร์/DevOps
    (47, 6, 2), -- CFMG: CLO3 การจัดการเวอร์ชันและการควบคุมการตั้งค่าของซอฟต์แวร์
    (47, 9, 2), -- DEMG: CLO3 การส่งมอบซอฟต์แวร์ตามรอบเวลา (DevOps/Release)
    -- ENGCE302 การกำหนดความต้องการและการออกแบบทางซอฟต์แวร์ (ไม่มี CLO ในหลักสูตร 2570)
    (48, 31, 3), -- REQM: กำหนดและจัดการความต้องการซอฟต์แวร์
    (48, 35, 3), -- SWDN: CLO ของ BECP0306: ออกแบบซอฟต์แวร์ตามความต้องการ
    -- ENGCE303 การตรวจสอบความสมเหตุสมผลและการทวนสอบซอฟต์แวร์ (ไม่มี CLO ในหลักสูตร 2570)
    (49, 15, 3), -- TEST: การทวนสอบและตรวจสอบความถูกต้องของซอฟต์แวร์
    (49, 22, 3), -- NFTS: ทดสอบคุณภาพมิใช่เชิงฟังก์ชันของซอฟต์แวร์
    -- ENGCE304 กระบวนการซอฟต์แวร์และการประกันคุณภาพ (ไม่มี CLO ในหลักสูตร 2570)
    (50, 15, 2), -- TEST: การประกันคุณภาพซอฟต์แวร์
    (50, 5, 2), -- CHMG: ควบคุมการเปลี่ยนแปลงและกระบวนการซอฟต์แวร์
    -- ENGCE305 การบริหารจัดการโครงการซอฟต์แวร์ (รหัสใหม่ BECP0013)
    (51, 28, 3), -- PRMG: CLO1-2 วางแผน/ควบคุม/วิเคราะห์ความเสี่ยงโครงการ
    (51, 25, 2), -- PROF: CLO3 นำเสนอความก้าวหน้าโครงการ WBS/Gantt
    (51, 2, 2), -- BENM: การคาดการณ์/ติดตามผลประโยชน์ของโครงการ IT (Gantt, WBS, ความเสี่ยง)
    (51, 24, 2), -- POMG: การบริหารกลุ่มโครงการ/พอร์ตโฟลิโอด้าน IT ในภาพรวม
    (51, 26, 2), -- PGMG: การวางแผนและประสานงานโครงการที่เกี่ยวข้องกันเพื่อเป้าหมายเชิงกลยุทธ์
    -- ENGCE306 การเขียนโปรแกรมบนเว็บ (รหัสใหม่ BECP0307)
    (52, 27, 3), -- PROG: CLO1-2 เขียนโปรแกรมเว็บ Client-Server
    (52, 8, 2), -- DENG: CLO3 เชื่อมโยงฐานข้อมูล
    (52, 43, 2), -- SINT: CLO3 เชื่อมต่อ API
    -- ENGCE307 การพัฒนาโปรแกรมประยุกต์สำหรับอุปกรณ์เคลื่อนที่ (รหัสใหม่ BECP0311)
    (53, 27, 3), -- PROG: CLO2 เขียนแอป Android/iOS
    (53, 4, 2), -- BUSA: CLO1 ออกแบบ UI/UX
    (53, 43, 2), -- SINT: CLO3 เชื่อมโยงฐานข้อมูล/API
    -- ENGCE308 การพัฒนาเกมสำหรับอุปกรณ์เคลื่อนที่ (รหัสใหม่ BECP0312)
    (54, 27, 3), -- PROG: CLO2 พัฒนาเกมด้วย Game Engine
    (54, 15, 2), -- TEST: CLO3 ทดสอบเกม
    (54, 30, 2), -- RELM: CLO3 เผยแพร่เกมบนแพลตฟอร์ม
    -- ENGCE309 การประมวลผลแบบคลาวด์ (รหัสใหม่ BECP0316)
    (55, 17, 3), -- IFDN: CLO1 สถาปัตยกรรมระบบคลาวด์
    (55, 18, 3), -- ITOP: CLO2 ใช้บริการ Compute/Storage/Networking
    (55, 38, 2), -- STMG: การจัดการทรัพยากร/ที่เก็บข้อมูลบนคลาวด์
    -- ENGCE310 การพัฒนาโปรแกรมบนระบบคลาวด์ (รหัสใหม่ BECP0317)
    (56, 10, 3), -- DEPL: CLO2 ปรับใช้แอปบนคลาวด์
    (56, 17, 3), -- IFDN: CLO1 วางแผนเลือกบริการคลาวด์
    (56, 18, 3), -- ITOP: CLO3 เฝ้าระวัง/ปรับปรุงประสิทธิภาพ
    (56, 1, 2), -- ASMG: Auto Scaling/Load Balancing
    (56, 39, 2), -- SUPP: CLO1 การเลือกและบริหารผู้ให้บริการคลาวด์ (AWS/Azure) ตามความต้องการ
    -- ENGCE311 วิทยาการข้อมูลและการวิเคราะห์ (รหัสใหม่ BECP0402)
    (57, 8, 3), -- DENG: CLO1-3 เตรียมข้อมูล/วิเคราะห์/visualize ด้วย pandas-matplotlib
    (57, 14, 2), -- RSCH: กระบวนการวิเคราะห์ข้อมูลเชิงสถิติ
    -- ENGCE312 การสร้างและทำการตลาดสินค้าดิจิทัล (รหัสใหม่ BECP0014)
    (58, 4, 2), -- BUSA: CLO1 วิเคราะห์ความต้องการผู้ใช้
    (58, 3, 2), -- BSMO: CLO2 กลยุทธ์การตลาด/โมเดลผลิตภัณฑ์ดิจิทัล
    -- ENGCE313 เทคโนโลยีบล็อคเชน (รหัสใหม่ BECP0411)
    (59, 11, 2), -- EMRG: CLO1,CLO3 เทคโนโลยีบล็อคเชน/กรณีศึกษา
    (59, 27, 2), -- PROG: CLO2 เขียน Smart Contract
    (59, 43, 2), -- SINT: พัฒนา DApp บน Ethereum
    -- ENGCE401 ฟัซซีเซตเบื้องต้น (รหัสใหม่ BECP0403)
    (60, 33, 3), -- SCMO: CLO2-3 ประยุกต์/ออกแบบระบบฟัซซี
    (60, 19, 2), -- MLNG: ระบบอัจฉริยะ/การอนุมาน
    -- ENGCE402 คอมพิวเตอร์กราฟิกส์ (รหัสใหม่ BECP0310)
    (61, 27, 3), -- PROG: CLO3 เขียนโปรแกรมกราฟิก 2 มิติ
    (61, 33, 2), -- SCMO: CLO1-2 อัลกอริทึม/การเรนเดอร์
    -- ENGCE403 การประมวลผลภาพดิจิทัล และการมองเห็นโดยคอมพิวเตอร์ (รหัสใหม่ BECP0406)
    (62, 19, 3), -- MLNG: CLO3 คอมพิวเตอร์วิทัศน์/รู้จำวัตถุ
    (62, 14, 2), -- RSCH: เทคนิคประมวลผลภาพดิจิทัล
    (62, 33, 2), -- SCMO: CLO2 การกรอง/แปลงภาพ/ตรวจจับขอบ
    -- ENGCE404 การทำเหมืองข้อมูลขนาดใหญ่ (รหัสใหม่ BECP0409)
    (63, 8, 4), -- DENG: CLO1-3 เตรียมข้อมูล/เหมืองข้อมูลขนาดใหญ่/ประเมินผล
    (63, 19, 3), -- MLNG: CLO2 จำแนก/จัดกลุ่ม/คาดการณ์
    -- ENGCE405 การเรียนรู้เชิงลึกเบื้องต้น (รหัสใหม่ BECP0404)
    (64, 19, 4), -- MLNG: CLO1-3 สร้าง/ฝึก/ปรับปรุงโมเดล CNN-RNN Deep Learning
    (64, 27, 2), -- PROG: พัฒนาโปรแกรมโมเดลการเรียนรู้เชิงลึก
    -- ENGCE406 การประมวลภาษาธรรมชาติเบื้องต้น (รหัสใหม่ BECP0405)
    (65, 19, 3), -- MLNG: CLO2-3 ประยุกต์ NLP จำแนก/วิเคราะห์ข้อความ
    (65, 8, 2), -- DENG: การประมวลผล/สกัดข้อมูลจากข้อความ
    -- ENGCE407 หัวข้อความก้าวล้ำในงานวิศวกรรมปัญญาประดิษฐ์ (ไม่มี CLO ในหลักสูตร 2570)
    (66, 11, 3), -- EMRG: ติดตามเทคโนโลยีปัญญาประดิษฐ์ใหม่ (ต่อเนื่องจาก BECP0410)
    (66, 19, 3), -- MLNG: หัวข้อก้าวหน้าทางปัญญาประดิษฐ์และการเรียนรู้ของเครื่อง
    (66, 14, 2), -- RSCH: ศึกษาและสังเคราะห์งานวิจัยด้าน AI
    -- ENGCE408 ความรู้เบื้องต้นในการรู้จำรูปแบบ (รหัสใหม่ BECP0407)
    (67, 19, 3), -- MLNG: CLO3 ตัวจำแนก/การจัดกลุ่มข้อมูล
    (67, 14, 2), -- RSCH: CLO1-2 หลักการรู้จำรูปแบบ/เลือกลักษณะเด่น
    -- ENGCE409 โครงข่ายประสาทเทียม (ไม่มี CLO ในหลักสูตร 2570)
    (68, 19, 3), -- MLNG: CLO ของ BECP0404: โครงสร้าง/ฝึกโครงข่ายประสาทเทียม
    (68, 27, 2), -- PROG: พัฒนาโปรแกรมโครงข่ายประสาทเทียม
    -- ENGCE410 อัลกอริทึมเชิงวิวัฒนาการ (รหัสใหม่ BECP0408)
    (69, 33, 3), -- SCMO: CLO2 สร้างฟังก์ชันความเหมาะสม/ปรับพารามิเตอร์
    (69, 23, 2), -- NUAN: อัลกอริทึมการปรับค่าให้เหมาะสม
    (69, 19, 2), -- MLNG: อัลกอริทึมเชิงวิวัฒนาการ/เลียนแบบธรรมชาติ
    -- ENGCE411 เทคโนโลยีความจริงเสมือน (รหัสใหม่ BECP0313)
    (70, 27, 2), -- PROG: CLO2 พัฒนาเนื้อหา/แอป VR ด้วย Unity
    (70, 11, 2), -- EMRG: CLO1,CLO3 เทคโนโลยี VR/การประยุกต์ใช้
    -- GEN101 test for Communication (ไม่มี CLO ในหลักสูตร 2570)
    (71, 36, 1); -- TECH: วิชาทดสอบหลักสูตร 2 (Communication): ทักษะการสื่อสาร/การสื่อสารเชิงวิชาชีพ

CREATE TABLE student_grades (
    user_id INT,
    course_id INT,
    grade_letter VARCHAR(5) NOT NULL,  -- เก็บเกรดตัวอักษร เช่น 'A', 'B+', 'C+'
    grade_point DECIMAL(3,2) NOT NULL, -- เก็บแต้มตัวเลข เช่น 4.00, 3.50, 2.50
    PRIMARY KEY (user_id, course_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

