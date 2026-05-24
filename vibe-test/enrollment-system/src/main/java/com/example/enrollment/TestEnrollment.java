package com.example.enrollment;

import java.util.*;

class EnrollRecord {
    private String studentId;
    private String courseId;
    private String courseName;

    public EnrollRecord(String studentId, String courseId, String courseName) {
        this.studentId = studentId;
        this.courseId = courseId;
        this.courseName = courseName;
    }

    public String getStudentId() { return studentId; }
    public String getCourseId() { return courseId; }
    public String getCourseName() { return courseName; }

    @Override
    public String toString() {
        return String.format("StudentID: %s, CourseID: %s, CourseName: %s", studentId, courseId, courseName);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        EnrollRecord that = (EnrollRecord) o;
        return studentId.equals(that.studentId) && courseId.equals(that.courseId);
    }

    @Override
    public int hashCode() {
        return 31 * studentId.hashCode() + courseId.hashCode();
    }
}

public class TestEnrollment {
    public static void main(String[] args) {
        List<EnrollRecord> input = Arrays.asList(
            new EnrollRecord("S000001", "C000001", "Java"),
            new EnrollRecord("S000002", "C000003", "Network"),
            new EnrollRecord("S000001", "C000001", "Java"),
            new EnrollRecord("S000001", "C000002", "Database"),
            new EnrollRecord("S000003", "C000001", "Java")
        );

        System.out.println("========== Original Data ==========");
        for (EnrollRecord r : input) {
            System.out.println(r);
        }

        Set<EnrollRecord> deduplicated = new LinkedHashSet<>(input);
        List<EnrollRecord> result = new ArrayList<>(deduplicated);
        result.sort(Comparator.comparing(EnrollRecord::getStudentId)
                        .thenComparing(EnrollRecord::getCourseId));

        System.out.println("\n========== After Deduplication & Sorting ==========");
        for (EnrollRecord r : result) {
            System.out.println(r);
        }

        System.out.println("\n========== Test Result ==========");
        System.out.println("Original count: " + input.size());
        System.out.println("After deduplication: " + result.size());
        System.out.println("Expected: 4 records (S000001,C000001 duplicated)");
        System.out.println("Test " + (result.size() == 4 ? "PASSED" : "FAILED"));
    }
}
