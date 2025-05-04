package com.example.supply_manager_api.repository;

import com.example.supply_manager_api.model.ReviewReply;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReviewReplyRepository extends JpaRepository<ReviewReply, Long> {

    // Найти все ответы на отзыв по ID отзыва
    @Query("SELECT rr FROM ReviewReply rr WHERE rr.reviewId = :reviewId AND rr.obsolete = false")
    List<ReviewReply> findRepliesByReviewId(Long reviewId);

    // Найти ответы на отзыв по ID автора
    @Query("SELECT rr FROM ReviewReply rr WHERE rr.authorId = :authorId AND rr.obsolete = false")
    List<ReviewReply> findRepliesByAuthorId(Long authorId);
}