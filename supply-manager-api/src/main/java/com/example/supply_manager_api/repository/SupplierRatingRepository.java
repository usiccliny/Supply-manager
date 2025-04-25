package com.example.supply_manager_api.repository;

import com.example.supply_manager_api.model.SupplierRating;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SupplierRatingRepository extends JpaRepository<SupplierRating, Long> {

    List<SupplierRating> findAllByOrderByTotalRankAsc();
}