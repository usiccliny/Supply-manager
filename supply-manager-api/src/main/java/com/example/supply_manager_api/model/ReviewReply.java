package com.example.supply_manager_api.model;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "review_reply", schema = "supply_manager")
public class ReviewReply {

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

    @Column(name = "author_id")
    private Long authorId;

    @Column(name = "author_version_id")
    private Long authorVersionId;

    @Column(name = "reply_text")
    private String replyText;

    @Column(name = "obsolete")
    private Boolean obsolete;

    @Column(name = "begin_ts")
    private LocalDateTime beginTs;

    @Column(name = "end_ts")
    private LocalDateTime endTs;
}