package com.example.supply_manager_api.service;

import com.example.supply_manager_api.dto.ProductRatingDto;
import com.example.supply_manager_api.repository.ProductRatingRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProductRatingService {

    @Autowired
    private ProductRatingRepository productRatingRepository;

    public List<ProductRatingDto> getProductRatingsByCategory(String category) {
        return productRatingRepository.getProductRatingsByCategory(category);
    }
}