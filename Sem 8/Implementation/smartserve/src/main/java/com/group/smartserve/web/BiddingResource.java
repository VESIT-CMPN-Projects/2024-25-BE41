package com.group.smartserve.web;

import com.group.smartserve.service.BiddingService;
import com.group.smartserve.service.FeedbackService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RequestMapping("/api/bids")
@RestController
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:3001" , "http://192.168.2.102:5173/"}, allowCredentials = "true")

public class BiddingResource {
    @Autowired
    BiddingService bidService;

    @PostMapping("/submit")
    public ResponseEntity<Map<String, Object>> submitBid(@RequestBody Map<String, Object> bidData) {
        boolean isSaved = bidService.saveBid(bidData);
        Map<String, Object> response = new HashMap<>();
        response.put("message", isSaved ? "Bid submitted successfully!" : "Failed to submit bid");

        return ResponseEntity.ok(response);
    }

    @GetMapping("/select-best/{queryId}")
    public ResponseEntity<Map<String, Object>> selectBestBid(@PathVariable String queryId) {
        Map<String, Object> bestBid = bidService.selectBestBid(queryId);
        if (bestBid == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "No bids found for this order"));
        }
        return ResponseEntity.ok(bestBid);
    }
    @GetMapping("/queries")
    public List<Map<String, Object>> getQueries() {
        return bidService.getQueries();
    }

}
