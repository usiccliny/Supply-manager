package com.example.supply_manager_api.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Immutable;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.Type;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Immutable
@Table(name = "v_product_card", schema = "supply_manager")
public class ProductCard {

    @Id
    @Column(name = "product_id")
    private Long productId;

    @Column(name = "supplier_id")
    private Long supplierId;

    @Column(name = "supplier_version_id")
    private Long supplierVersionId;

    @Column(name = "product_version_id")
    private Long productVersionId;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "user_version_id")
    private Long userVersionId;

    @Column(name = "category_name")
    private String categoryName;

    @Column(name = "product_status")
    private String productStatus;

    @Column(name = "product_name")
    private String productName;

    @Column(name = "price")
    private BigDecimal price;

    @Column(name = "quantity")
    private Integer quantity;

    @Column(name = "photo")
    private String photo;

    @Column(name = "video")
    private String video;

    @Column(name = "rating")
    private Double rating;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "attributes", columnDefinition = "jsonb")
    private List<Map<String, Object>> attributes;

    @Column(name = "created_date")
    private LocalDate createdDate;
}
