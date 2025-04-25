package com.example.supply_manager_api.model;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.Generated;
import org.hibernate.annotations.GenerationTime;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "order_detail", schema = "supply_manager")
public class OrderDetail {

    @Id
    @Column(name = "version_id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long versionId;

    @Column(name = "id")
    @Generated(GenerationTime.INSERT)
    private Long id;

    @Column(name = "order_id")
    private Long orderId;

    @Column(name = "order_version_id")
    private Long orderVersionId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumns({
            @JoinColumn(name = "supplier_id", referencedColumnName = "supplier_id"),
            @JoinColumn(name = "supplier_version_id", referencedColumnName = "supplier_version_id")
    })
    private Supplier supplier;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumns({
            @JoinColumn(name = "product_id", referencedColumnName = "id"),
            @JoinColumn(name = "product_version_id", referencedColumnName = "version_id")
    })
    private Product product;

    @Column(name = "quantity", nullable = false)
    private Long quantity;

    @Column(name = "date_created", nullable = false)
    private LocalDateTime dateCreated;

    @Column(name = "date_modified", nullable = false)
    private LocalDateTime dateModified;

    @Column(name = "obsolete")
    private Boolean obsolete;

    @Column(name = "begin_ts")
    private LocalDateTime beginTs;

    @Column(name = "end_ts")
    private LocalDateTime endTs;
}