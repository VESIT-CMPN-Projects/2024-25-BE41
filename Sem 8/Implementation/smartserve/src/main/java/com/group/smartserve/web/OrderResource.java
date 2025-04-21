package com.group.smartserve.web;
import com.group.smartserve.helper.QRCodeGenerator;
import com.group.smartserve.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RequestMapping("/api/order/")
@RestController
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:3001" , "http://192.168.2.102:5173/"}, allowCredentials = "true")
public class OrderResource {
    @Autowired
    OrderService orderService;
    @PostMapping("send-query")
    public ResponseEntity<Map<String,Object>> sendQuery(@RequestBody Map<String, Object> body) {
        System.out.println(body);
        return orderService.sendQuery(body);
    }
    @PostMapping("user-orders")
    public ResponseEntity<Map<String,Object>> getUserOrders(@RequestHeader("token") String token) {
        return orderService.getUserOrders(token);
    }
    @GetMapping("/order-details/{orderId}")
    public Map<String,Object> getOrderDetails(@PathVariable int orderId) {
        return orderService.getOrderDetails(orderId);
    }

    @PostMapping("status")
    public ResponseEntity<Map<String,Object>> updateStatus(@RequestBody Map<String, Object> body) {
        System.out.println("called");
        return orderService.updateStatus(body);
    }
    @PostMapping("query-all")
    public ResponseEntity<Map<String,Object>> sendQueriestoAll(@RequestBody Map<String, Object> body) {
        System.out.println(body);
        return orderService.sendQueriestoAll(body);
    }
    @PostMapping("query-decision")
    public ResponseEntity<Map<String, Object>> decideQuery(@RequestBody Map<String, Object> body) {
        System.out.println(body);
        return orderService.decideQuery(body);
    }
    @GetMapping("get-queries/{restaurant_id}")
    public List<Map<String, Object>> getQueries(@PathVariable int restaurant_id) {
        return orderService.getQueries(restaurant_id);
    }
    @GetMapping("get-user-queries/{user_id}")
    public List<Map<String, Object>> getUserQueries(@PathVariable int user_id) {
        return orderService.getUserQueries(user_id);
    }

//    @PostMapping("/generate")
//    public ResponseEntity<Map<String,Object>> generateBill(@RequestBody Map<String,Object> orderRequest) {
//        String billId = UUID.randomUUID().toString();
////        String qrCodeData = "http://your-app.com/feedback?orderId=" + billId;
//        String qrCodeData = "http://localhost:3001";
//        try {
//            byte[] qrCodeImage = QRCodeGenerator.generateQRCodeImage(qrCodeData, 200, 200);
//            String base64Image = Base64.getEncoder().encodeToString(qrCodeImage);
//
//            // Save bill and other details in the database
//            return ResponseEntity.ok(Map.of(billId, base64Image));
//        } catch (Exception e) {
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
//        }
//    }

}
