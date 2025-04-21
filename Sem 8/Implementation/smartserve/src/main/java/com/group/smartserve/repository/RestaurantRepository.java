package com.group.smartserve.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.*;

@Repository
public class RestaurantRepository {

    @Autowired
    JdbcTemplate jdbcTemplate;
    public List<Map<String,Object>> getRestaurants()
    {
        return jdbcTemplate.queryForList("EXEC sp_get_restaurants");
    }
    public Map<String,Object> getRestaurantDetails(int restaurantId)
    {
        return jdbcTemplate.queryForMap("EXEC sp_fetch_restaurant_details ?", restaurantId);
    }
    public List<Map<String, Object>> getRestaurantMenu(Long restaurantId) {
        return jdbcTemplate.queryForList("EXEC sp_get_restaurant_menu ?", restaurantId);
    }
    public List<Map<String, Object>> getFoodList(int user_id) {
            return jdbcTemplate.queryForList("SELECT * FROM restaurants r INNER JOIN restaurant_menu_items rm ON r.restaurant_id = rm.restaurant_id where user_id =  ?", user_id);
    }
    public List<Map<String, Object>> getOrderList(int user_id) {
        try {
            // Fetch restaurant_id
            Integer restaurantId = jdbcTemplate.queryForObject(
                    "SELECT restaurant_id FROM restaurants WHERE user_id = ?",
                    Integer.class,
                    user_id
            );

            // If no restaurant_id is found, return an empty list
            if (restaurantId == null) {
                return Collections.emptyList();
            }

            // Fetch orders with details
            String sql = "SELECT " +
                    "    o.order_id, " +
                    "    o.user_id, " +
                    "    u.full_name, " +
                    "    u.user_phone, " +
                    "    u.user_email, " +
                    "    o.restaurant_id, " +
                    "    o.order_date, " +
                    "    o.order_status, " +
                    "    o.quantity AS total_quantity, " +
                    "    o.total_amount, " +
                    "    r.restaurant_name, " +
                    "    od.item_id, " +
                    "    mi.item_name, " +
                    "    od.quantity, " +
                    "    od.price " +
                    "FROM " +
                    "    orders o " +
                    "JOIN " +
                    "    restaurants r ON o.restaurant_id = r.restaurant_id " +
                    "JOIN " +
                    "    users u ON o.user_id = u.user_id " +
                    "JOIN " +
                    "    order_details od ON o.order_id = od.order_id " +
                    "JOIN " +
                    "    restaurant_menu_items mi ON od.item_id = mi.item_id " +
                    "WHERE " +
                    "    o.order_status NOT LIKE 'Delivered' " +
                    "    AND o.restaurant_id = ? " +
                    "ORDER BY o.order_date";

            List<Map<String, Object>> orderDetails = jdbcTemplate.queryForList(sql, restaurantId);

            // Process the result to create a nested JSON structure
            Map<Integer, Map<String, Object>> ordersMap = new LinkedHashMap<>();

            for (Map<String, Object> row : orderDetails) {
                int orderId = (int) row.get("order_id");

                // If this order is not in the map, add it
                ordersMap.putIfAbsent(orderId, new LinkedHashMap<>(row));

                // Remove fields that should be inside order_details
                Map<String, Object> order = ordersMap.get(orderId);
                order.put("order_details", order.getOrDefault("order_details", new ArrayList<Map<String, Object>>()));

                // Create order details entry
                Map<String, Object> orderDetail = new LinkedHashMap<>();
                orderDetail.put("item_id", row.get("item_id"));
                orderDetail.put("item_name", row.get("item_name"));
                orderDetail.put("quantity", row.get("quantity"));
                orderDetail.put("price", row.get("price"));

                // Add order detail to the list
                ((List<Map<String, Object>>) order.get("order_details")).add(orderDetail);
            }

            // Convert map values to list
            return new ArrayList<>(ordersMap.values());

        } catch (Exception e) {
            // Log the error and return an empty list
            System.err.println("Error fetching order list: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    public ResponseEntity<Map<String, Object>> addFood(String name , int price , int user_id , int category, String description) {
        int res = jdbcTemplate.update("Exec AddMenuItem ?,?,?,?,?",user_id,name,description,price,category);
        if (res>0)
        {
            return ResponseEntity.ok().body(Map.of("status","successful"));
        }
        return ResponseEntity.status(HttpStatus.NOT_ACCEPTABLE).body(Map.of("status","Unsuccessful"));

    }
}
