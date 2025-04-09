package com.example.supply_manager_api.service;

import com.example.supply_manager_api.dto.SupplierDto;
import com.example.supply_manager_api.model.SupplierWidget;
import com.example.supply_manager_api.repository.SupplierRepository;
import com.example.supply_manager_api.repository.SupplierWidgetRepository;
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

    @Autowired
    private SupplierWidgetRepository supplierWidgetRepository;

    public List<SupplierDto> getSuppliersByUserId() {
        return supplierRepository.findSuppliersByUserId();
    }

    public List<SupplierDto> getSuppliersById(Long userId, Long supplierId) {
        logger.info("Fetching orders for user ID: {}, supplierId: {}", userId, supplierId);
        return supplierRepository.findSuppliersById(userId, supplierId);
    }

    public List<SupplierWidget> getSupplierWidgetAll(){
        return supplierWidgetRepository.findAll();
    }
}