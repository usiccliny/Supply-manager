package com.example.supply_manager_api.repository;

import com.example.supply_manager_api.model.ViewProduct;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ViewProductRepository extends JpaRepository<ViewProduct, Long> {
}