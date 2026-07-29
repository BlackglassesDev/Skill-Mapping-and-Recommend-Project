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

