package com.example.supply_manager_api.controller;

import com.example.supply_manager_api.model.ReviewReaction;
import com.example.supply_manager_api.service.ReviewReactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/review-reactions")
public class ReviewReactionController {

    @Autowired
    private ReviewReactionService reviewReactionService;

    // Создание новой реакции на отзыв
    @PostMapping
    public ResponseEntity<ReviewReaction> createReaction(@RequestBody ReviewReaction reaction) {
        ReviewReaction createdReaction = reviewReactionService.createReaction(reaction);
        return ResponseEntity.ok(createdReaction);
    }

    // Получение всех реакций на конкретный отзыв
    @GetMapping("/review/{reviewId}")
    public ResponseEntity<List<ReviewReaction>> getReactionsByReviewId(@PathVariable Long reviewId) {
        List<ReviewReaction> reactions = reviewReactionService.getReactionsByReviewId(reviewId);
        return ResponseEntity.ok(reactions);
    }

    // Получение всех реакций от конкретного пользователя
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<ReviewReaction>> getReactionsByUserId(@PathVariable Long userId) {
        List<ReviewReaction> reactions = reviewReactionService.getReactionsByUserId(userId);
        return ResponseEntity.ok(reactions);
    }

    // Получение реакции пользователя на конкретный отзыв
    @GetMapping("/review/{reviewId}/user/{userId}")
    public ResponseEntity<ReviewReaction> getReactionByReviewIdAndUserId(
            @PathVariable Long reviewId,
            @PathVariable Long userId) {
        ReviewReaction reaction = reviewReactionService.getReactionByReviewIdAndUserId(reviewId, userId);
        return ResponseEntity.ok(reaction);
    }

    // Обновление реакции
    @PutMapping("/{id}")
    public ResponseEntity<ReviewReaction> updateReaction(@PathVariable Long id, @RequestBody ReviewReaction updatedReaction) {
        ReviewReaction updated = reviewReactionService.updateReaction(id, updatedReaction);
        return ResponseEntity.ok(updated);
    }

    // Удаление реакции (пометка как устаревшая)
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReaction(@PathVariable Long id) {
        reviewReactionService.deleteReaction(id);
        return ResponseEntity.noContent().build();
    }
}