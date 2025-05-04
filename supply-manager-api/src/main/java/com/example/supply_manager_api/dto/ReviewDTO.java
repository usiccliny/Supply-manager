package com.example.supply_manager_api.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ReviewDTO {
    private Long id;
    private Long versionId;
    private Long authorId;
    private Long authorVersionId;
    private Long targetId;
    private Long targetVersionId;
    private Long orderId;
    private Long orderVersionId;
    private Integer rating;
    private String comment;
}