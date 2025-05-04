package com.example.supply_manager_api.model;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "review", schema = "supply_manager")
public class Review {

    @Column(name = "id")
    private Long id;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "version_id")
    private Long versionId;

    @Column(name = "author_id")
    private Long authorId;

    @Column(name = "author_version_id")
    private Long authorVersionId;

    @Column(name = "target_id")
    private Long targetId;

    @Column(name = "target_version_id")
    private Long targetVersionId;

    @Column(name = "order_id")
    private Long orderId;

    @Column(name = "order_version_id")
    private Long orderVersionId;

    @Column(name = "rating")
    private Integer rating;

    @Column(name = "comment")
    private String comment;

    @Column(name = "obsolete")
    private Boolean obsolete;

    @Column(name = "begin_ts")
    private LocalDateTime beginTs;

    @Column(name = "end_ts")
    private LocalDateTime endTs;
}