package com.example.supply_manager_api.model;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.Generated;
import org.hibernate.annotations.GenerationTime;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Entity
@Table(name = "order", schema = "supply_manager")
public class Order {

    @Column(name = "version_id", nullable = false)
    @Generated(GenerationTime.INSERT)
    private Long versionId;

    @Id
    @Column(name = "id", nullable = false)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumns({
            @JoinColumn(name = "user_id", referencedColumnName = "id"),
            @JoinColumn(name = "user_version_id", referencedColumnName = "version_id")
    })
    private User user;

    @Column(name = "order_date", nullable = false)
    private LocalDateTime orderDate;

    @Column(name = "order_status_id")
    private Long orderStatusId;

    @Column(name = "total_amount")
    private BigDecimal totalAmount;

    @Column(name = "shipping_address", columnDefinition = "TEXT")
    private String shippingAddress;

    @Column(name = "billing_address", columnDefinition = "TEXT")
    private String billingAddress;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "payment_method_id")
    private PaymentMethod paymentMethod;

    @Column(name = "tracking_number", nullable = false)
    private String trackingNumber;

    @Column(name = "date_created", nullable = false)
    private LocalDateTime dateCreated;

    @Column(name = "date_modified", nullable = false)
    private LocalDateTime dateModified;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @Column(name = "obsolete")
    private Boolean obsolete;

    @Column(name = "begin_ts")
    private LocalDateTime beginTs;

    @Column(name = "end_ts")
    private LocalDateTime endTs;
}
