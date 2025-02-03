package com.example.supply_manager_api.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**") // Разрешаем доступ ко всем эндпоинтам /api/**
                .allowedOrigins("http://localhost:3000") // URL вашего React-приложения
                .allowedMethods("GET", "POST", "PUT", "DELETE") // Разрешённые HTTP-методы
                .allowedHeaders("*") // Разрешаем все заголовки
                .allowCredentials(true); // Разрешаем отправку куки и авторизационных данных
    }
}