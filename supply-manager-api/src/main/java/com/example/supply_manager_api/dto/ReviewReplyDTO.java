package com.example.supply_manager_api.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ReviewReplyDTO {
    private Long id;
    private Long versionId;
    private Long reviewId;
    private Long reviewVersionId;
    private Long authorId;
    private Long authorVersionId;
    private String replyText;
}