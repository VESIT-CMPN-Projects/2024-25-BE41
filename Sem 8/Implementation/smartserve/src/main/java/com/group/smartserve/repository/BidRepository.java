package com.group.smartserve.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
@Repository
public class BidRepository {
    @Autowired
    JdbcTemplate jdbcTemplate;

    // ✅ Corrected: Using query_id instead of order_id, and additional_info instead of special_offers
    public boolean saveBid(Map<String, Object> bidData) {
        System.out.println(bidData+"biddata");
        int restaurantId = (int) jdbcTemplate.queryForMap("select restaurant_id from restaurants where user_id = ?", bidData.get("userId")).get("restaurant_id");
        String sql = "INSERT INTO bids (query_id, restaurant_id, bid_price, estimated_delivery_time, additional_info) " +
                "VALUES (?, ?, ?, ?, ?)";

        int rows = jdbcTemplate.update(sql,
                bidData.get("queryId"),  // ✅ Corrected
                restaurantId,
                bidData.get("bidPrice"),
                bidData.get("estimatedDeliveryTime"),
                bidData.get("additionalInfo"));  // ✅ Corrected

        return rows > 0;
    }

    // ✅ Corrected: Using query_id instead of order_id
    public List<Map<String, Object>> getBidsByQueryId(String queryId) {
        String sql = "SELECT * FROM bids b inner join restaurants r on b.restaurant_id = r.restaurant_id WHERE b.query_id = ?";
        return jdbcTemplate.queryForList(sql, queryId);
    }
    public List<Map<String, Object>> getQueries() {
        return jdbcTemplate.queryForList("EXEC sp_get_queries");
    }
    public void updateQueryWithBestBid(int bidId){
        System.out.println("EXEC PlaceOrderFromBid "+bidId);
        jdbcTemplate.update("EXEC PlaceOrderFromBid ?", bidId);

    }
}
