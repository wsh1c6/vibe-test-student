-- =====================================================
-- 高校选课管理系统 - SQL统计查询
-- =====================================================

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS enrollment_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE enrollment_system;

-- 题目1：统计每门课程的选课人数，返回课程ID、课程名称、选课人数（别名：enroll_count），结果按选课人数降序排序
SELECT 
    c.course_id AS courseId,
    c.course_name AS courseName,
    COUNT(e.student_id) AS enroll_count
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name
ORDER BY enroll_count DESC;


-- 题目2：统计选课人数超过50人的专业课，返回课程ID、课程名称、选课人数，结果按选课人数升序排序
SELECT 
    c.course_id AS courseId,
    c.course_name AS courseName,
    COUNT(e.student_id) AS enroll_count
FROM courses c
INNER JOIN enrollments e ON c.course_id = e.course_id
WHERE c.course_type = '专业课'
GROUP BY c.course_id, c.course_name
HAVING COUNT(e.student_id) > 50
ORDER BY enroll_count ASC;
