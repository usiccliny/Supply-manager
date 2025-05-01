package com.example.supply_manager_api.controller;

import com.example.supply_manager_api.service.RatingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Date;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/rating")
public class RatingController {

    private final RatingService ratingService;

    @Autowired
    public RatingController(RatingService ratingService) {
        this.ratingService = ratingService;
    }

    @GetMapping("/supplier-rating")
    public List<Map<String, Object>> getSupplierRating(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date date) {
        return ratingService.getSupplierRating(date);
    }

    @GetMapping("/product-rating")
    public List<Map<String, Object>> getProductRating(
            @RequestParam String productCategory,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date date) {
        return ratingService.getProductRating(productCategory, date);
    }

    @GetMapping("/category-rating")
    public List<Map<String, Object>> getCategoryRating(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date date) {
        return ratingService.getCategoryRating(date);
    }

    @GetMapping("/supplier-description-quality-rating")
    public List<Map<String, Object>> getSupplierDescriptionQualityRating(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date date) {
        return ratingService.getSupplierDescriptionQualityRating(date);
    }

    @GetMapping("/supplier-price-rating")
    public List<Map<String, Object>> getSupplierPriceRating(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date date) {
        return ratingService.getSupplierPriceRating(date);
    }

    @GetMapping("/supplier-rating-category")
    public List<Map<String, Object>> getSupplierRatingCategory(
            @RequestParam String productCategory,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date date) {
        return ratingService.getSupplierRatingCategory(productCategory, date);
    }

    @GetMapping("/user-rating")
    public List<Map<String, Object>> getUserRating(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date date) {
        return ratingService.getUserRating(date);
    }

    @GetMapping("/supplier-newness-rating")
    public List<Map<String, Object>> getSupplierNewnessRating(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date date) {
        return ratingService.getSupplierNewnessRating(date);
    }

    @GetMapping("/user-loyalty-rating")
    public List<Map<String, Object>> getUserLoyaltyRating(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date date,
            @RequestParam Long supplierId) {
        return ratingService.getUserLoyaltyRating(date, supplierId);
    }
}