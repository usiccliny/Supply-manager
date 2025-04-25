package com.example.supply_manager_api.repository;

import com.example.supply_manager_api.model.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OrderRep extends JpaRepository<Order, Long> {
    Optional<Order> findByIdAndObsoleteFalse(Long id);
}