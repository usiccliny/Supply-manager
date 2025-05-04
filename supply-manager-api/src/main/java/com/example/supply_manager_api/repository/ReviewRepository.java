package com.example.supply_manager_api.repository;

import com.example.supply_manager_api.model.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {

    // Найти все активные отзывы по ID цели отзыва
    @Query("SELECT r FROM Review r WHERE r.targetId = :targetId AND r.obsolete = false")
    List<Review> findActiveReviewsByTargetId(Long targetId);

    // Найти отзыв по ID заказа
    @Query("SELECT r FROM Review r WHERE r.orderId = :orderId AND r.obsolete = false")
    List<Review> findReviewsByOrderId(Long orderId);

    // Найти отзыв по ID автора
    @Query("SELECT r FROM Review r WHERE r.authorId = :authorId AND r.obsolete = false")
    List<Review> findReviewsByAuthorId(Long authorId);
}