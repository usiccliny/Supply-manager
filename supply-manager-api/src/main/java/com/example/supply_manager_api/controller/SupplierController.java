package com.example.supply_manager_api.controller;

import com.example.supply_manager_api.dto.SupplierDto;
import com.example.supply_manager_api.model.SupplierWidget;
import com.example.supply_manager_api.service.SupplierService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/suppliers")
public class SupplierController {

    @Autowired
    private SupplierService supplierService;

    @GetMapping()
    public List<SupplierDto> getSuppliersByUserId() {
        return supplierService.getSuppliersByUserId();
    }

    @GetMapping("/{supplierId}")
    public List<SupplierDto> getSuppliersById(@PathVariable Long supplierId, @RequestParam Long userId) {
        return supplierService.getSuppliersById(userId, supplierId);
    }

    @GetMapping("/supplierWidget")
    public List<SupplierWidget> getAllSupplierWidget()
    {
        return supplierService.getSupplierWidgetAll();
    }
}