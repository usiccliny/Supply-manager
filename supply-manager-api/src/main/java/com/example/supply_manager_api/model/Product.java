package com.example.supply_manager_api.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table (name = "product", schema = "supply_manager")
public class Product {

    @Column(name = "id")
    private Long id;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "version_id")
    private Long versionId;

    @Column(name = "supplier_id")
    private Long supplierId;

    @Column(name = "supplier_version_id")
    private Long supplierVersionId;

    @ManyToOne
    @JoinColumns({
            @JoinColumn(name = "supplier_id", referencedColumnName = "supplier_id", insertable = false, updatable = false),
            @JoinColumn(name = "supplier_version_id", referencedColumnName = "supplier_version_id", insertable = false, updatable = false)
    })
    private Supplier supplier;

    @Column(name = "category_product_id")
    private Long categoryProductId;

    @ManyToOne
    @JoinColumn(name = "category_product_id", referencedColumnName = "id", insertable = false, updatable = false)
    private ProductCategory productCategory;

    @Column(name = "status_id")
    private Long statusId;

    @ManyToOne
    @JoinColumn(name = "status_id", referencedColumnName = "id", insertable = false, updatable = false)
    private ProductStatus productStatus;

    @Column(name = "product_name")
    private String productName;

    @Column(name = "price")
    private Double price;

    @Column(name = "quantity")
    private Integer quantity;

    @Column (name = "obsolete")
    private Boolean obsolete = false;
}
