package com.group.smartserve.service;

import com.group.smartserve.repository.BidRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class BiddingService {
    @Autowired
    private BidRepository bidRepository;

    public boolean saveBid(Map<String, Object> bidData) {
        return bidRepository.saveBid(bidData);
    }

    public Map<String, Object> selectBestBid(String queryId) {
        List<Map<String, Object>> bids = bidRepository.getBidsByQueryId(queryId);
//        logger.info("Fetched {} bids for queryId {}", bids.size(), queryId);
        System.out.println("Fetched "+bids.size() +" bids for queryId "+queryId );

        if (bids.isEmpty()) return null;

        // Find min/max values for normalization
        double minRating = bids.stream().mapToDouble(b -> getDoubleValue(b.get("averageRating"), 0)).min().orElse(0);
        double maxRating = bids.stream().mapToDouble(b -> getDoubleValue(b.get("averageRating"), 5)).max().orElse(5);
        double minPrice = bids.stream().mapToDouble(b -> getDoubleValue(b.get("bidPrice"), Double.MAX_VALUE)).min().orElse(Double.MAX_VALUE);
        double maxPrice = bids.stream().mapToDouble(b -> getDoubleValue(b.get("bidPrice"), Double.MIN_VALUE)).max().orElse(Double.MIN_VALUE);
        int minTime = bids.stream().mapToInt(b -> getIntValue(b.get("estimatedDeliveryTime"), Integer.MAX_VALUE)).min().orElse(Integer.MAX_VALUE);
        int maxTime = bids.stream().mapToInt(b -> getIntValue(b.get("estimatedDeliveryTime"), Integer.MIN_VALUE)).max().orElse(Integer.MIN_VALUE);

        // Select best bid based on the formula
        Map<String, Object> bestBid = bids.stream()
                .min(Comparator.comparingDouble(b -> calculateBidScore(b, minRating, maxRating, minPrice, maxPrice, minTime, maxTime)))
                .orElse(null);

        if (bestBid != null) {
            int bidId = ((Number) bestBid.getOrDefault("bid_id", 0)).intValue();
            bidRepository.updateQueryWithBestBid(bidId);
        }

        return bestBid; // Returns null if no bid is found
    }

    // Formula-based score calculation
    private double calculateBidScore(Map<String, Object> bid, double minRating, double maxRating, double minPrice, double maxPrice, int minTime, int maxTime) {
        double rating = getDoubleValue(bid.get("averageRating"), 0);
        double price = getDoubleValue(bid.get("bidPrice"), Double.MAX_VALUE);
        int time = getIntValue(bid.get("estimatedDeliveryTime"), Integer.MAX_VALUE);

        // Normalize values
        double normRating = (maxRating - rating) / (maxRating - minRating + 0.01); // Higher rating → Lower score
        double normPrice = (price - minPrice) / (maxPrice - minPrice + 0.01); // Lower price → Lower score
        double normTime = (time - minTime) / (maxTime - minTime + 0.01); // Faster delivery → Lower score

        // Weights (adjustable)
        double w1 = 0.5, w2 = 0.3, w3 = 0.2;
        System.out.println(w1 * normRating + w2 * normPrice + w3 * normTime);
        return w1 * normRating + w2 * normPrice + w3 * normTime;
    }

    // Utility methods for safe type conversions
    private double getDoubleValue(Object value, double defaultValue) {
        return (value instanceof Number) ? ((Number) value).doubleValue() : defaultValue;
    }

    private int getIntValue(Object value, int defaultValue) {
        return (value instanceof Number) ? ((Number) value).intValue() : defaultValue;
    }


    public List<Map<String, Object>> getQueries() {
        return bidRepository.getQueries();
    }
}
