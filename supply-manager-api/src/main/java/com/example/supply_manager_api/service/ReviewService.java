package com.example.supply_manager_api.service;

import com.example.supply_manager_api.model.Review;
import com.example.supply_manager_api.repository.ReviewRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ReviewService {

    @Autowired
    private ReviewRepository reviewRepository;

    // Создание нового отзыва
    public Review createReview(Review review) {
        review.setAuthorVersionId(review.getAuthorId());
        review.setTargetVersionId(review.getTargetVersionId());
        review.setObsolete(false);
        return reviewRepository.save(review);
    }

    // Получение всех активных отзывов по ID цели отзыва
    public List<Review> getActiveReviewsByTargetId(Long targetId) {
        return reviewRepository.findActiveReviewsByTargetId(targetId);
    }

    // Получение всех отзывов по ID заказа
    public List<Review> getReviewsByOrderId(Long orderId) {
        return reviewRepository.findReviewsByOrderId(orderId);
    }

    // Получение всех отзывов по ID автора
    public List<Review> getReviewsByAuthorId(Long authorId) {
        return reviewRepository.findReviewsByAuthorId(authorId);
    }

    // Обновление отзыва
    public Review updateReview(Long id, Review updatedReview) {
        return reviewRepository.findById(id).map(review -> {
            review.setObsolete(true); // Помечаем предыдущую версию как устаревшую

            // Создаем новую версию отзыва
            Review newVersion = new Review();
            newVersion.setAuthorId(review.getAuthorId());
            newVersion.setAuthorVersionId(review.getAuthorVersionId());
            newVersion.setTargetId(review.getTargetId());
            newVersion.setTargetVersionId(review.getTargetVersionId());
            newVersion.setOrderId(review.getOrderId());
            newVersion.setOrderVersionId(review.getOrderVersionId());
            newVersion.setRating(updatedReview.getRating());
            newVersion.setComment(updatedReview.getComment());

            return reviewRepository.save(newVersion);
        }).orElseThrow(() -> new RuntimeException("Отзыв не найден"));
    }

    // Удаление отзыва (пометка как устаревший)
    public void deleteReview(Long id) {
        reviewRepository.findById(id).ifPresent(review -> {
            review.setObsolete(true);
            reviewRepository.save(review);
        });
    }
}