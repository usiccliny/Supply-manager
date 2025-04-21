package com.example.supply_manager_api.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "product_attribute", schema = "supply_manager")
@Getter
@Setter
public class ProductAttribute {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false)
    private Long id;

    @Column(name = "version_id")
    private Long versionId;

    @Column(name = "product_id", nullable = false)
    private Long productId;

    @Column(name = "product_version_id", nullable = false)
    private Long productVersionId;

    @ManyToOne
    @JoinColumn(name = "attribute_id", referencedColumnName = "id", nullable = false)
    private Attribute attribute;

    @Column(name = "value", nullable = false)
    private String value;

    @Column(name = "obsolete", nullable = false)
    private Boolean obsolete;
}