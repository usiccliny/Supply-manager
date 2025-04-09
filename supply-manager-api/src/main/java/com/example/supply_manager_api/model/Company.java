package com.example.supply_manager_api.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "company", schema = "supply_manager")
public class Company {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "version_id", nullable = false)
    private Long versionId;

    @Column(nullable = false)
    private String name;

    @Column(nullable = true)
    private String email;

    @Column(nullable = true)
    private String address;

    @Column(nullable = true)
    private String website;

    @Column(nullable = true)
    private Integer lifetime;

    @Column(nullable = true)
    private Double rating;

    @Column(nullable = false, unique = true)
    private String companyCode;

    @Column(nullable = true)
    private String logotype;

    @Column(nullable = false)
    private Boolean obsolete;

    @Column(nullable = false, updatable = false)
    private LocalDateTime beginTs;

    @Column(nullable = false)
    private LocalDateTime endTs;
}
