package com.example.supply_manager_api.repository;

import com.example.supply_manager_api.model.Product;
import com.example.supply_manager_api.model.ProductAttribute;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    Optional<Product> findByIdAndObsoleteFalse(Long id);
}
