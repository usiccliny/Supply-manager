package com.example.supply_manager_api.repository;

import com.example.supply_manager_api.model.OrderDetailV;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OrderDetailVRepository extends JpaRepository <OrderDetailV, Long> {

    List<OrderDetailV> findByOrderId(Long orderId);
}