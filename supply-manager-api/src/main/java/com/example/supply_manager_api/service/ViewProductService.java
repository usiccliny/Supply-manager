package com.example.supply_manager_api.service;

import com.example.supply_manager_api.model.ViewProduct;
import com.example.supply_manager_api.repository.ViewProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ViewProductService {

    @Autowired
    private ViewProductRepository viewProductRepository;

    public List<ViewProduct> getAllProducts() {
        return viewProductRepository.findAll();
    }
}
