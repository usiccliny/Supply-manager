package com.example.supply_manager_api.model;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "review_reaction", schema = "supply_manager")
public class ReviewReaction {

    @Column(name = "id")
    private Long id;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "version_id")
    private Long versionId;

    @Column(name = "review_id")
    private Long reviewId;

    @Column(name = "review_version_id")
    private Long reviewVersionId;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "user_version_id")
    private Long userVersionId;

    @Column(name = "reaction_type")
    private String reactionType;

    @Column(name = "obsolete")
    private Boolean obsolete;

    @Column(name = "begin_ts")
    private LocalDateTime beginTs;

    @Column(name = "end_ts")
    private LocalDateTime endTs;
}