package com.example.supply_manager_api.controller;

import com.example.supply_manager_api.dto.SupplierDto;
import com.example.supply_manager_api.service.SupplierService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/suppliers")
public class SupplierController {

    @Autowired
    private SupplierService supplierService;

    @GetMapping({"/{userId}"})
    public List<SupplierDto> getSuppliersByUserId(@PathVariable Long userId) {
        return supplierService.getSuppliersByUserId(userId);
    }
}