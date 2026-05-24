# 高校选课管理系统

基于Spring Boot 3.x框架开发的高校选课管理系统，提供学生选课数据处理功能。
使用trae的minimax-M2.5模型
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
