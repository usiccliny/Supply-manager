package com.example.supply_manager_api.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class OrderDetailDTO {
    private Long orderDetailId;
    private Long orderId;
    private Long userId; // Только для роли 4 (поставщик)
    private Long supplierId; // Только для роли 3 (покупатель)
    private Long productId;
    private String productName;
    private String contactPerson; // Контактное лицо (поставщика или пользователя)
    private String contactData; // Телефон или email
    private BigDecimal price;
    private Integer quantity;
}
