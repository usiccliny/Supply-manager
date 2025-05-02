package com.example.supply_manager_api.service;

import com.example.supply_manager_api.dto.OrderDetailDTO;
import com.example.supply_manager_api.repository.OrderDetailVRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class OrderDetailVService {

    @Autowired
    private OrderDetailVRepository orderDetailRepository;

    public List<OrderDetailDTO> getOrderDetails(Long orderId, Integer role) {
        return orderDetailRepository.findOrderDetails(orderId, role);
    }
}