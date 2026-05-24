package com.example.enrollment.service;

import com.example.enrollment.entity.EnrollRecord;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class EnrollmentService {

    private static final Map<String, String> COURSE_TYPE_MAP = new HashMap<>();

    static {
        COURSE_TYPE_MAP.put("Java程序设计", "专业课");
        COURSE_TYPE_MAP.put("数据结构", "专业课");
        COURSE_TYPE_MAP.put("计算机网络", "公共课");
        COURSE_TYPE_MAP.put("高等数学", "公共课");
        COURSE_TYPE_MAP.put("线性代数", "公共课");
        COURSE_TYPE_MAP.put("操作系统", "专业课");
        COURSE_TYPE_MAP.put("数据库原理", "专业课");
        COURSE_TYPE_MAP.put("软件工程", "专业课");
    }

    public List<EnrollRecord> processEnrollments(List<EnrollRecord> records) {
        Set<EnrollRecord> deduplicatedSet = new LinkedHashSet<>(records);

        for (EnrollRecord record : deduplicatedSet) {
            if (record.getCourseType() == null || record.getCourseType().isEmpty()) {
                record.setCourseType(determineCourseType(record.getCourseName()));
            }
        }

        List<EnrollRecord> sortedList = new ArrayList<>(deduplicatedSet);
        sortedList.sort(Comparator.comparing(EnrollRecord::getStudentId)
                .thenComparing(EnrollRecord::getCourseId));

        return sortedList;
    }

    public String determineCourseType(String courseName) {
        return COURSE_TYPE_MAP.getOrDefault(courseName, "选修课");
    }

    public List<EnrollRecord> searchRecords(List<EnrollRecord> records, String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return records;
        }

        String lowerKeyword = keyword.toLowerCase().trim();

        return records.stream()
                .filter(record -> matchesKeyword(record, lowerKeyword))
                .collect(Collectors.toList());
    }

    private boolean matchesKeyword(EnrollRecord record, String keyword) {
        return (record.getStudentId() != null && record.getStudentId().toLowerCase().contains(keyword))
                || (record.getCourseId() != null && record.getCourseId().toLowerCase().contains(keyword))
                || (record.getCourseName() != null && record.getCourseName().toLowerCase().contains(keyword))
                || (record.getCourseType() != null && record.getCourseType().toLowerCase().contains(keyword));
    }

    public List<EnrollRecord> parseCsvData(String csvData) {
        List<EnrollRecord> records = new ArrayList<>();
        if (csvData == null || csvData.trim().isEmpty()) {
            return records;
        }

        String[] lines = csvData.trim().split("\n");
        for (String line : lines) {
            String[] parts = line.trim().split(",");
            if (parts.length >= 3) {
                String studentId = parts[0].trim();
                String courseId = parts[1].trim();
                String courseName = parts[2].trim();
                String courseType = parts.length > 3 ? parts[3].trim() : determineCourseType(courseName);

                EnrollRecord record = new EnrollRecord(studentId, courseId, courseName, courseType);
                records.add(record);
            }
        }
        return records;
    }

    public List<EnrollRecord> getSampleData() {
        List<EnrollRecord> samples = Arrays.asList(
            new EnrollRecord("S000001", "C000001", "Java程序设计", "专业课"),
            new EnrollRecord("S000001", "C000002", "数据结构", "专业课"),
            new EnrollRecord("S000002", "C000001", "Java程序设计", "专业课"),
            new EnrollRecord("S000002", "C000003", "计算机网络", "公共课"),
            new EnrollRecord("S000003", "C000002", "数据结构", "专业课"),
            new EnrollRecord("S000003", "C000004", "高等数学", "公共课"),
            new EnrollRecord("S000004", "C000003", "计算机网络", "公共课"),
            new EnrollRecord("S000004", "C000005", "线性代数", "公共课"),
            new EnrollRecord("S000005", "C000001", "Java程序设计", "专业课"),
            new EnrollRecord("S000005", "C000006", "操作系统", "专业课")
        );
        return processEnrollments(samples);
    }
}
