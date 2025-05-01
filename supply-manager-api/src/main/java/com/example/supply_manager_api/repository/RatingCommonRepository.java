package com.example.supply_manager_api.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class RatingCommonRepository {

    private final NamedParameterJdbcTemplate jdbcTemplate;

    @Autowired
    public RatingCommonRepository(NamedParameterJdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<Map<String, Object>> executeQuery(String sql, Map<String, Object> params) {
        return jdbcTemplate.queryForList(sql, new MapSqlParameterSource(params));
    }

    public List<Map<String, Object>> executeQuery(String sql) {
        return jdbcTemplate.queryForList(sql, new MapSqlParameterSource());
    }
}