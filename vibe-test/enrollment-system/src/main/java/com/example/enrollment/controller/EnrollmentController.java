package com.example.enrollment.controller;

import com.example.enrollment.entity.EnrollRecord;
import com.example.enrollment.service.EnrollmentService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
public class EnrollmentController {

    private final EnrollmentService enrollmentService;

    public EnrollmentController(EnrollmentService enrollmentService) {
        this.enrollmentService = enrollmentService;
    }

    @GetMapping("/")
    public String index(Model model) {
        List<EnrollRecord> sampleData = enrollmentService.getSampleData();
        model.addAttribute("records", sampleData);
        model.addAttribute("searchKeyword", "");
        return "index";
    }

    @PostMapping("/import")
    public String importData(@RequestParam String csvData, Model model) {
        List<EnrollRecord> parsedRecords = enrollmentService.parseCsvData(csvData);
        List<EnrollRecord> processedRecords = enrollmentService.processEnrollments(parsedRecords);

        model.addAttribute("records", processedRecords);
        model.addAttribute("csvData", csvData);
        model.addAttribute("searchKeyword", "");

        return "index";
    }

    @GetMapping("/search")
    public String search(@RequestParam String keyword, Model model) {
        List<EnrollRecord> sampleData = enrollmentService.getSampleData();
        List<EnrollRecord> searchResults = enrollmentService.searchRecords(sampleData, keyword);

        model.addAttribute("records", searchResults);
        model.addAttribute("searchKeyword", keyword);

        if (searchResults.isEmpty()) {
            model.addAttribute("message", "无匹配选课记录");
        }

        return "index";
    }

    @GetMapping("/filter")
    public String filterByType(@RequestParam String courseType, Model model) {
        List<EnrollRecord> allRecords = enrollmentService.getSampleData();
        List<EnrollRecord> filteredRecords;

        if (courseType == null || courseType.isEmpty() || courseType.equals("all")) {
            filteredRecords = allRecords;
        } else {
            filteredRecords = allRecords.stream()
                    .filter(r -> courseType.equals(r.getCourseType()))
                    .collect(java.util.stream.Collectors.toList());
        }

        model.addAttribute("records", filteredRecords);
        model.addAttribute("filterType", courseType);
        model.addAttribute("searchKeyword", "");

        return "index";
    }

    @ResponseBody
    @PostMapping("/api/import")
    public List<EnrollRecord> importApi(@RequestBody String csvData) {
        List<EnrollRecord> parsedRecords = enrollmentService.parseCsvData(csvData);
        return enrollmentService.processEnrollments(parsedRecords);
    }
}
