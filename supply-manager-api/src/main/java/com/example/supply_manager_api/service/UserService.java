package com.example.supply_manager_api.service;

import com.example.supply_manager_api.dto.LoginDto;
import com.example.supply_manager_api.dto.UserDto;

public interface UserService {
    void registerUser(UserDto userDto);
    String authenticateUser(LoginDto loginDto);
}