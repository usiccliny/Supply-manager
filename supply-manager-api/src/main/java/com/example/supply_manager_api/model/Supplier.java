package com.example.supply_manager_api.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "supplier", schema = "supply_manager")
public class Supplier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "supplier_id", nullable = false)
    private Long supplierId;

    @Column(name = "supplier_version_id")
    private Long supplierVersionId;

    @Column(name = "contact_person", nullable = false)
    private String contactPerson;

    @Column(name = "phone_number")
    private String phoneNumber;

    @Column(name = "email")
    private String email;

    @Column(name = "address")
    private String address;

    @Column(name = "company_id")
    private Long companyId;

    @Column(name = "company_version_id")
    private Long companyVersionId;

    @ManyToOne
    @JoinColumns({
            @JoinColumn(name = "company_id", referencedColumnName = "id", insertable = false, updatable = false),
            @JoinColumn(name = "company_version_id", referencedColumnName = "version_id", insertable = false, updatable = false)
    })
    private Company company; // связь с сущностью Company

    @Column(name = "post_id", nullable = false)
    private Long postId;

    @ManyToOne
    @JoinColumn(name = "post_id", referencedColumnName = "id", insertable = false, updatable = false)
    private Post post; // связь с сущностью Post

    @Column(name = "obsolete")
    private boolean obsolete;

    @Column(name = "begin_ts")
    private LocalDateTime beginTs;

    @Column(name = "end_ts")
    private LocalDateTime endTs;
}