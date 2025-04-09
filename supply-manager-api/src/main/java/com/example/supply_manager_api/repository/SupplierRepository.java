package com.example.supply_manager_api.repository;

import com.example.supply_manager_api.model.SupplierWidget;
import com.example.supply_manager_api.dto.SupplierDto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Repository
public class SupplierRepository {

    private static final Logger logger = LoggerFactory.getLogger(SupplierRepository.class);

    private final NamedParameterJdbcTemplate jdbcTemplate;

    public SupplierRepository(NamedParameterJdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<SupplierDto> findSuppliersByUserId() {
        String sql = "SELECT * FROM supply_manager.fv_suppliers()";

        try {
            return jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(SupplierDto.class));
        } catch (Exception e) {
            logger.error("Error executing query: {}", e.getMessage(), e);
            throw e;
        }
    }

    public List<SupplierDto> findSuppliersById(Long userId, Long supplierId) {
        logger.info("Executing query for user ID: {}, Supplier ID: {}", userId, supplierId);
        String sql = "SELECT * FROM supply_manager.fv_suppliers(:userId) WHERE supplier_id = :supplierId";

        // Создаем MapSqlParameterSource и добавляем оба параметра
        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("userId", userId)
                .addValue("supplierId", supplierId);

        try {
            return jdbcTemplate.query(sql, params, new BeanPropertyRowMapper<>(SupplierDto.class));
        } catch (Exception e) {
            logger.error("Error executing query: {}", e.getMessage(), e);
            throw e;
        }
    }
}