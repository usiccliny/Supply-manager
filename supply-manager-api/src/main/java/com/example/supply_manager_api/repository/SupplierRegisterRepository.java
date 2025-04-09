package com.example.supply_manager_api.repository;

import com.example.supply_manager_api.model.Supplier;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface SupplierRegisterRepository extends JpaRepository<Supplier, Long> {
    Optional<Supplier> findByEmail (String email);
}