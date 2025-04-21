package com.group.smartserve.web;

import com.group.smartserve.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
@RequestMapping("/api/user")
@RestController
@CrossOrigin(origins = {"http://localhost:5173", "http://192.168.2.102:5173/", "http://localhost:3001"}, allowCredentials = "true")
public class UserResource {

    @Autowired
    UserService userService;

    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> registerUser(@RequestBody Map<String, Object> body) {
        return userService.registerUser(body);
    }

    @PostMapping("/login")
    public Map<String, Object> loginUser(@RequestBody Map<String, Object> body) {
        System.out.println(userService.loginUser(body));
        return userService.loginUser(body);
    }

    @GetMapping("/test")
    public String test() {
        return "Hello World";
    }


}
