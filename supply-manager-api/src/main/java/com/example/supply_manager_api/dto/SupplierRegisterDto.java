package com.example.supply_manager_api.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SupplierRegisterDto extends UserDto{

    private String contactPerson;   // Контактное лицо
    private String phoneNumber;      // Номер телефона (опционально)
    private String email;            // Электронная почта (опционально)
    private String address;          // Адрес (опционально)
    private String companyName;      // Имя компании (опционально для источника)
    private String position;         // Должность (опционально для источника)
    private String username;         // Имя пользователя (обязательное)
    private String password;         // Пароль (обязательное)
}