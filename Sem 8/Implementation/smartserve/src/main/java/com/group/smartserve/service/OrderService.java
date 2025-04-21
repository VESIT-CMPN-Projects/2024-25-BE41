package com.group.smartserve.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.group.smartserve.repository.OrderRepository;
import com.group.smartserve.repository.RestaurantRepository;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.io.ByteArrayInputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Service
public class OrderService {
    @Autowired
    OrderRepository orderRepository;
    @Autowired
    RestaurantRepository restaurantRepository;
    @Autowired
    JavaMailSender javaMailSender;

    public ResponseEntity<Map<String, Object>> sendQuery(Map<String, Object> body) {
        try {
            int user_id = (int) body.get("user_id");
            int restaurant_id = (int) body.get("restaurant_id");
            String order_date = (String) body.get("order_date");

            // Handle number_of_people properly
            int number_of_people;
            if (body.get("number_of_people") instanceof Integer) {
                number_of_people = (Integer) body.get("number_of_people");
            } else if (body.get("number_of_people") instanceof String) {
                number_of_people = Integer.parseInt((String) body.get("number_of_people"));
            } else {
                number_of_people = 0;
            }

            String order_time = (String) body.get("event_time");

            // Convert cart_items to a JSON array
            Map<String, Map<String, Object>> cartItems = (Map<String, Map<String, Object>>) body.get("cart_items");
            String cartItemsJson = convertCartItemsToJson(cartItems);

            System.out.println("Converted Cart JSON: " + cartItemsJson);

            // Call stored procedure
            int res = orderRepository.insertOrder(user_id, restaurant_id, order_date, number_of_people, cartItems);
            System.out.println(res);
            if (res > 0)
                return ResponseEntity.ok(Map.of("status", "successful"));

            return ResponseEntity.badRequest().body(Map.of("status", "Unsuccessful"));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("status", "error", "message", e.getMessage()));
        }
    }
    private String convertCartItemsToJson(Map<String, Map<String, Object>> cartItems) {
        try {
            List<Map<String, Object>> cartItemsList = cartItems.entrySet()
                    .stream()
                    .map(entry -> {
                        Map<String, Object> item = new HashMap<>(entry.getValue());
                        item.put("item_id", Integer.parseInt(entry.getKey())); // Add item_id field
                        return item;
                    })
                    .collect(Collectors.toList());

            ObjectMapper objectMapper = new ObjectMapper();
            return objectMapper.writeValueAsString(cartItemsList);
        } catch (Exception e) {
            e.printStackTrace();
            return "[]"; // Return empty JSON array on failure
        }
    }
    public ResponseEntity<Map<String,Object>> updateStatus(Map<String,Object> body){
        int orderId = (int) body.get("orderId");
        String status = (String) body.get("status");
        int res = orderRepository.updateStatus(orderId,status);
        if(res>0){
            return ResponseEntity.ok(Map.of("status","successful"));
        }
        return ResponseEntity.badRequest().body(Map.of("status","Unsuccessful"));
    }

    public ResponseEntity<Map<String,Object>> getUserOrders(String token){
        List<Map<String,Object>> orders = orderRepository.getUserOrders(token);
        if(orders.size()>0){
            return ResponseEntity.ok(Map.of("status","successful","orders",orders));
        }
        return ResponseEntity.badRequest().body(Map.of("status","Unsuccessful"));
    }
    public ResponseEntity<Map<String, Object>> sendQueriestoAll(Map<String, Object> body) {
        // Send the queries and return the response immediately
        ResponseEntity<Map<String, Object>> response = orderRepository.sendQueriesToAll(body);

        // Execute foo asynchronously after returning the response
        CompletableFuture.runAsync(() -> foo(body));

        return response;
    }

    public void foo(Map<String,Object > body){
        List<Map<String,Object>> res= restaurantRepository.getRestaurants();
//        get all email ids and send the information of the body to all via mail
        for (Map<String, Object> re : res) {
            String email = (String) re.get("user_email");
            System.out.println(email);
            sendMail(email,body);

        }
    }
    public void sendMail(String email, Map<String, Object> body) {
        try {
            MimeMessage message = javaMailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true);
            helper.setTo(email);
            helper.setSubject("Restaurant Order Query");
            String bidLink = "https://yourdomain.com/bid/submit?orderId=" + body.get("orderId");
            // Formatting the email properly using HTML
            String emailContent = "<html><body>"
                    + "<h2>New Restaurant Query</h2>"
                    + "<p><strong>Food Type:</strong> " + body.get("foodType") + "</p>"
                    + "<p><strong>Occasion:</strong> " + body.get("occasion") + "</p>"
                    + "<p><strong>Event date:</strong> " + body.get("eventDate") + "</p>"
                    + "<p><strong>Event Time:</strong> " + body.get("eventTime") + "</p>"
                    + "<p><strong>Number of People:</strong> " + body.get("people") + "</p>"
                    + "<p><strong>Food Items:</strong> " + body.get("foodItems") + "</p>"
                    + "<p><strong>Budget:</strong> ₹" + body.get("budget") + "</p>"
                    + "<p><strong>Additional Info:</strong> " + body.get("additionalInfo") + "</p>"
                    + "<br>"
                    + "<h3>User Details</h3>"
                    + "<p><strong>Name:</strong> " + ((Map<?, ?>) body.get("userData")).get("full_name") + "</p>"
                    + "<p><strong>Phone:</strong> " + ((Map<?, ?>) body.get("userData")).get("user_phone") + "</p>"
                    + "<p><strong>Email:</strong> " + ((Map<?, ?>) body.get("userData")).get("user_email") + "</p>"
                    + "<br>"
                    +"<p><a href='" + bidLink + "' style='color:blue; font-size:16px;'>Click here to submit your bid</a></p>"
                    + "</body></html>";

            helper.setText(emailContent, true); // Enable HTML content
            javaMailSender.send(message);
            System.out.println("Mail sent to " + email);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public Map<String,Object> getOrderDetails(int orderId){
        return orderRepository.getOrderDetails(orderId);
    }
    public ResponseEntity<Map<String, Object>> decideQuery(Map<String, Object> body) {
        int queryId = (int) body.get("queryId");
        String decision = (String) body.get("decision");

        int res= orderRepository.decideQuery(body);
        if(res>0){
            return ResponseEntity.ok(Map.of("status","successful"));
        }
        return ResponseEntity.badRequest().body(Map.of("status","Unsuccessful"));

//        }
    }
    public List<Map<String,Object>> getQueries(int restaurant_id){
        return orderRepository.getQueries(restaurant_id);
    }
    public List<Map<String,Object>> getUserQueries(int user_id){
        return orderRepository.getUserQueries(user_id);
    }

}
