package com.example.supply_manager_api.model;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.Immutable;

@Entity
@Data
@Immutable
@Table(name = "v_supplier_rating", schema = "supply_manager")
public class SupplierRating {

    @Id
    @Column(name = "supplier_id", nullable = false)
    private Long supplierId;

    @Column(name = "contact_person", nullable = false)
    private String contactPerson;

    @Column(name = "total_rating", nullable = false)
    private Double totalRating;

    @Column(name = "total_rank", nullable = false)
    private Integer totalRank;
}