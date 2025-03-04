package com.example.supply_manager_api.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class SupplierDto {
    private Long supplierId;
    private Long userId;
    private String contactPerson;
    private String phoneNumber;
    private String email;
    private String address;
    private Long companyId;
    private String companyName;
    private String postName;
    private String postShortName;
}
