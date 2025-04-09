package com.example.supply_manager_api.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CompanyDto {
    private String name;
    private String email;
    private String address;
    private String website;
    private int lifetime;
    private double rating;
    private String compyany_code;
    private String logotype;
}
