package com.example.supply_manager_api.service;

import com.example.supply_manager_api.model.SupplierRating;
import com.example.supply_manager_api.repository.SupplierRatingRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SupplierRatingService {

    @Autowired
    private SupplierRatingRepository supplierRatingRepository;

    public List<SupplierRating> getAllSuppliersWithRating() {
        return supplierRatingRepository.findAllByOrderByTotalRankAsc();
    }
}
