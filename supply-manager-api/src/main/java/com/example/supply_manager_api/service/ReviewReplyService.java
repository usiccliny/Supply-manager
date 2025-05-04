package com.example.supply_manager_api.service;

import com.example.supply_manager_api.model.ReviewReply;
import com.example.supply_manager_api.repository.ReviewReplyRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ReviewReplyService {

    @Autowired
    private ReviewReplyRepository reviewReplyRepository;

    // Создание нового ответа на отзыв
    public ReviewReply createReply(ReviewReply reply) {
        reply.setAuthorVersionId(reply.getAuthorId());
        reply.setObsolete(false);
        return reviewReplyRepository.save(reply);
    }

    // Получение всех ответов на конкретный отзыв
    public List<ReviewReply> getRepliesByReviewId(Long reviewId) {
        return reviewReplyRepository.findRepliesByReviewId(reviewId);
    }

    // Получение всех ответов от конкретного автора
    public List<ReviewReply> getRepliesByAuthorId(Long authorId) {
        return reviewReplyRepository.findRepliesByAuthorId(authorId);
    }

    // Обновление ответа
    public ReviewReply updateReply(Long id, ReviewReply updatedReply) {
        return reviewReplyRepository.findById(id).map(reply -> {
            reply.setObsolete(true);

            ReviewReply newVersion = new ReviewReply();
            newVersion.setReviewId(reply.getReviewId());
            newVersion.setReviewVersionId(reply.getReviewVersionId());
            newVersion.setAuthorId(reply.getAuthorId());
            newVersion.setAuthorVersionId(reply.getAuthorVersionId());
            newVersion.setReplyText(updatedReply.getReplyText());

            return reviewReplyRepository.save(newVersion);
        }).orElseThrow(() -> new RuntimeException("Ответ не найден"));
    }

    // Удаление ответа (пометка как устаревший)
    public void deleteReply(Long id) {
        reviewReplyRepository.findById(id).ifPresent(reply -> {
            reply.setObsolete(true);
            reviewReplyRepository.save(reply);
        });
    }
}