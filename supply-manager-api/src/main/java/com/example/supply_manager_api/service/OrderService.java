package com.example.supply_manager_api.service;

import com.example.supply_manager_api.dto.OrderDto;
import com.example.supply_manager_api.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class OrderService {

    private static final Logger logger = LoggerFactory.getLogger(OrderService.class);

    @Autowired
    private OrderRepository orderRepository;

    public List<OrderDto> getOrdersByUserId(Long userId) {
        logger.info("Fetching orders for user ID: {}", userId);
        return orderRepository.findOrdersByUserId(userId);
    }
}