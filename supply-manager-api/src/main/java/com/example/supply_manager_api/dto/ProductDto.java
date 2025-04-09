package com.example.supply_manager_api.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ProductDto {
    private String username;
    private String categoryProduct;
    private String statusProduct;
    private String productName;
    private Double price;
    private Integer quantity;
}
