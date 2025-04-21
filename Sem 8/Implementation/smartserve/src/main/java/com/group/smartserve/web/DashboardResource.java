package com.group.smartserve.web;

import com.group.smartserve.service.DashboardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
@CrossOrigin(origins = {"http://localhost:5173", "http://192.168.2.102:5173/", "http://localhost:3001"}, allowCredentials = "true")

@RestController
@RequestMapping("/api/restaurant")
public class DashboardResource {
    @Autowired
    JdbcTemplate jdbcTemplate;
@GetMapping("/feedback-stats/{restaurant_id}")
public List<Map<String,Object>> getFeedbackStats(@PathVariable int restaurant_id)
{
    String sql = "SELECT \n" +
            "    mi.item_id,\n" +
            "    mi.item_name AS dishName,\n" +
            "    COALESCE(AVG(CAST(df.rating AS FLOAT)), 0) AS averageRating\n" +
            "FROM restaurant_menu_items mi\n" +
            "LEFT JOIN order_details od ON mi.item_id = od.item_id\n" +
            "LEFT JOIN dish_feedback df ON od.order_detail_id = df.order_detail_id\n" +
            "WHERE mi.restaurant_id = ?\n" +
            "GROUP BY mi.item_id, mi.item_name\n" +
            "ORDER BY averageRating DESC;\n";
    return jdbcTemplate.queryForList(sql,restaurant_id);
}

@GetMapping("/top-dishes/{restaurant_id}")
public List<Map<String,Object>> getTopDishes(@PathVariable int restaurant_id)
{
    String sql = "SELECT \n" +
            "    mi.item_id,\n" +
            "    mi.item_name AS dishName,\n" +
            "    COUNT(od.order_detail_id) AS orderCount\n" +
            "FROM restaurant_menu_items mi\n" +
            "JOIN order_details od ON mi.item_id = od.item_id\n" +
            "WHERE mi.restaurant_id = ?\n" +
            "GROUP BY mi.item_id, mi.item_name\n" +
            "ORDER BY orderCount DESC;\n";
    return jdbcTemplate.queryForList(sql,restaurant_id);
}


@GetMapping("/recent-feedback/{restaurant_id}")
public List<Map<String,Object>> getRecentFeedback(@PathVariable int restaurant_id)
{
    String sql = "SELECT TOP 10 \n" +
            "    df.feedback_id,\n" +
            "    mi.item_name AS dishName,\n" +
            "    df.rating,\n" +
            "    df.comments,\n" +
            "    df.created_at\n" +
            "FROM dish_feedback df\n" +
            "JOIN order_details od ON df.order_detail_id = od.order_detail_id\n" +
            "JOIN restaurant_menu_items mi ON od.item_id = mi.item_id\n" +
            "WHERE mi.restaurant_id = ? \n" +
            "ORDER BY df.created_at DESC;\n ";

    return jdbcTemplate.queryForList(sql,restaurant_id);
}
@GetMapping("/customers/{restaurant_id}")
public List<Map<String,Object>> getCustomers(@PathVariable int restaurant_id)
{
    String sql = "SELECT u.full_name, o.restaurant_id, o.customer_count\n" +
            "FROM users u\n" +
            "INNER JOIN (\n" +
            "    SELECT user_id, restaurant_id, COUNT(*) AS customer_count\n" +
            "    FROM orders\n" +
            "    GROUP BY user_id, restaurant_id\n" +
            ") o ON u.user_id = o.user_id\n WHERE o.restaurant_id = ?  " +

            "ORDER BY o.customer_count DESC;\n";

    return jdbcTemplate.queryForList(sql,restaurant_id);
}

}
