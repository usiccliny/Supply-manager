package com.example.supply_manager_api.dto;

import lombok.Data;

@Data
public class ProductRatingDto {
    private Long productId;
    private String productName;
    private Double totalRating;
    private Integer totalRank;
}
