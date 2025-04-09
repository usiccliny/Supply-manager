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

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Immutable
@Table(name = "v_supplier_widget", schema = "supply_manager")
public class SupplierWidget {

    @Id
    @Column(name = "supplier_id")
    private Long supplierId;

    @Column(name = "supplier_version_id")
    private Long supplierVersionId;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "userVersionId")
    private Long user_version_id;

    @Column (name = "total_product_cnt")
    private Long totalProductCnt;

    @Column (name = "available_product_cnt")
    private Long availableProductCnt;

    @Column (name = "ended_product_cnt")
    private Long endedProductCnt;

    @Column (name = "coming_product_cnt")
    private Long comingProductCnt;
}
