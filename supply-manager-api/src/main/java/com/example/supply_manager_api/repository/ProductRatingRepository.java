package com.example.supply_manager_api.repository;

import com.example.supply_manager_api.dto.ProductRatingDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class ProductRatingRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public List<ProductRatingDto> getProductRatingsByCategory(String category) {
        String sql = "SELECT * FROM supply_manager.fv_product_rating(?)";
        return jdbcTemplate.query(sql, new Object[]{category}, new BeanPropertyRowMapper<>(ProductRatingDto.class));
    }
}
