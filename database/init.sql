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
    ('ASMG','Asset management','Capacity Planning, Performance, Scalability','การบริหารจัดการทรัพย์สินดิจิทัลและเทคโนโลยีตลอดวงจรชีวิต เพื่อส่งมอบมูลค่าสูงสุดและปฏิบัติตามข้อกำหนด',1),
    ('BENM','Benefits management','Process Automation, User Experience','การคาดการณ์ วางแผน และติดตามผลประโยชน์ที่ได้รับจากโครงการและแผนงานดิจิทัล',1),
    ('BMOD','Business modelling','','การสร้าง ค้นหา และวิเคราะห์แบบจำลองกระบวนการหรือโครงสร้างทางธุรกิจ',1),
    ('BISA','Business situation analysis','Agile, Analytical, Application Debugging, Application Resiliency, Capacity Planning, Communication Skills, Cross Browser, Database Performance Tuning, Database Recovery Plan, Decision Making, Interpersonal Skills, Methodologies, Performance, Predictive Modelling, Predictive Software Development, Problem Solving, Process Automation, Relational Database Design, Relational Oltp Queries, Replication, Scalability, Scrum, System Troubleshooting, Team Player, Time Management Skills, User Experience','การประเมินสถานะ ปัญหา และบริบททางธุรกิจเพื่อระบุโอกาสในการปรับปรุงและสร้างโซลูชัน',1),
    ('CHMG','Change control','CI/CD, Cfengine, Chef, Cobbler, Deployment Validation, DevOps, Docker, Eks, Foreman, Gerrit, Git, Gitlab Ci, Gke, Infrastructure As Code, Jenkins, Kubernetes, Mercurial, Openshift, Puppet, Svn, Version Control','การประเมิน ถอดถอน และควบคุมการเปลี่ยนแปลงในผลิตภัณฑ์หรือระบบอย่างเป็นระบบ',1),
    ('CFMG','Configuration management','CI/CD, Cfengine, Chef, Cobbler, Deployment Validation, DevOps, Docker, Eks, Foreman, Gerrit, Git, Gitlab Ci, Gke, Infrastructure As Code, Jenkins, Kubernetes, Mercurial, Openshift, Puppet, Svn, Version Control','การติดตาม บริหารจัดการ และบันทึกโครงสร้างองค์ประกอบฮาร์ดแวร์/ซอฟต์แวร์ของระบบ',1),
    ('COPL','Continuity management','Datadog, Grafana, Prometheus','การวางแผน จัดทำ และทดสอบกรอบความต่อเนื่องในการดำเนินธุรกิจและระบบสารสนเทศ',1),
    ('DENG','Data engineering','Athena, Big Data, Bigquery, Data Mining, Database, Dynamodb, Elasticsearch, Glue, Lake Formation, Mongodb, Mssql, Mysql, Nosql, Oracle, Postgresql, Rds, Redis, Redshift, Spark, Sql','การออกแบบ สร้าง ปรับแต่งให้ใช้งานจริง และดูแลท่อส่งข้อมูล (Data Pipelines) และคลังจัดเก็บข้อมูล',1),
    ('DLMG','Delivery management','Agile, Analytical, Application Debugging, Application Resiliency, Capacity Planning, Communication Skills, Cross Browser, Database Performance Tuning, Database Recovery Plan, Decision Making, Interpersonal Skills, Methodologies, Performance, Predictive Modelling, Predictive Software Development, Problem Solving, Process Automation, Relational Database Design, Relational Oltp Queries, Replication, Scalability, Scrum, System Troubleshooting, Team Player, Time Management Skills, User Experience','การบริหารจัดการการส่งมอบผลิตภัณฑ์และบริการดิจิทัลให้เป็นไปตามเป้าหมายและคุณภาพที่กำหนด',1),
    ('DEPL','Deployment','CI/CD, Cfengine, Chef, Cobbler, Deployment Validation, DevOps, Docker, Eks, Foreman, Gerrit, Git, Gitlab Ci, Gke, Infrastructure As Code, Jenkins, Kubernetes, Mercurial, Openshift, Puppet, Svn, Version Control','การทดสอบ นำส่ง และติดตั้งส่วนประกอบของระบบเข้าสู่สภาพแวดล้อมใช้งานจริง (Production)',1),
    ('EMRG','Emerging technology monitoring','Cloud Computing','การติดตาม ประเมิน และวิเคราะห์เทคโนโลยีใหม่ๆ ที่มีศักยภาพในการสร้างโอกาสทางธุรกิจ',1),
    ('DCMA','Facilities management','Capacity Planning, Performance, Scalability','การบริหารจัดการโครงสร้างพื้นฐาน ศูนย์ข้อมูล (Data Centre) และสิ่งอำนวยความสะดวกทางเทคโนโลยี',1),
    ('FEAS','Feasibility assessment','','การประเมินความเป็นไปได้ในเชิงเทคโนโลยี การเงิน และการดำเนินงานของโซลูชันที่เสนอ',1),
    ('RSCH','Formal research','Classic Image Processing Techniques, Computer Vision, Distributed Systems, Faster Rcnn, Grid Computing, Image Processing, Instance Segmentation, Mask Rcnn, Matlab, Mobile Net, Object Detection, Opencv, R, Semantic Segmentation, Single Shot Multibox Detector Ssd','การวิจัย รวบรวมข้อมูล ทดลอง และประเมินอย่างเป็นระบบเพื่อสร้างความรู้ใหม่',1),
    ('TEST','Functional testing','Automated Testing, Automated Unit Testing, Chrome Inspector, Exploratory Testing, Firebug, Jasmine, Manual Testing, Progression/Regression Testing, Protractor, Pyunit, Testing, Unit Testing','การทดสอบ ประเมินผล และตรวจสอบระบบหรือส่วนประกอบซอฟต์แวร์ตามเกณฑ์ที่กำหนด',1),
    ('HPCO','High-performance computing','Classic Image Processing Techniques, Computer Vision, Distributed Systems, Faster Rcnn, Grid Computing, Image Processing, Instance Segmentation, Mask Rcnn, Matlab, Mobile Net, Object Detection, Opencv, R, Semantic Segmentation, Single Shot Multibox Detector Ssd','การออกแบบ พัฒนา และดูแลระบบการคำนวณและประมวลผลสมรรถนะสูง (HPC)',1),
    ('INFR','Infrastructure design','AWS EC2, Apache, Cloud Computing, Cloud Environments, Cloud Infrastructure, Cloudify, Containers, Iaas, Linux, Microsoft Iis, Mule, Openam, Paas, Tomcat, Urban Code, Vms, Windows Os','การออกแบบโครงสร้างพื้นฐานไอที ระบบเครือข่าย และระบบคลาวด์',1),
    ('ITOP','Infrastructure operations','AWS EC2, Apache, Cloud Computing, Cloud Environments, Cloud Infrastructure, Cloudify, Containers, Iaas, Linux, Microsoft Iis, Mule, Openam, Paas, Tomcat, Urban Code, Vms, Windows Os','การดูแล ปฏิบัติการ และสนับสนุนระบบโครงสร้างพื้นฐานไอทีใน daily operations',1),
    ('MLNG','Machine learning','Amazon Sagemaker, Artificial Neural Network Ann, Convolutional Neural Networks, Deep Learning, Keras, Machine Learning, Numpy, Pytorch, Scikit Learn, Tensorflow','การพัฒนาระบบ เทคนิค และแบบจำลองการเรียนรู้ของเครื่อง (Machine Learning models)',1),
    ('NTDS','Network design','Concurrency, Dns, F5 Load Balancers, HTTP API, Http, Networking, Ntp, Tcp/Ip, Threading','การออกแบบสถาปัตยกรรมและโครงสร้างระบบเครือข่ายสื่อสาร',1),
    ('NTAS','Network support','Concurrency, Dns, F5 Load Balancers, HTTP API, Http, Networking, Ntp, Tcp/Ip, Threading','การสนับสนุน ติดตั้ง บำรุงรักษา และแก้ปัญหาระบบเครือข่าย',1),
    ('TEST','Non-functional testing','Automated Testing, Automated Unit Testing, Chrome Inspector, Exploratory Testing, Firebug, Jasmine, Manual Testing, Progression/Regression Testing, Protractor, Pyunit, Testing, Unit Testing','การทดสอบ ประเมินผล และตรวจสอบระบบหรือส่วนประกอบซอฟต์แวร์ตามเกณฑ์ที่กำหนด',1),
    ('NMAN','Numerical analysis','Classic Image Processing Techniques, Computer Vision, Distributed Systems, Faster Rcnn, Grid Computing, Image Processing, Instance Segmentation, Mask Rcnn, Matlab, Mobile Net, Object Detection, Opencv, R, Semantic Segmentation, Single Shot Multibox Detector Ssd','การประยุกต์ใช้เทคนิคและแบบจำลองทางคณิตศาสตร์/ตัวเลขในการแก้ปัญหา',1),
    ('POMG','Portfolio management','Process Automation, User Experience','การบริหารจัดการกลุ่มโครงการ (Portfolio) ให้สอดคล้องกับวัตถุประสงค์เชิงกลยุทธ์',1),
    ('PROF','Portfolio, programme and project support','Process Automation, User Experience','การสนับสนุนด้านธุรการและแนวทางปฏิบัติสำหรับการบริหารกลุ่มโครงการและโครงการ',1),
    ('PGMG','Programme management','Process Automation, User Experience','การบริหารและประสานงานชุดโครงการ (Programme) เพื่อให้บรรลุผลประโยชน์เชิงกลยุทธ์',1),
    ('PROG','Programming/software development','Angular, Bash, Bootstrap, C#, C++, C/C++, CSS, Cocoa Touch, Django, Flask, Flutter, Go, Groovy, HTML, Java, JavaScript, Jquery, Less, Node.js, Objective C, Perl, Php, Postcss, Python, React, React / Angular, Ruby, Sass, Scala, Vue.js, Wordpress, Xml/Xslt, Zend','การออกแบบ เขียนโค้ด ทดสอบ และพัฒนาส่วนประกอบซอฟต์แวร์เพื่อสร้างมูลค่าแก่ผู้ใช้',1),
    ('PRMG','Project management','Agile, Analytical, Application Debugging, Application Resiliency, Capacity Planning, Communication Skills, Cross Browser, Database Performance Tuning, Database Recovery Plan, Decision Making, Interpersonal Skills, Methodologies, Performance, Predictive Modelling, Predictive Software Development, Problem Solving, Process Automation, Relational Database Design, Relational Oltp Queries, Replication, Scalability, Scrum, System Troubleshooting, Team Player, Time Management Skills, User Experience','การบริหารจัดการโครงการให้บรรลุผลสำเร็จตามกรอบเวลา งบประมาณ และคุณภาพที่กำหนด',1),
    ('RESD','Real-time/embedded systems development','API, API Development, Adaptive Design, Algorithms, Design Patterns, Edge, Graphql, Mvc, Object Oriented Programming, REST API, Responsive Design, Responsive Ui, Rpc, Single Page Application Spa','การพัฒนาระบบฝังตัว (Embedded) และระบบประมวลผลแบบเรียลไทม์',1),
    ('RELM','Release management','Process Automation, User Experience','การวางแผน จัดเวลา และควบคุมการปลดปล่อยเวอร์ชัน (Release) ของซอฟต์แวร์',1),
    ('REQM','Requirements definition and management','Agile, Analytical, Application Debugging, Application Resiliency, Capacity Planning, Communication Skills, Cross Browser, Database Performance Tuning, Database Recovery Plan, Decision Making, Interpersonal Skills, Methodologies, Performance, Predictive Modelling, Predictive Software Development, Problem Solving, Process Automation, Relational Database Design, Relational Oltp Queries, Replication, Scalability, Scrum, System Troubleshooting, Team Player, Time Management Skills, User Experience','การค้นหา วิเคราะห์ กำหนด และบริหารจัดการความต้องการของผู้ใช้และระบบ',1),
    ('SFEN','Safety engineering','Process Automation, User Experience','การวิเคราะห์ ออกแบบ และประเมินความปลอดภัยของระบบเพื่อป้องกันอันตราย',1),
    ('SMOD','Scientific modelling','Classic Image Processing Techniques, Computer Vision, Distributed Systems, Faster Rcnn, Grid Computing, Image Processing, Instance Segmentation, Mask Rcnn, Matlab, Mobile Net, Object Detection, Opencv, R, Semantic Segmentation, Single Shot Multibox Detector Ssd','การสร้างและใช้แบบจำลองทางวิทยาศาสตร์และคณิตศาสตร์เพื่อจำลองปรากฏการณ์',1),
    ('SLMO','Service level management','Datadog, Grafana, Prometheus','การตกลง กำหนด และบริหารจัดการระดับการให้บริการ (SLA) ให้เป็นไปตามสัญญา',1),
    ('SWDN','Software design','API, API Development, Adaptive Design, Algorithms, Design Patterns, Edge, Graphql, Mvc, Object Oriented Programming, REST API, Responsive Design, Responsive Ui, Rpc, Single Page Application Spa','การแปลงความต้องการเป็นการออกแบบสถาปัตยกรรมและรายละเอียดชิ้นส่วนซอฟต์แวร์',1),
    ('TECH','Specialist advice','Communication Skills, Interpersonal Skills','การให้คำแนะนำและความรู้ความเชี่ยวชาญเฉพาะทางแก่ผู้มีส่วนได้ส่วนเสีย',1),
    ('RLMT','Stakeholder relationship management','Communication Skills, Interpersonal Skills','การสร้างและรักษาความสัมพันธ์อันดีกับผู้มีส่วนได้ส่วนเสียในระดับต่างๆ',1),
    ('STMG','Storage management','Capacity Planning, Performance, Scalability','การบริหารจัดการ วางแผน และดูแลระบบจัดเก็บข้อมูล (Data Storage)',1),
    ('SUPP','Supplier management','Communication Skills, Interpersonal Skills','การบริหารจัดการ ความสัมพันธ์ และสัญญาของคู่ค้าหรือผู้ให้บริการภายนอก',1),
    ('SYSP','System software administration','AWS EC2, Apache, Cloud Computing, Cloud Environments, Cloud Infrastructure, Cloudify, Containers, Iaas, Linux, Microsoft Iis, Mule, Openam, Paas, Tomcat, Urban Code, Vms, Windows Os','การติดตั้ง กำหนดค่า และบริหารจัดการซอฟต์แวร์ระบบและระบบปฏิบัติการ',1),
    ('DESG','Systems design','API, API Development, Adaptive Design, Algorithms, Design Patterns, Edge, Graphql, Mvc, Object Oriented Programming, REST API, Responsive Design, Responsive Ui, Rpc, Single Page Application Spa','การออกแบบระบบสารสนเทศโดยรวมทั้งในส่วนฮาร์ดแวร์ ซอฟต์แวร์ และกระบวนการ',1),
    ('HSIN','Systems installation and removal','AWS, Azure, Azure Functions, Gcp, Kafka, Kineses','การติดตั้ง กำหนดค่า และถอนการติดตั้งอุปกรณ์ฮาร์ดแวร์และระบบเทคโนโลยี',1),
    ('SINT','Systems integration and build','AWS, Azure, Azure Functions, Gcp, Kafka, Kineses','การรวมและทดสอบประกอบส่วนประกอบซอฟต์แวร์และระบบต่างๆ เข้าด้วยกัน',1);

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

