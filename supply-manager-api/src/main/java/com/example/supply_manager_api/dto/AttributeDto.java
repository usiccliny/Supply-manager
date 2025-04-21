package com.example.supply_manager_api.dto;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
@Getter
@Setter
public class AttributeDto {
    private Long productId;
    private Long productVersionId;
    private Long attributeId;
    private String name;
    private String type;
    private String unit;
    private String value;
}
