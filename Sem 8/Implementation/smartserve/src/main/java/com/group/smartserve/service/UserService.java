package com.group.smartserve.service;

import com.group.smartserve.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.Map;
@Service
public class UserService {
    @Autowired
    UserRepository userRepository;

    public ResponseEntity<Map<String,Object>> registerUser(Map<String,Object> body)
    {

        String fullname = (String)body.get("fullname");
        String password = (String)body.get("password");
        String email = (String)body.get("email");
        String dob = (String) body.get("dob");
        String phone = (String) body.get("phone");

        Map<String, Object> res  = userRepository.registerUser(fullname,dob,email,password,phone);
        if(res.get("message").equals("User registered successfully"))
        {
            return ResponseEntity.ok(Map.of("status","successful"));
        }
        return ResponseEntity.status(HttpStatus.NOT_ACCEPTABLE).body(Map.of("status","Unsuccessful"));

    }
    public Map<String,Object> loginUser( Map<String,Object> body)
    {
        String username = (String)body.get("username");
        String password = (String)body.get("password");
        return userRepository.loginUser(username,password);

//        return ResponseEntity.status(HttpStatus.NOT_ACCEPTABLE).body(Map.of("status","Unsuccessful"));
    }
}
