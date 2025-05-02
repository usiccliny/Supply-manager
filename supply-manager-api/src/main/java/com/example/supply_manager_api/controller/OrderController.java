package com.example.supply_manager_api.controller;

import com.example.supply_manager_api.dto.OrderDetailDTO;
import com.example.supply_manager_api.dto.OrderDto;
import com.example.supply_manager_api.dto.OrderRequestDTO;
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
    public List<OrderDto> getOrders(
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) String date,
            @RequestParam(required = false) String supplierName) {
        return orderService.getOrders(userId, date, supplierName);
    }

    @GetMapping("/{orderId}")
    public List<OrderDetailDTO> getOrderDetails(
            @PathVariable Long orderId,
            @RequestParam Integer role) {
        return orderDetailVService.getOrderDetails(orderId, role);
    }

    @PostMapping
    public String createOrder(@RequestBody OrderRequestDTO orderRequestDTO) {
        orderServ.createOrder(orderRequestDTO);
        return "Order created successfully!";
    }
}