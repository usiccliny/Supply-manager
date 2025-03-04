package com.example.supply_manager_api.dto;

import jakarta.persistence.Column;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class OrderDto {

    private Long orderId;
    private Long userId;
    private LocalDateTime orderDate;
    private String orderStatus;
    private Double totalAmount;
    private String shippingAddress;
    private String billingAddress;
    private String paymentMethod;
    private String trackingNumber;
    @Column(nullable = true)
    private String notes;
}
