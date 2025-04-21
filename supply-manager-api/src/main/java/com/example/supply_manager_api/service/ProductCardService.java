package com.example.supply_manager_api.service;

import com.example.supply_manager_api.model.ProductCard;
import com.example.supply_manager_api.repository.ProductCardRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProductCardService {

    @Autowired
    private ProductCardRepository productCardRepository;

    public List<ProductCard> getAllProductCards() {
        return productCardRepository.findAll();
    }

    public ProductCard getProductCardById(Long id) {
        return productCardRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("ProductCard not found with id: " + id));
    }
}
