package com.group.smartserve.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.jdbc.core.JdbcTemplate;
import java.util.Map;

@Repository
public class UserRepository {

    @Autowired
    JdbcTemplate jdbcTemplate;
    public Map<String, Object> registerUser(String fullname,String dob,String email, String password,String phone)
    {
        Map<String, Object> res = jdbcTemplate.queryForMap("EXEC sp_register_user ?,?,?,?,?",fullname,password,email,phone,dob);
        System.out.println(res);
        return res;
    }
    public Map<String, Object> loginUser(String username, String password) {
        System.out.println(jdbcTemplate.queryForMap("EXEC sp_login_user ? , ? ", username, password));
        return jdbcTemplate.queryForMap("EXEC sp_login_user ? , ? ", username, password);
    }
}
