package com.example.supply_manager_api.repository;

import com.example.supply_manager_api.model.OrderDetail;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OrderDetailRepository extends JpaRepository<OrderDetail, Long> {
    Optional<OrderDetail> findByIdAndObsoleteFalse(Long id);
}