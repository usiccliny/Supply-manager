package com.example.supply_manager_api.controller;

import com.example.supply_manager_api.model.ReviewReply;
import com.example.supply_manager_api.service.ReviewReplyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/review-replies")
public class ReviewReplyController {

    @Autowired
    private ReviewReplyService reviewReplyService;

    // Создание нового ответа на отзыв
    @PostMapping
    public ResponseEntity<ReviewReply> createReply(@RequestBody ReviewReply reply) {
        ReviewReply createdReply = reviewReplyService.createReply(reply);
        return ResponseEntity.ok(createdReply);
    }

    // Получение всех ответов на конкретный отзыв
    @GetMapping("/review/{reviewId}")
    public ResponseEntity<List<ReviewReply>> getRepliesByReviewId(@PathVariable Long reviewId) {
        List<ReviewReply> replies = reviewReplyService.getRepliesByReviewId(reviewId);
        return ResponseEntity.ok(replies);
    }

    // Получение всех ответов от конкретного автора
    @GetMapping("/author/{authorId}")
    public ResponseEntity<List<ReviewReply>> getRepliesByAuthorId(@PathVariable Long authorId) {
        List<ReviewReply> replies = reviewReplyService.getRepliesByAuthorId(authorId);
        return ResponseEntity.ok(replies);
    }

    // Обновление ответа
    @PutMapping("/{id}")
    public ResponseEntity<ReviewReply> updateReply(@PathVariable Long id, @RequestBody ReviewReply updatedReply) {
        ReviewReply updated = reviewReplyService.updateReply(id, updatedReply);
        return ResponseEntity.ok(updated);
    }

    // Удаление ответа (пометка как устаревший)
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReply(@PathVariable Long id) {
        reviewReplyService.deleteReply(id);
        return ResponseEntity.noContent().build();
    }
}