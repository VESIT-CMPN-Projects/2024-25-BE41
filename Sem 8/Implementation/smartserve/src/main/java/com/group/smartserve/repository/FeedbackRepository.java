package com.group.smartserve.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class FeedbackRepository {
    @Autowired
    JdbcTemplate jdbcTemplate;
    public int addDishFeedback(int orderId,int order_detail_id,int rating,String comment){
        String sql = "INSERT INTO dish_feedback  (order_detail_id,rating,comments) values (? ,?,?)";
        return jdbcTemplate.update(sql,order_detail_id,rating,comment);
    }
    public int addRestaurantFeedback(int restaurant_id,int hygiene,int packaging, int quality,int deliveredOnTime,String qualitativeFeedback){
        String sql = "INSERT INTO restaurant_feedback ([restaurant_id] ,[hygiene]\n" +
                "           ,[packaging]\n" +
                "           ,[quality]\n" +
                "           ,[delivered_on_time]\n" +
                "           ,[comments]) VALUES (?,?,?,?,?,?) ";
        return jdbcTemplate.update(sql,restaurant_id,hygiene,packaging,quality,deliveredOnTime,qualitativeFeedback);

    }
}
