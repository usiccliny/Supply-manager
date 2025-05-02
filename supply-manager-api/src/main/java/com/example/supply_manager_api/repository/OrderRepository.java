package com.example.supply_manager_api.repository;

import com.example.supply_manager_api.dto.OrderDto;
import com.example.supply_manager_api.model.Supplier;
import com.example.supply_manager_api.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Repository
public class OrderRepository {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SupplierRegisterRepository supplierRepository;

    private static final Logger logger = LoggerFactory.getLogger(OrderRepository.class);

    private final NamedParameterJdbcTemplate jdbcTemplate;

    public OrderRepository(NamedParameterJdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<OrderDto> findOrders(Long userId, String date, String supplierName) {
        logger.info("Executing query for user ID: {}, date: {}, supplier ID: {}", userId, date, supplierName);
        Long supplierId;
        if (supplierName != null) {
            String email = getSupplierEmailByUsername(supplierName);
            Optional<Supplier> supplierOptional = supplierRepository.findByEmail(email);
            supplierId = supplierOptional.orElseThrow().getSupplierId();
        }
        else {
            supplierId = null;
        }

        StringBuilder sqlBuilder = new StringBuilder("SELECT * FROM supply_manager.fv_orders(");
        MapSqlParameterSource params = new MapSqlParameterSource();

        if (userId != null) {
            sqlBuilder.append(":userId");
            params.addValue("userId", userId);
        } else {
            sqlBuilder.append("NULL");
        }

        sqlBuilder.append(", ");

        if (date != null && !date.isEmpty()) {
            sqlBuilder.append(":date");
            params.addValue("date", date);
        } else {
            sqlBuilder.append("NULL");
        }

        sqlBuilder.append(", ");

        if (supplierId != null) {
            sqlBuilder.append(":supplierId");
            params.addValue("supplierId", supplierId);
        } else {
            sqlBuilder.append("NULL");
        }

        sqlBuilder.append(")");

        String sql = sqlBuilder.toString();

        try {
            return jdbcTemplate.query(sql, params, new BeanPropertyRowMapper<>(OrderDto.class));
        } catch (Exception e) {
            logger.error("Error executing query: {}", e.getMessage(), e);
            throw e;
        }
    }

    private String getSupplierEmailByUsername(String username) {
        Optional<User> userOptional = userRepository.findByUsername(username);
        return userOptional.map(User::getEmail).orElseThrow(() -> new RuntimeException("Пользователь не найден"));
    }
}