package com.example.supply_manager_api.dto;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class UserDto {
    // Геттеры и сеттеры
    private String username;
    private String password;
    private String email;

}