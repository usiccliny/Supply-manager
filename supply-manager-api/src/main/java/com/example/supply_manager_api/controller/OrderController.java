package com.example.supply_manager_api.controller;

import com.example.supply_manager_api.dto.OrderDto;
import com.example.supply_manager_api.model.OrderDetail;
import com.example.supply_manager_api.service.OrderDetailService;
import com.example.supply_manager_api.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    @Autowired
    private OrderService orderService;

    @Autowired
    private OrderDetailService orderDetailService;

    @GetMapping()
    public List<OrderDto> getOrdersByUserId(@RequestParam Long userId) {
        return orderService.getOrdersByUserId(userId);
    }

    @GetMapping("/{orderId}")
    public List<OrderDetail> getOrderDetailByOrderId (@PathVariable Long orderId){
        return orderDetailService.getOrderDetailsByOrderId(orderId);
    }
}