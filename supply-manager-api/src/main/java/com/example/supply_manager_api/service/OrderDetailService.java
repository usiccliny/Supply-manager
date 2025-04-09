package com.example.supply_manager_api.service;

import com.example.supply_manager_api.model.OrderDetail;
import com.example.supply_manager_api.repository.OrderDetailRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.dao.DataAccessException;

import java.util.List;

@Service
public class OrderDetailService {

    private static final Logger logger = LoggerFactory.getLogger(OrderDetailService.class);

    @Autowired
    private OrderDetailRepository orderDetailRepository;

    public List<OrderDetail> getOrderDetailsByOrderId(Long orderId) {
        try {
            logger.info("Fetching order details for order ID: {}", orderId);
            List<OrderDetail> details = orderDetailRepository.findByOrderId(orderId);
            logger.info("Found {} order details", details.size());
            return details;
        } catch (DataAccessException e) {
            logger.error("Error fetching order details for order ID: {}", orderId, e);
            throw new RuntimeException("Failed to retrieve order details", e);
        }
    }
}