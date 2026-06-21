# 高校选课管理系统

基于Spring Boot 3.x框架开发的高校选课管理系统，提供学生选课数据处理功能。

## AI编程工具

- **工具名称**：Trae IDE
- **AI模型**：MiniMax-M2.5

## 开发思路

本项目采用Vibe Coding（氛围编程）方式开发，通过AI辅助完成代码生成和优化。

### 开发流程
1. 明确需求：将题目要求整理为完整的需求文档
2. AI辅助编码：向AI描述需求，生成基础代码框架
3. 代码审查：检查生成的代码是否符合要求
4. 功能优化：根据实际需求对代码进行修改和完善
5. 测试验证：确保功能正常运行

### 提示词设计
向AI提供的完整提示词需包含以下要素：
- 明确技术栈：SpringBoot 3.x版本
- 分层要求：Controller → Service → Entity架构
- 后端功能需求：去重、排序、分类、检索
- 页面设计需求：CSV文本框批量导入、数据展示
- 前后端衔接要求
- 性能要求：1000条以上≤1秒，500条批量导入

### 提示词示例
```
请使用SpringBoot 3.x框架帮我开发一个高校选课管理系统：
1. 后端采用Controller→Service→Entity分层架构
2. 实现选课数据去重（学生ID+课程ID）、排序（学生ID升序，相同则课程ID升序）
3. 增加选课分类功能（按课程类型：公共课/专业课/选修课分类）
4. 增加选课检索功能（支持按学生ID、课程ID、课程名称、课程类型检索）
5. 设计前端页面：CSV文本框批量导入、数据展示、按课程类型筛选
6. 前后端衔接：页面上传数据经后端处理后回显展示
7. 性能要求：1000条以上响应≤1秒，支持≥500条批量导入
```

### 人工修改优化说明

在AI生成代码的基础上，根据实际需求进行了以下优化：

1. **搜索功能修复**：原AI生成的搜索只作用于样例数据，修改为同时支持搜索导入数据和样例数据
2. **筛选功能增强**：添加lastCsvData参数传递，使分类筛选能同时作用于导入数据和样例数据
3. **前后端数据贯通**：确保导入CSV后，搜索和筛选功能都能正确处理新导入的数据

## 技术栈

- **后端框架**：Spring Boot 3.2.0
- **Java版本**：Java 17
- **模板引擎**：Thymeleaf
- **构建工具**：Maven

## 项目结构

```
vibe-test/
├── enrollment-system/           # Spring Boot项目
│   ├── src/main/java/com/example/enrollment/
│   │   ├── controller/         # 控制层
│   │   │   └── EnrollmentController.java
│   │   ├── service/            # 服务层
│   │   │   └── EnrollmentService.java
│   │   ├── entity/             # 实体层
│   │   │   └── EnrollRecord.java
│   │   └── EnrollmentApplication.java
│   ├── src/main/resources/
│   │   ├── templates/
│   │   │   └── index.html      # 前端页面
│   │   ├── application.properties
│   │   └── database-design.sql # 数据库设计
│   └── pom.xml
├── sql-queries.sql              # SQL统计查询
└── EnrollmentProcessor.java    # Java基础处理工具
```

## 功能特性

### 1. 选课数据处理
- **去重**：根据学生ID+课程ID自动去重
- **排序**：按学生ID升序，相同则按课程ID升序
- **分类**：自动识别课程类型（公共课/专业课/选修课）

### 2. 选课检索
- 支持按学生ID检索
- 支持按课程ID检索
- 支持按课程名称检索
- 支持按课程类型检索
- 检索不到时提示"无匹配选课记录"

### 3. 页面功能
- CSV格式批量导入选课数据
- 数据展示表格
- 按课程类型筛选（全部/公共课/专业课/选修课）
- 样例数据展示

## 运行方式

### 前提条件
- JDK 17或更高版本
- Maven 3.6+

### 启动项目

```bash
cd enrollment-system
mvn spring-boot:run
```

启动成功后，访问 http://localhost:8080

## CSV数据格式

```
学生ID,课程ID,课程名称,课程类型
S000001,C000001,Java程序设计,专业课
S000002,C000003,计算机网络,公共课
```

说明：
- 课程类型可省略，系统会自动识别
- 每行一条记录

## API接口

| 接口 | 方法 | 说明 |
|------|------|------|
| `/` | GET | 首页，展示样例数据 |
| `/import` | POST | 导入CSV数据 |
| `/search` | GET | 关键词检索 |
| `/filter` | GET | 按课程类型筛选 |
| `/api/import` | POST | API导入（JSON返回） |

## SQL统计查询

详见 [sql-queries.sql](sql-queries.sql)

### 题目1：统计每门课程选课人数（降序）
```sql
SELECT c.course_id, c.course_name, COUNT(e.student_id) AS enroll_count
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name
ORDER BY enroll_count DESC;
```

### 题目2：统计专业课选课人数超过50人的课程（升序）
```sql
SELECT c.course_id, c.course_name, COUNT(e.student_id) AS enroll_count
FROM courses c
INNER JOIN enrollments e ON c.course_id = e.course_id
WHERE c.course_type = '专业课'
GROUP BY c.course_id, c.course_name
HAVING COUNT(e.student_id) > 50
ORDER BY enroll_count ASC;
```

## 三题实现详解

### 第一题：Java基础处理工具

#### 需求
接收学生选课信息列表，实现去重、排序、输出三大核心功能。

#### 实现思路

1. **去重逻辑**
   - 规则：学生ID + 课程ID 完全一致视为重复记录
   - 实现：重写 `EnrollRecord` 类的 `equals()` 和 `hashCode()` 方法，基于 studentId 和 courseId 计算
   - 使用 `LinkedHashSet` 保持插入顺序的同时去除重复

2. **排序逻辑**
   - 规则：先按学生ID升序，学生ID相同时按课程ID升序
   - 实现：使用 Java 8 Stream API 的 `Comparator`
   ```java
   list.sort(Comparator.comparing(EnrollRecord::getStudentId)
           .thenComparing(EnrollRecord::getCourseId));
   ```

3. **输出格式**
   - 格式：`学生ID：XXX，课程ID：XXX，课程名称：XXX`
   - 实现：重写 `toString()` 方法

#### 核心代码

```java
// EnrollRecord.java - 去重实现
@Override
public boolean equals(Object o) {
    if (this == o) return true;
    EnrollRecord that = (EnrollRecord) o;
    return studentId.equals(that.studentId) && courseId.equals(that.courseId);
}

@Override
public int hashCode() {
    return 31 * studentId.hashCode() + courseId.hashCode();
}

// EnrollmentService.java - 处理流程
public List<EnrollRecord> processEnrollments(List<EnrollRecord> records) {
    // 1. 去重
    Set<EnrollRecord> deduplicatedSet = new LinkedHashSet<>(records);
    
    // 2. 排序
    List<EnrollRecord> sortedList = new ArrayList<>(deduplicatedSet);
    sortedList.sort(Comparator.comparing(EnrollRecord::getStudentId)
            .thenComparing(EnrollRecord::getCourseId));
    
    return sortedList;
}
```

---

### 第二题：SQL统计查询

#### 题目1：统计每门课程的选课人数（降序）

**需求**：返回课程ID、课程名称、选课人数（enroll_count），按选课人数降序排序

**实现**：
```sql
SELECT 
    c.course_id AS courseId,
    c.course_name AS courseName,
    COUNT(e.student_id) AS enroll_count
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name
ORDER BY enroll_count DESC;
```

**关键点**：
- 使用 `LEFT JOIN` 确保没有选课记录的课程也显示（人数为0）
- `GROUP BY` 按课程分组统计
- `COUNT(e.student_id)` 统计选课人数
- `ORDER BY enroll_count DESC` 按人数降序

---

**题目2：统计选课人数超过50人的专业课（升序）**

**需求**：返回课程ID、课程名称、选课人数，按选课人数升序排序

**实现**：
```sql
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
```

**关键点**：
- 使用 `INNER JOIN` 只统计有选课记录的课程
- `WHERE c.course_type = '专业课'` 筛选专业课
- `HAVING COUNT(e.student_id) > 50` 过滤选课人数超过50的课程
- `ORDER BY enroll_count ASC` 按人数升序

---

### 第三题：数据库设计与分析

#### 1. 核心数据模型（5张表）

| 表名 | 说明 | 关键字段 |
|------|------|----------|
| **students** | 学生表 | student_id(PK), student_name, student_major, student_grade |
| **teachers** | 教师表 | teacher_id(PK), teacher_name, department, teacher_title |
| **courses** | 课程表 | course_id(PK), course_name, course_type, capacity, teacher_id(FK) |
| **enrollments** | 选课记录表 | student_id(FK), course_id(FK), enroll_time, status |
| **course_schedules** | 开课计划表 | schedule_id(PK), course_id(FK), location, schedule_time |

#### 2. ER图（表间关联关系）

```
+-------------+         +---------------+         +-------------+
|  students  |         |  enrollments  |         |   courses   |
+-------------+         +---------------+         +-------------+
| PK student_id|-------->| FK student_id |         | PK course_id|
| student_name |        | FK course_id  |<--------| course_name |
| student_major|        | enroll_time   |         | course_type |
+-------------+        | status        |         | capacity    |
                       +---------------+         +-------------+
                                                      |
                                                      | FK
                                                      v
                                                +-------------+
                                                |  teachers   |
                                                +-------------+
                                                | PK teacher_id|
                                                | teacher_name |
                                                | department  |
                                                +-------------+
```

**关联关系说明**：
- `students 1--* enrollments`：一个学生可以选多门课程
- `enrollments *--1 courses`：一门课程可以被多个学生选择
- `courses *--1 teachers`：一门课程对应一个授课教师

#### 3. 并发风险与解决方案

**核心并发问题**：

| 问题 | 说明 |
|------|------|
| 超卖问题 | 多个学生同时选择同一课程，导致选课人数超过容量 |
| 数据不一致 | 并发更新导致选课状态不一致 |
| 重复选课 | 同一学生多次提交选课请求 |

**解决方案：乐观锁 + 事务控制 + 行级锁**

```sql
START TRANSACTION;

-- 1. 检查课程容量（使用行级锁 FOR UPDATE）
SELECT capacity, current_enrolled 
FROM course_schedules 
WHERE course_id = 'C000001' 
FOR UPDATE;

-- 2. 检查学生是否已选
SELECT COUNT(*) FROM enrollments 
WHERE student_id = 'S000001' AND course_id = 'C000001';

-- 3. 插入选课记录
INSERT INTO enrollments (student_id, course_id, enroll_time, status)
VALUES ('S000001', 'C000001', NOW(), '已选');

-- 4. 更新已选人数（乐观锁：检查当前人数未超容量）
UPDATE course_schedules 
SET current_enrolled = current_enrolled + 1 
WHERE course_id = 'C000001' 
  AND current_enrolled < capacity;

COMMIT;
```

#### 4. 索引设计

**选课记录表 (enrollments)**

| 索引名 | 索引类型 | 用途 |
|--------|----------|------|
| PRIMARY (student_id, course_id) | 复合主键 | 去重、联合查询 |
| idx_enrollments_student_id | 单列 | 查询学生选课记录 |
| idx_enrollments_course_id | 单列 | 统计课程选课人数 |
| idx_enrollments_enroll_time | 单列 | 按选课时间排序 |

**课程表 (courses)**

| 索引名 | 索引类型 | 用途 |
|--------|----------|------|
| PRIMARY (course_id) | 主键 | 主键索引 |
| idx_courses_type | 单列 | 按课程类型筛选 |
| idx_courses_teacher | 单列 | 按教师查询课程 |
| idx_courses_type_name | 组合 | 专业课统计查询 |

**索引设计理由**：
1. 选课记录表以(student_id, course_id)为主键，确保去重和联合查询效率
2. course_id索引支持按课程统计选课人数
3. course_type索引支持按课程类型筛选和统计
4. 组合索引优化多条件查询性能
