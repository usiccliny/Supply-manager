package com.example.supply_manager_api.repository;

import com.example.supply_manager_api.model.ReviewReaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReviewReactionRepository extends JpaRepository<ReviewReaction, Long> {

    // Найти все реакции на отзыв по ID отзыва
    @Query("SELECT rr FROM ReviewReaction rr WHERE rr.reviewId = :reviewId AND rr.obsolete = false")
    List<ReviewReaction> findReactionsByReviewId(Long reviewId);

    // Найти реакции пользователя по ID пользователя
    @Query("SELECT rr FROM ReviewReaction rr WHERE rr.userId = :userId AND rr.obsolete = false")
    List<ReviewReaction> findReactionsByUserId(Long userId);

    // Найти реакцию пользователя на конкретный отзыв
    @Query("SELECT rr FROM ReviewReaction rr WHERE rr.reviewId = :reviewId AND rr.userId = :userId AND rr.obsolete = false")
    ReviewReaction findReactionByReviewIdAndUserId(Long reviewId, Long userId);
}