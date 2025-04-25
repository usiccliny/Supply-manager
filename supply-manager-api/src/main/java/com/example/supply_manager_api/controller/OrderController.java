package com.example.supply_manager_api.controller;

import com.example.supply_manager_api.dto.OrderDto;
import com.example.supply_manager_api.dto.OrderRequestDTO;
import com.example.supply_manager_api.model.OrderDetailV;
import com.example.supply_manager_api.service.OrderDetailVService;
import com.example.supply_manager_api.service.OrderServ;
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
    private OrderServ orderServ;

    @Autowired
    private OrderDetailVService orderDetailVService;

    @GetMapping()
    public List<OrderDto> getOrdersByUserId(@RequestParam Long userId) {
        return orderService.getOrdersByUserId(userId);
    }

    @GetMapping("/{orderId}")
    public List<OrderDetailV> getOrderDetailByOrderId (@PathVariable Long orderId){
        return orderDetailVService.getOrderDetailsByOrderId(orderId);
    }

    @PostMapping
    public String createOrder(@RequestBody OrderRequestDTO orderRequestDTO) {
        orderServ.createOrder(orderRequestDTO);
        return "Order created successfully!";
    }
}