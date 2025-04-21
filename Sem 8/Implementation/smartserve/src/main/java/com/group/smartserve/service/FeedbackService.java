package com.group.smartserve.service;

import com.group.smartserve.repository.FeedbackRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.List;
import java.util.Map;

@Service
public class FeedbackService {
    @Autowired
    FeedbackRepository feedbackRepository;


    public ResponseEntity<Map<String,Object>> submitFeedback(@RequestBody Map<String,Object> feedbackData)
    {Integer orderId = Integer.parseInt(feedbackData.get("order_id").toString());

        // Insert into Dish Feedback Table
        List<Map<String, Object>> feedbackItems = (List<Map<String, Object>>) feedbackData.get("feedback_items");
        for (Map<String, Object> item : feedbackItems) {
            Integer order_detail_id = Integer.parseInt(item.get("item_id").toString());
            int rating = Integer.parseInt(item.get("rating").toString());

            String comment = switch (rating) {
                case 5 -> "Excellent";
                case 4 -> "Good";
                case 3 -> "Average";
                case 2 -> "Below Average";
                case 1 -> "Poor";
                default -> "No Rating";
            };

//            DishFeedback dishFeedback = new DishFeedback(orderId, itemId, rating, comment);
//            dishFeedbackRepository.save(dishFeedback);
//            sp for addin dis feedback
            int res = feedbackRepository.addDishFeedback(orderId,order_detail_id,rating,comment);
            System.out.println(res +"dish feedback");
        }

        // Insert into Restaurant Feedback Table
        Map<String, Object> restaurantFeedback = (Map<String, Object>) feedbackData.get("restaurant_feedback");
        int restaurant_id = Integer.parseInt(feedbackData.get("restaurant_id").toString());
        int hygiene = Integer.parseInt(restaurantFeedback.get("hygiene").toString());
        int packaging = Integer.parseInt(restaurantFeedback.get("packaging").toString());
        int quality = Integer.parseInt(restaurantFeedback.get("quality").toString());
        int deliveredOnTime = Integer.parseInt(restaurantFeedback.get("deliveredOnTime").toString());
        String experience = restaurantFeedback.get("experience").toString();

        // Generate custom feedback if qualitative_feedback is not provided
        String qualitativeFeedback = feedbackData.get("qualitative_feedback").toString()
                + generateCustomFeedback(hygiene, packaging, quality) + (experience.equals("1")?" Good Experience":"Bad Experience");
//
//        RestaurantFeedback restaurantFeedbackEntity = new RestaurantFeedback(
//                orderId, hygiene, packaging, quality, deliveredOnTime, experience, qualitativeFeedback
//        );
//        restaurantFeedbackRepository.save(restaurantFeedbackEntity);
         int res = feedbackRepository.addRestaurantFeedback(restaurant_id,hygiene,packaging,quality,deliveredOnTime,qualitativeFeedback);
        System.out.println("res2"+res);
        if (res>0)
        {
            return ResponseEntity.ok().body(Map.of("status","successful"));
        }
        return  ResponseEntity.status(HttpStatus.NOT_ACCEPTABLE).body(Map.of("status","Unsuccessful"));
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
