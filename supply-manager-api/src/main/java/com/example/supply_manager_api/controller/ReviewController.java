package com.example.supply_manager_api.controller;

import com.example.supply_manager_api.model.Review;
import com.example.supply_manager_api.service.ReviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reviews")
public class ReviewController {

    @Autowired
    private ReviewService reviewService;

    // Создание нового отзыва
    @PostMapping
    public ResponseEntity<Review> createReview(@RequestBody Review review) {
        Review createdReview = reviewService.createReview(review);
        return ResponseEntity.ok(createdReview);
    }

    // Получение всех активных отзывов по ID цели отзыва
    @GetMapping("/target/{targetId}")
    public ResponseEntity<List<Review>> getActiveReviewsByTargetId(@PathVariable Long targetId) {
        List<Review> reviews = reviewService.getActiveReviewsByTargetId(targetId);
        return ResponseEntity.ok(reviews);
    }

    // Получение всех отзывов по ID заказа
    @GetMapping("/order/{orderId}")
    public ResponseEntity<List<Review>> getReviewsByOrderId(@PathVariable Long orderId) {
        List<Review> reviews = reviewService.getReviewsByOrderId(orderId);
        return ResponseEntity.ok(reviews);
    }

    // Получение всех отзывов по ID автора
    @GetMapping("/author/{authorId}")
    public ResponseEntity<List<Review>> getReviewsByAuthorId(@PathVariable Long authorId) {
        List<Review> reviews = reviewService.getReviewsByAuthorId(authorId);
        return ResponseEntity.ok(reviews);
    }

    // Обновление отзыва
    @PutMapping("/{id}")
    public ResponseEntity<Review> updateReview(@PathVariable Long id, @RequestBody Review updatedReview) {
        Review updated = reviewService.updateReview(id, updatedReview);
        return ResponseEntity.ok(updated);
    }

    // Удаление отзыва (пометка как устаревший)
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReview(@PathVariable Long id) {
        reviewService.deleteReview(id);
        return ResponseEntity.noContent().build();
    }
}