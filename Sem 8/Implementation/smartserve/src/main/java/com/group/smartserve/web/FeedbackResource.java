package com.group.smartserve.web;

import com.group.smartserve.service.FeedbackService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RequestMapping("/api/feedback/")
@RestController
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:3001" , "http://192.168.2.102:5173/"}, allowCredentials = "true")

public class FeedbackResource {
    @Autowired
    FeedbackService feedbackService;

    @PostMapping("submitFeedback")
    public ResponseEntity<Map<String,Object>> submitFeedback(@RequestBody Map<String,Object> feedbackData){
        return  feedbackService.submitFeedback(feedbackData);
    }


    private String generateCustomFeedback(int hygiene, int packaging, int quality) {
        int avgRating = (hygiene + packaging + quality) / 3;
        return switch (avgRating) {
            case 5 -> "Outstanding restaurant experience!";
            case 4 -> "Great experience overall.";
            case 3 -> "Satisfactory, but could be better.";
            case 2 -> "Needs improvement in service.";
            case 1 -> "Poor experience, not recommended.";
            default -> "No feedback available.";
        };
    }
}
