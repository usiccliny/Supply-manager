package com.example.supply_manager_api.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Immutable;

import java.time.LocalDate;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Immutable
@Entity
@Table(name = "v_product", schema = "supply_manager")
public class ViewProduct {

    @Column(name = "supplier_id")
    private Long supplierId;

    @Column(name = "supplier_version_id")
    private Long supplierVersionId;

    @Column(name = "product_id")
    private Long productId;

    @Id
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
    private Double price;

    @Column(name = "quantity")
    private Integer quantity;

    @Column(name = "created_date")
    private LocalDate createdDate;
}