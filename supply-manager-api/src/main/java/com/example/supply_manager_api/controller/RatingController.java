package com.example.supply_manager_api.controller;

import com.example.supply_manager_api.dto.ProductRatingDto;
import com.example.supply_manager_api.model.SupplierRating;
import com.example.supply_manager_api.service.ProductRatingService;
import com.example.supply_manager_api.service.SupplierRatingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/rating")
public class RatingController {

    @Autowired
    private SupplierRatingService supplierRatingService;

    @Autowired
    private ProductRatingService productRatingService;

    @GetMapping("/supplier-total")
    public List<SupplierRating> getSupplierRatings() {
        return supplierRatingService.getAllSuppliersWithRating();
    }

    @GetMapping("/product-total")
    public List<ProductRatingDto> getProductRatings(@RequestParam String category) {
        return productRatingService.getProductRatingsByCategory(category);
    }
}