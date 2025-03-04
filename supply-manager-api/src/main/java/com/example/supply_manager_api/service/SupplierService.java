package com.example.supply_manager_api.service;

import com.example.supply_manager_api.dto.OrderDto;
import com.example.supply_manager_api.dto.SupplierDto;
import com.example.supply_manager_api.repository.OrderRepository;
import com.example.supply_manager_api.repository.SupplierRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class SupplierService {

    private static final Logger logger = LoggerFactory.getLogger(SupplierService.class);

    @Autowired
    private SupplierRepository supplierRepository;

    public List<SupplierDto> getSuppliersByUserId(Long userId) {
        logger.info("Fetching orders for user ID: {}", userId);
        return supplierRepository.findSuppliersByUserId(userId);
    }
}