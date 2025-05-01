package com.example.supply_manager_api.service;

import com.example.supply_manager_api.repository.RatingCommonRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class RatingService {

    private final RatingCommonRepository commonRepository;

    @Autowired
    public RatingService(RatingCommonRepository commonRepository) {
        this.commonRepository = commonRepository;
    }

    public List<Map<String, Object>> getSupplierRating(java.util.Date date) {
        String sql = "SELECT * FROM supply_manager.fv_supplier_rating(:i_date)";
        Map<String, Object> params = new HashMap<>();
        params.put("i_date", new java.sql.Date(date.getTime()));
        return commonRepository.executeQuery(sql, params);
    }

    public List<Map<String, Object>> getProductRating(String productCategory, java.util.Date date) {
        String sql = "SELECT * FROM supply_manager.fv_product_rating(:i_product_category,:i_date)";
        Map<String, Object> params = new HashMap<>();
        params.put("i_product_category", productCategory);
        params.put("i_date", new java.sql.Date(date.getTime()));
        return commonRepository.executeQuery(sql, params);
    }

    public List<Map<String, Object>> getCategoryRating(java.util.Date date) {
        String sql = "SELECT * FROM supply_manager.fv_category_rating(:i_date)";
        Map<String, Object> params = new HashMap<>();
        params.put("i_date", new java.sql.Date(date.getTime()));
        return commonRepository.executeQuery(sql, params);
    }

    public List<Map<String, Object>> getSupplierDescriptionQualityRating(java.util.Date date) {
        String sql = "SELECT * FROM supply_manager.fv_supplier_description_quality_rating(:i_date)";
        Map<String, Object> params = new HashMap<>();
        params.put("i_date", new java.sql.Date(date.getTime()));
        return commonRepository.executeQuery(sql, params);
    }

    public List<Map<String, Object>> getSupplierPriceRating(java.util.Date date) {
        String sql = "SELECT * FROM supply_manager.fv_supplier_price_rating(:i_date)";
        Map<String, Object> params = new HashMap<>();
        params.put("i_date", new java.sql.Date(date.getTime()));
        return commonRepository.executeQuery(sql, params);
    }

    public List<Map<String, Object>> getSupplierRatingCategory(String productCategory, java.util.Date date) {
        String sql = "SELECT * FROM supply_manager.fv_supplier_rating_category(:i_product_category,:i_date)";
        Map<String, Object> params = new HashMap<>();
        params.put("i_product_category", productCategory);
        params.put("i_date", new java.sql.Date(date.getTime()));
        return commonRepository.executeQuery(sql, params);
    }

    public List<Map<String, Object>> getUserRating(java.util.Date date) {
        String sql = "SELECT * FROM supply_manager.fv_user_rating(:i_date)";
        Map<String, Object> params = new HashMap<>();
        params.put("i_date", new java.sql.Date(date.getTime()));
        return commonRepository.executeQuery(sql, params);
    }

    public List<Map<String, Object>> getSupplierNewnessRating(java.util.Date date) {
        String sql = "SELECT * FROM supply_manager.fv_supplier_newness_rating(:i_date)";
        Map<String, Object> params = new HashMap<>();
        params.put("i_date", new java.sql.Date(date.getTime()));
        return commonRepository.executeQuery(sql, params);
    }

    public List<Map<String, Object>> getUserLoyaltyRating(java.util.Date date, Long supplierId) {
        String sql = "SELECT * FROM supply_manager.fv_user_loyalty_rating(:i_date, :i_supplier_id)";
        Map<String, Object> params = new HashMap<>();
        params.put("i_date", new java.sql.Date(date.getTime()));
        params.put("i_supplier_id", supplierId);
        return commonRepository.executeQuery(sql, params);
    }
}
