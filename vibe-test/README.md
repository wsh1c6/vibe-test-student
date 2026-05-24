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
