package com.group.smartserve.repository;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;
import com.group.smartserve.helper.QRCodeGenerator;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.io.ByteArrayInputStream;
import java.util.*;
import java.util.stream.Collectors;

@Repository
public class OrderRepository {

    @Autowired
    JdbcTemplate jdbcTemplate;
    @Autowired
    JavaMailSender javaMailSender;
    @Autowired
    RestaurantRepository restaurantRepository;
//   / Modify insertOrder to pass JSON array
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
    public int insertOrder(int user_id, int restaurant_id, String order_date,int number_of_people, Map<String, Map<String, Object>> cartItems) {
        String cartItemsJson = new Gson().toJson(cartItems); // Convert cart items to JSON

        int totalQuantity = 0;
        int totalAmount = 0;

        for (Map<String, Object> item : cartItems.values()) {
            int quantity = (int) item.get("quantity");
            int price = (int) item.get("price");

            totalQuantity += quantity;
            totalAmount += (quantity * price);
        }

        System.out.println("Total Quantity: " + totalQuantity);
        System.out.println("Total Amount: " + totalAmount);
        System.out.println("Sending JSON: " + cartItemsJson);

        Integer orderId = jdbcTemplate.queryForObject(
                "DECLARE @result INT; EXEC @result = InsertOrderAndDetails ?, ?, ?, ?, ?, ?, ?; SELECT @result;",
                Integer.class,
                user_id, restaurant_id, order_date, "Pending", totalQuantity, totalAmount, convertCartItemsToJson(cartItems)
        );

        if (orderId == null || orderId == -1) {
            throw new RuntimeException("Order insertion failed!");
        }

        return orderId;
    }

//    private String convertCartItemsToJson(Map<String, Map<String, Object>> cartItems) {
//        List<Map<String, Object>> cartList = new ArrayList<>();
//
//        for (Map.Entry<String, Map<String, Object>> entry : cartItems.entrySet()) {
//            Map<String, Object> item = new HashMap<>();
//            item.put("item_id", Integer.parseInt(entry.getKey()));  // Convert key to int
//            item.put("quantity", entry.getValue().get("quantity"));
//            item.put("price", entry.getValue().get("price"));
//            cartList.add(item);
//        }
//
//        return new Gson().toJson(cartList);  // Convert list to JSON array
//    }

    // Helper method to convert cartItems Map to JSON string
    public int updateStatus(int orderId, String status){
        if (status.equals("Delivered")){
//            fetch user details and send a mail that order is delivered
            Map<String,Object> order = jdbcTemplate.queryForMap("SELECT * FROM orders WHERE order_id = ?", orderId);
            int userId = (int) order.get("user_id");
            Map<String,Object> user = jdbcTemplate.queryForMap("SELECT * FROM users WHERE user_id = ?", userId);
            String email = (String) user.get("user_email");
            System.out.println(email);
            // Send email to email
try {
                MimeMessage message = javaMailSender.createMimeMessage();
                MimeMessageHelper helper = new MimeMessageHelper(message, true);
                helper.setTo(email);
                helper.setSubject("Order Delivered");
                helper.setText("Your order has been delivered. Thank you for choosing us.");
                byte[] qrCodeImage = generateBill(String.valueOf(orderId));
// Attach QR Code
    helper.addAttachment("QRCode.png", () -> new ByteArrayInputStream(qrCodeImage));

                javaMailSender.send(message);
    System.out.println("Mail sent");
            } catch (Exception e) {
                e.printStackTrace();
            }


        }
//        jdbcTemplate.update("UPDATE queries SET status = 'Completed' WHERE order_id = ?", orderId);
        return jdbcTemplate.update("UPDATE orders SET order_status = ? WHERE order_id = ?", status, orderId);
    }
    public byte[] generateBill(String billId) {
        String qrCodeData = "http://localhost:5173/feedback/"+billId;
        try {
            byte[] qrCodeImage = QRCodeGenerator.generateQRCodeImage(qrCodeData, 200, 200);
            String base64Image = Base64.getEncoder().encodeToString(qrCodeImage);

            // Save bill and other details in the database
            return  qrCodeImage;
        } catch (Exception e) {
            return null;
        }
    }
    public List<Map<String,Object>> getUserOrders(String token){
        String sql = "SELECT \n" +
                "    o.order_id, \n" +
                "    o.restaurant_id, \n" +
                "    o.order_date, \n" +
                "    o.order_status, \n" +
                "    o.quantity, \n" +
                "    o.total_amount, \n" +
                "    o.query_id,\n" +
                "    u.user_id,\n" +
                "    u.full_name,\n" +
                "    u.user_phone,\n" +
                "    u.user_email,\n" +
                "    (\n" +
                "        SELECT \n" +
                "            od.order_detail_id, \n" +
                "            r.item_id, \n" +
                "            r.item_name, \n" +
                "            r.price, \n" +
                "            r.veg_nonveg, \n" +
                "            r.item_image\n" +
                "        FROM order_details od \n" +
                "        INNER JOIN restaurant_menu_items r ON r.item_id = od.item_id \n" +
                "        WHERE od.order_id = o.order_id\n" +
                "        FOR JSON PATH\n" +
                "    ) AS items\n" +
                "FROM users u \n" +
                "JOIN orders o ON u.user_id = o.user_id \n" +
                "WHERE u.token = ? \n" +
                "ORDER BY o.order_id DESC;\n";
        return jdbcTemplate.queryForList(sql, token);

    }
    public Map<String,Object> getOrderDetails(int orderId){
        return jdbcTemplate.queryForMap("EXEC sp_get_order_details ?", orderId);
    }

        public ResponseEntity<Map<String,Object>> sendQueriesToAll(Map<String,Object> body) {
        List<Map<String, Object>> res = restaurantRepository.getRestaurants();
        String sql = "EXEC sp_InsertQuery ?,?,?,?,?,?,?,?,? ";
        jdbcTemplate.update(sql , body.get("user_id"), body.get("foodType"), body.get("occasion"), body.get("people"), body.get("foodItems"), body.get("budget"), body.get("eventDate"), body.get("eventTime"), body.get("additionalInfo"));
        return ResponseEntity.ok(Map.of("status", "successful", "restaurants", res));
    }
    public int decideQuery(Map<String, Object> body) {
        String sql = "EXEC sp_DecideQuery ?,?";
        int res = jdbcTemplate.update(sql, body.get("queryId"), body.get("decision"));
        System.out.println(res);
        return 1;
    }
    public List<Map<String, Object>> getQueries(int restaurant_id) {
        String sql = "exec sp_GetQueriesForRestaurant ?";

        System.out.println(jdbcTemplate.queryForList(sql,restaurant_id));
        return jdbcTemplate.queryForList(sql,restaurant_id);
    }
    public List<Map<String, Object>> getUserQueries(int user_id) {
        String sql = "exec sp_GetQueriesForUser ?";

        System.out.println(jdbcTemplate.queryForList(sql,user_id));
        return jdbcTemplate.queryForList(sql,user_id);
    }
}
