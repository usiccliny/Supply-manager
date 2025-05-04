package com.example.supply_manager_api.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ReviewReactionDTO {
    private Long id;
    private Long versionId;
    private Long reviewId;
    private Long reviewVersionId;
    private Long userId;
    private Long userVersionId;
    private String reactionType;
}