package com.example.supply_manager_api.repository;

import com.example.supply_manager_api.dto.OrderDetailDTO;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class OrderDetailVRepository {

    private final NamedParameterJdbcTemplate jdbcTemplate;

    public OrderDetailVRepository(NamedParameterJdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<OrderDetailDTO> findOrderDetails(Long orderId, Integer role) {
        String sql = "SELECT * FROM supply_manager.fv_order_detail(:orderId, :role)";
        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("orderId", orderId)
                .addValue("role", role);

        return jdbcTemplate.query(sql, params, new BeanPropertyRowMapper<>(OrderDetailDTO.class));
    }
}