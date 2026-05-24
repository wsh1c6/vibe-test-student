-- =====================================================
-- 第四题：高校选课管理系统 - 数据库设计与分析
-- =====================================================

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS enrollment_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE enrollment_system;

-- 一、核心数据模型设计
-- =====================================================

-- 注意：创建表时需要先创建被引用的表

-- 1. 教师表 (teachers) - 放在最前面，因为其他表可能引用它
DROP TABLE IF EXISTS teachers;
CREATE TABLE teachers (
    teacher_id VARCHAR(20) PRIMARY KEY,
    teacher_name VARCHAR(50) NOT NULL,
    teacher_gender VARCHAR(10),
    teacher_title VARCHAR(20) COMMENT '教授/副教授/讲师',
    department VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. 学生表 (students) - 放在courses前面，因为enrollments引用它
DROP TABLE IF EXISTS students;
CREATE TABLE students (
    student_id VARCHAR(20) PRIMARY KEY,
    student_name VARCHAR(50) NOT NULL,
    student_gender VARCHAR(10),
    student_major VARCHAR(50),
    student_grade VARCHAR(10),
    student_class VARCHAR(20),
    phone VARCHAR(20),
    email VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 3. 课程表 (courses) - 在enrollments前面
DROP TABLE IF EXISTS courses;
CREATE TABLE courses (
    course_id VARCHAR(20) PRIMARY KEY,
    course_name VARCHAR(50) NOT NULL,
    course_type VARCHAR(20) NOT NULL COMMENT '公共课/专业课/选修课',
    capacity INT NOT NULL DEFAULT 0,
    credits DECIMAL(3,1),
    teacher_id VARCHAR(20),
    semester VARCHAR(20),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id)
);

-- 4. 选课记录表 (enrollments) - 最后创建，因为引用students和courses
DROP TABLE IF EXISTS enrollments;
CREATE TABLE enrollments (
    student_id VARCHAR(20) NOT NULL,
    course_id VARCHAR(20) NOT NULL,
    enroll_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT '已选' COMMENT '已选/已退/待审核',
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- 5. 开课计划表 (course_schedules)
DROP TABLE IF EXISTS course_schedules;
CREATE TABLE course_schedules (
    schedule_id VARCHAR(20) PRIMARY KEY,
    course_id VARCHAR(20) NOT NULL,
    teacher_id VARCHAR(20),
    location VARCHAR(50),
    schedule_time VARCHAR(100),
    week_range VARCHAR(50),
    current_enrolled INT DEFAULT 0,
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id)
);

-- 表间关联关系说明：
-- students 1--* enrollments *--1 courses
-- courses *--1 teachers (课程归属教师)
-- courses 1--* course_schedules (课程开课计划)


-- 二、ER图（文本表示）
-- =====================================================
-- 
--     +-------------+         +---------------+         +-------------+
--     |  students  |         |  enrollments  |         |   courses   |
--     +-------------+         +---------------+         +-------------+
--     | PK student_id|------->| FK student_id|         | PK course_id|
--     | student_name |         | FK course_id  |<-------| course_name |
--     | student_gender      | enroll_time  |         | course_type |
--     | student_major       | status       |         | capacity   |
--     +-------------+         +---------------+         | credits    |
--                                                         +-------------+
--                                                                 |
--                                                                 v
--                                                         +-------------+
--                                                         |  teachers   |
--                                                         +-------------+
--                                                         | PK teacher_id|
--                                                         | teacher_name |
--                                                         | department  |
--                                                         +-------------+


-- 三、并发风险分析与解决方案
-- =====================================================

-- 核心并发问题：选课高峰期可能出现以下问题
-- 1. 超卖问题：多个学生同时选择同一门课程，可能导致选课人数超过课程容量
-- 2. 数据不一致：并发更新导致选课状态不一致
-- 3. 重复选课：同一学生多次提交选课请求

-- 解决方案：乐观锁 + 事务控制
-- 采用数据库事务配合乐观锁机制，确保选课操作的原子性

-- 示例SQL解决方案：
START TRANSACTION;

-- 检查课程容量（使用行级锁）
SELECT capacity, current_enrolled 
FROM course_schedules 
WHERE course_id = 'C000001' 
FOR UPDATE;

-- 检查学生是否已选
SELECT COUNT(*) FROM enrollments 
WHERE student_id = 'S000001' AND course_id = 'C000001';

-- 插入选课记录
INSERT INTO enrollments (student_id, course_id, enroll_time, status)
VALUES ('S000001', 'C000001', NOW(), '已选');

-- 更新已选人数
UPDATE course_schedules 
SET current_enrolled = current_enrolled + 1 
WHERE course_id = 'C000001' 
  AND current_enrolled < capacity;

COMMIT;


-- 四、索引设计
-- =====================================================

-- 1. 选课记录表 (enrollments) 索引设计
-- 复合主键索引：(student_id, course_id) - 已存在

-- 检索学生选课记录
CREATE INDEX idx_enrollments_student_id ON enrollments(student_id);

-- 检索课程选课学生列表 + 统计查询
CREATE INDEX idx_enrollments_course_id ON enrollments(course_id);

-- 按选课时间排序查询
CREATE INDEX idx_enrollments_enroll_time ON enrollments(enroll_time);

-- 组合索引：支持按课程类型统计（关联courses表）
CREATE INDEX idx_enrollments_course_status ON enrollments(course_id, status);

-- 2. 课程表 (courses) 索引设计
-- 主键索引：course_id - 已存在

-- 按课程类型查询
CREATE INDEX idx_courses_type ON courses(course_type);

-- 按授课教师查询
CREATE INDEX idx_courses_teacher ON courses(teacher_id);

-- 按学期查询
CREATE INDEX idx_courses_semester ON courses(semester);

-- 组合索引：支持专业课统计查询
CREATE INDEX idx_courses_type_name ON courses(course_type, course_name);

-- 3. 学生表 (students) 索引设计
-- 主键索引：student_id - 已存在

-- 按姓名模糊查询
CREATE INDEX idx_students_name ON students(student_name);

-- 按专业和年级查询
CREATE INDEX idx_students_major_grade ON students(student_major, student_grade);

-- 索引设计理由：
-- 1. 选课记录表以(student_id, course_id)为主键，确保去重和联合查询效率
-- 2. enrollments表的course_id索引支持按课程统计选课人数
-- 3. courses表的course_type索引支持按课程类型筛选和统计
-- 4. 组合索引优化多条件查询性能
-- 5. 避免过度索引，每次索引都会增加写操作开销


-- =====================================================
-- 五、测试数据（Demo Data）
-- =====================================================

-- 插入教师数据
INSERT INTO teachers (teacher_id, teacher_name, teacher_gender, teacher_title, department, phone, email) VALUES
('T001', '张三', '男', '教授', '计算机学院', '13800001001', 'zhangsan@university.edu'),
('T002', '李四', '女', '副教授', '计算机学院', '13800001002', 'lisi@university.edu'),
('T003', '王五', '男', '讲师', '计算机学院', '13800001003', 'wangwu@university.edu'),
('T004', '赵六', '女', '教授', '数学学院', '13800001004', 'zhaoliu@university.edu'),
('T005', '钱七', '男', '副教授', '数学学院', '13800001005', 'qianqi@university.edu');

-- 插入学生数据
INSERT INTO students (student_id, student_name, student_gender, student_major, student_grade, student_class, phone, email) VALUES
('S2021001', '王小明', '男', '计算机科学与技术', '2021', '计21-1班', '13900001001', 'wangxm@student.edu'),
('S2021002', '李小红', '女', '计算机科学与技术', '2021', '计21-1班', '13900001002', 'lixh@student.edu'),
('S2021003', '张小华', '男', '软件工程', '2021', '软工21-1班', '13900001003', 'zhangxh@student.edu'),
('S2021004', '刘小芳', '女', '软件工程', '2021', '软工21-1班', '13900001004', 'liuxf@student.edu'),
('S2021005', '陈小军', '男', '信息安全', '2021', '信安21-1班', '13900001005', 'chenxj@student.edu'),
('S2022001', '周小杰', '男', '计算机科学与技术', '2022', '计22-1班', '13900001006', 'zhouxj@student.edu'),
('S2022002', '吴小娟', '女', '计算机科学与技术', '2022', '计22-2班', '13900001007', 'wuxj@student.edu'),
('S2022003', '郑小伟', '男', '软件工程', '2022', '软工22-1班', '13900001008', 'zhengxw@student.edu'),
('S2022004', '孙小玲', '女', '数据科学与大数据技术', '2022', '数据22-1班', '13900001009', 'sunxl@student.edu'),
('S2022005', '杨小波', '男', '人工智能', '2022', 'AI22-1班', '13900001010', 'yangxb@student.edu');

-- 插入课程数据
INSERT INTO courses (course_id, course_name, course_type, capacity, credits, teacher_id, semester) VALUES
('C001', 'Java程序设计', '专业课', 100, 4.0, 'T001', '2024-1'),
('C002', '数据结构', '专业课', 80, 4.0, 'T001', '2024-1'),
('C003', '计算机网络', '公共课', 150, 3.0, 'T002', '2024-1'),
('C004', '操作系统', '专业课', 80, 4.0, 'T002', '2024-1'),
('C005', '数据库原理', '专业课', 80, 4.0, 'T003', '2024-1'),
('C006', '高等数学A', '公共课', 200, 4.0, 'T004', '2024-1'),
('C007', '线性代数', '公共课', 180, 3.0, 'T005', '2024-1'),
('C008', '离散数学', '专业课', 100, 3.0, 'T003', '2024-1'),
('C009', '软件工程', '专业课', 60, 3.0, 'T002', '2024-2'),
('C010', 'Python程序设计', '选修课', 60, 2.0, 'T001', '2024-2');

-- 插入选课记录数据
INSERT INTO enrollments (student_id, course_id, enroll_time, status) VALUES
('S2021001', 'C001', '2024-01-15 10:30:00', '已选'),
('S2021001', 'C002', '2024-01-15 10:32:00', '已选'),
('S2021001', 'C003', '2024-01-15 10:35:00', '已选'),
('S2021001', 'C006', '2024-01-15 10:36:00', '已选'),
('S2021002', 'C001', '2024-01-15 11:00:00', '已选'),
('S2021002', 'C002', '2024-01-15 11:02:00', '已选'),
('S2021002', 'C004', '2024-01-15 11:05:00', '已选'),
('S2021003', 'C001', '2024-01-15 14:00:00', '已选'),
('S2021003', 'C002', '2024-01-15 14:02:00', '已选'),
('S2021003', 'C005', '2024-01-15 14:05:00', '已选'),
('S2021003', 'C008', '2024-01-15 14:08:00', '已选'),
('S2021004', 'C001', '2024-01-15 15:00:00', '已选'),
('S2021004', 'C002', '2024-01-15 15:02:00', '已选'),
('S2021005', 'C001', '2024-01-15 16:00:00', '已选'),
('S2021005', 'C003', '2024-01-15 16:02:00', '已选'),
('S2021005', 'C005', '2024-01-15 16:05:00', '已选'),
('S2022001', 'C001', '2024-01-16 09:00:00', '已选'),
('S2022001', 'C006', '2024-01-16 09:02:00', '已选'),
('S2022001', 'C007', '2024-01-16 09:05:00', '已选'),
('S2022002', 'C001', '2024-01-16 10:00:00', '已选'),
('S2022002', 'C003', '2024-01-16 10:02:00', '已选'),
('S2022002', 'C006', '2024-01-16 10:05:00', '已选'),
('S2022003', 'C001', '2024-01-16 11:00:00', '已选'),
('S2022003', 'C002', '2024-01-16 11:02:00', '已选'),
('S2022003', 'C008', '2024-01-16 11:05:00', '已选'),
('S2022004', 'C001', '2024-01-16 14:00:00', '已选'),
('S2022004', 'C002', '2024-01-16 14:02:00', '已选'),
('S2022004', 'C010', '2024-01-16 14:05:00', '已选'),
('S2022005', 'C001', '2024-01-16 15:00:00', '已选'),
('S2022005', 'C010', '2024-01-16 15:02:00', '已选');

-- 插入开课计划数据
INSERT INTO course_schedules (schedule_id, course_id, teacher_id, location, schedule_time, week_range, current_enrolled) VALUES
('SCH001', 'C001', 'T001', '教学楼A101', '周一 08:00-09:40', '1-16', 10),
('SCH002', 'C002', 'T001', '教学楼A102', '周二 10:00-11:40', '1-16', 8),
('SCH003', 'C003', 'T002', '教学楼B201', '周三 14:00-15:40', '1-16', 6),
('SCH004', 'C004', 'T002', '教学楼A103', '周四 08:00-09:40', '1-16', 2),
('SCH005', 'C005', 'T003', '实验楼301', '周五 10:00-11:40', '1-16', 5),
('SCH006', 'C006', 'T004', '教学楼C101', '周一 10:00-11:40', '1-16', 6),
('SCH007', 'C007', 'T005', '教学楼C102', '周二 14:00-15:40', '1-16', 3),
('SCH008', 'C008', 'T003', '教学楼A104', '周三 10:00-11:40', '1-16', 3),
('SCH009', 'C010', 'T001', '实验楼201', '周四 14:00-15:40', '1-16', 2);
