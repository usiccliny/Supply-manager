import React, { useState } from 'react';
import axios from "axios";
import styled from "styled-components";
import { FaThumbsUp, FaThumbsDown } from 'react-icons/fa';

const ReviewCardContainer = styled.div`
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 16px;
  background: #fff;
  max-width: 600px;
  width: 100%;

  h3 {
    margin: 0;
    font-size: 1rem;
    display: flex;
    align-items: center;
  }

  p {
    margin: 8px 0;
    font-size: 0.9rem;
    color: #555;
    word-break: break-word;
  }

  .actions {
    display: flex;
    gap: 8px;
    margin-top: 8px;

    button {
      padding: 4px 8px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      transition: background-color 0.3s;

      &:hover {
        background-color: #f0f0f0;
      }
    }
  }

  .reply-form {
    margin-top: 8px;
    display: none;
    &.active {
      display: block;
    }

    textarea {
      width: 100%;
      padding: 8px;
      border: 1px solid #ccc;
      border-radius: 4px;
      resize: vertical;
    }

    button {
      margin-top: 8px;
      padding: 8px 16px;
      background-color: #007bff;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      transition: background-color 0.3s;

      &:hover {
        background-color: #0056b3;
      }
    }
  }

  .replies {
    margin-top: 8px;
    display: none;
    &.active {
      display: block;
    }

    div {
      margin-bottom: 8px;
    }
  }
`;

const ReviewCard = ({ review, onReplyAdded, onReactionAdded }) => {
    const [replyText, setReplyText] = useState('');
    const [showReplies, setShowReplies] = useState(false);
    const [showReplyForm, setShowReplyForm] = useState(false);

    const handleReplySubmit = async (e) => {
        e.preventDefault();
        const replyData = {
            reviewId: review.id,
            reviewVersionId: review.versionId,
            authorId: localStorage.getItem('userId'),
            authorVersionId: localStorage.getItem('userId'),
            replyText,
        };
        try {
            const response = await axios.post(`http://localhost:8080/api/review-replies`, replyData);
            const newReply = response.data;
            onReplyAdded(newReply);
            setReplyText('');
            setShowReplyForm(false);
        } catch (error) {
            console.error("Ошибка при добавлении ответа:", error);
        }
    };

    const handleReaction = async (reactionType) => {
        try {
            const reactionData = {
                reviewId: review.id,
                reviewVersionId: review.versionId,
                userId: localStorage.getItem('userId'),
                userVersionId: localStorage.getItem('userId'),
                reactionType,
            };
            await axios.post(`http://localhost:8080/api/review-reactions`, reactionData);
        } catch (error) {
            console.error("Ошибка при отправке реакции:", error);
        }
    };

    return (
        <ReviewCardContainer>
            <h3>{review.rating} ★</h3>
            <p>{review.comment}</p>
            <div className="actions">
                <button onClick={() => handleReaction('like')}><FaThumbsUp /></button>
                <button onClick={() => handleReaction('dislike')}><FaThumbsDown /></button>
            </div>

            <button onClick={() => setShowReplies(!showReplies)}>
              {showReplies ? 'Скрыть ответы' : 'Показать ответы'}
            </button>

            <button onClick={() => setShowReplyForm(!showReplyForm)}>
              {showReplyForm ? 'Скрыть форму ответа' : 'Добавить ответ'}
            </button>

            <form className={`reply-form ${showReplyForm ? 'active' : ''}`} onSubmit={handleReplySubmit}>
                <textarea value={replyText} onChange={(e) => setReplyText(e.target.value)} />
                <button type="submit">Отправить</button>
            </form>

            <div className={`replies ${showReplies ? 'active' : ''}`}>
                {review.replies?.map((reply) => (
                    <div key={reply.reviewVersionId}>{reply.replyText}</div>
                ))}
            </div>
        </ReviewCardContainer>
    );
};

export default ReviewCard;