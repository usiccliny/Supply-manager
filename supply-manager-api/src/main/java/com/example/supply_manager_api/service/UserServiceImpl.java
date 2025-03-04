package com.example.supply_manager_api.service;

import com.example.supply_manager_api.config.JwtUtils;
import com.example.supply_manager_api.dto.AuthResponse;
import com.example.supply_manager_api.dto.LoginDto;
import com.example.supply_manager_api.dto.UserDto;
import com.example.supply_manager_api.model.User;
import com.example.supply_manager_api.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtils jwtUtils; // Добавляем JwtUtils

    @Override
    public void registerUser(UserDto userDto) {
        if (userRepository.existsByUsername(userDto.getUsername())) {
            throw new RuntimeException("Username already exists");
        }
        User user = new User();
        user.setUsername(userDto.getUsername());
        user.setPassword(passwordEncoder.encode(userDto.getPassword()));
        user.setEmail(userDto.getEmail());
        userRepository.save(user);
    }

    @Override
    public AuthResponse authenticateUser(LoginDto loginDto) {
        User user = userRepository.findByUsername(loginDto.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!passwordEncoder.matches(loginDto.getPassword(), user.getPassword())) {
            throw new RuntimeException("Invalid password");
        }

        // Генерируем JWT-токен
        String token = jwtUtils.generateToken(user.getUsername());

        // Возвращаем объект AuthResponse с токеном и userId
        return new AuthResponse(token, user.getId());
    }
}