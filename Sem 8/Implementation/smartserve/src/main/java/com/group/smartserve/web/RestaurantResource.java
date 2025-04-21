package com.group.smartserve.web;

import com.group.smartserve.service.RestaurantService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RequestMapping("/api/food")
@RestController
@CrossOrigin(origins = {"http://localhost:5173", "http://192.168.2.102:5173/", "http://localhost:3001"}, allowCredentials = "true")
public class RestaurantResource {

    @Autowired
    RestaurantService restaurantService;
    @GetMapping("/get-restaurants")
    public List<Map<String,Object>> getRestaurants() {
        return restaurantService.getRestaurants();
    }
    @GetMapping("/get-restaurant-details/{restaurantId}")
    public Map<String,Object> getRestaurantDetails(@PathVariable int restaurantId) {
        return restaurantService.getRestaurantDetails(restaurantId);
    }
    @GetMapping("/get-restaurant-menu/{restaurantId}")
    public List<Map<String, Object>> getRestaurantMenu(@PathVariable Long restaurantId) {
        return restaurantService.getRestaurantMenu(restaurantId);
    }
    @GetMapping("/list/{user_id}")
    public List<Map<String, Object>> getFoodList(@PathVariable int user_id) {
        return restaurantService.getFoodList(user_id);
    }

    @GetMapping("/order/list/{user_id}")
    public List<Map<String, Object>> getOrderList(@PathVariable int user_id) {
        return restaurantService.getOrderList(user_id);
    }

    @PostMapping("/add")
    public ResponseEntity<Map<String, Object>> addFood(@RequestParam("name") String name, @RequestParam("price") int price, @RequestParam("user_id") int user_id, @RequestParam("category") int category , @RequestParam("description") String description) {
//        System.out.println("image = " + image);
        System.out.println("name = " + name);
        System.out.println("price = " + price);
        System.out.println("restaurant_id = " + user_id);
        System.out.println("category = " + category);
        System.out.println("description = " + description);

        return restaurantService.addFood(name,price,user_id,category,description);
    }





}
