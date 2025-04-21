package com.group.smartserve.service;
import com.group.smartserve.repository.RestaurantRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class RestaurantService {
    @Autowired
    RestaurantRepository restaurantRepository;

    public List<Map<String,Object>> getRestaurants()
    {
        return restaurantRepository.getRestaurants();
    }
    public Map<String,Object> getRestaurantDetails(int restaurantId)
    {
        return restaurantRepository.getRestaurantDetails(restaurantId);
    }
    public List<Map<String, Object>> getRestaurantMenu(Long restaurantId) {
        return restaurantRepository.getRestaurantMenu(restaurantId);
    }
    public List<Map<String, Object>> getFoodList(int user_id) {
        return restaurantRepository.getFoodList(user_id);
    }
    public List<Map<String, Object>> getOrderList(int user_id) {
        return restaurantRepository.getOrderList(user_id);
    }
    public ResponseEntity<Map<String, Object>> addFood(String name , int price , int user_id , int category, String description) {

        return restaurantRepository.addFood(name , price , user_id,category,description);
    }

}
