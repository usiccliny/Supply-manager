package com.example.supply_manager_api.controller;

import com.example.supply_manager_api.dto.AuthResponse;
import com.example.supply_manager_api.dto.SupplierRegisterDto;
import com.example.supply_manager_api.dto.UserDto;
import com.example.supply_manager_api.dto.LoginDto;
import com.example.supply_manager_api.service.SupplierRegisterService;
import com.example.supply_manager_api.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Objects;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserService userService;

    @Autowired
    private SupplierRegisterService supplierRegisterService;

    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody SupplierRegisterDto supplierRegisterDto) {
        try {
            if (Objects.equals(supplierRegisterDto.getRole(), "supplier")) {
                supplierRegisterService.registerSupplier(supplierRegisterDto);
            }
            else{
                userService.registerUser(supplierRegisterDto);
            }
            return ResponseEntity.ok("User registered successfully");
        } catch (RuntimeException e) {
            // Логируем конкретные ошибки
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An unexpected error occurred: " + e.getMessage());
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginDto loginDto) {
        try {
            AuthResponse authResponse = userService.authenticateUser(loginDto);
            return ResponseEntity.ok(authResponse);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An unexpected error occurred");
        }
    }
}