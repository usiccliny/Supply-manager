package com.example.supply_manager_api.repository;

import com.example.supply_manager_api.model.OrderDetail;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OrderDetailRepository extends JpaRepository <OrderDetail, Long> {

    List<OrderDetail> findByOrderId(Long orderId);
}