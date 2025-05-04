package com.example.supply_manager_api.service;

import com.example.supply_manager_api.model.ReviewReaction;
import com.example.supply_manager_api.repository.ReviewReactionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ReviewReactionService {

    @Autowired
    private ReviewReactionRepository reviewReactionRepository;

    // Создание новой реакции на отзыв
    public ReviewReaction createReaction(ReviewReaction reaction) {
        reaction.setUserVersionId(reaction.getUserId());
        reaction.setObsolete(false);
        return reviewReactionRepository.save(reaction);
    }

    // Получение всех реакций на конкретный отзыв
    public List<ReviewReaction> getReactionsByReviewId(Long reviewId) {
        return reviewReactionRepository.findReactionsByReviewId(reviewId);
    }

    // Получение всех реакций от конкретного пользователя
    public List<ReviewReaction> getReactionsByUserId(Long userId) {
        return reviewReactionRepository.findReactionsByUserId(userId);
    }

    // Получение реакции пользователя на конкретный отзыв
    public ReviewReaction getReactionByReviewIdAndUserId(Long reviewId, Long userId) {
        return reviewReactionRepository.findReactionByReviewIdAndUserId(reviewId, userId);
    }

    // Обновление реакции
    public ReviewReaction updateReaction(Long id, ReviewReaction updatedReaction) {
        return reviewReactionRepository.findById(id).map(reaction -> {
            reaction.setObsolete(true); // Помечаем предыдущую версию как устаревшую

            // Создаем новую версию реакции
            ReviewReaction newVersion = new ReviewReaction();
            newVersion.setReviewId(reaction.getReviewId());
            newVersion.setReviewVersionId(reaction.getReviewVersionId());
            newVersion.setUserId(reaction.getUserId());
            newVersion.setUserVersionId(reaction.getUserVersionId());
            newVersion.setReactionType(updatedReaction.getReactionType());
            newVersion.setBeginTs(LocalDateTime.now());
            newVersion.setEndTs(LocalDateTime.MAX);
            newVersion.setObsolete(false);

            return reviewReactionRepository.save(newVersion);
        }).orElseThrow(() -> new RuntimeException("Реакция не найдена"));
    }

    public void deleteReaction(Long id) {
        reviewReactionRepository.findById(id).ifPresent(reaction -> {
            reaction.setObsolete(true);
            reviewReactionRepository.save(reaction);
        });
    }
}