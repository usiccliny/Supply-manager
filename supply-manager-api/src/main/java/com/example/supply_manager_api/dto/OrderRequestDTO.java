package com.example.supply_manager_api.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class OrderRequestDTO {
    private Long userId;
    private Long paymentMethodId;
    private String shippingAddress;
    private String billingAddress;
    private BigDecimal totalAmount;
    private List<OrderDetailRequestDTO> orderDetails;
}
