package com.example.enrollment;

import java.util.*;
import java.util.stream.Collectors;

class EnrollRecord {
    private String studentId;
    private String courseId;
    private String courseName;

    public EnrollRecord(String studentId, String courseId, String courseName) {
        this.studentId = studentId;
        this.courseId = courseId;
        this.courseName = courseName;
    }

    public String getStudentId() {
        return studentId;
    }

    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }

    public String getCourseId() {
        return courseId;
    }

    public void setCourseId(String courseId) {
        this.courseId = courseId;
    }

    public String getCourseName() {
        return courseName;
    }

    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    @Override
    public String toString() {
        return String.format("学生ID：%s，课程ID：%s，课程名称：%s", studentId, courseId, courseName);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        EnrollRecord that = (EnrollRecord) o;
        return Objects.equals(studentId, that.studentId) && Objects.equals(courseId, that.courseId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(studentId, courseId);
    }
}

public class EnrollmentProcessor {

    public static List<EnrollRecord> processEnrollments(List<EnrollRecord> records) {
        Set<EnrollRecord> deduplicatedSet = new LinkedHashSet<>(records);

        List<EnrollRecord> sortedList = new ArrayList<>(deduplicatedSet);
        sortedList.sort(Comparator.comparing(EnrollRecord::getStudentId)
                .thenComparing(EnrollRecord::getCourseId));

        return sortedList;
    }

    public static void main(String[] args) {
        List<EnrollRecord> testRecords = Arrays.asList(
            new EnrollRecord("S000002", "C000003", "计算机网络"),
            new EnrollRecord("S000001", "C000001", "Java程序设计"),
            new EnrollRecord("S000001", "C000001", "Java程序设计"),
            new EnrollRecord("S000003", "C000002", "数据结构"),
            new EnrollRecord("S000001", "C000002", "数据结构"),
            new EnrollRecord("S000002", "C000001", "Java程序设计")
        );

        List<EnrollRecord> result = processEnrollments(testRecords);

        System.out.println("处理后的选课记录：");
        for (EnrollRecord record : result) {
            System.out.println(record);
        }
    }
}
