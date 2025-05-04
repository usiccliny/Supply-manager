import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import axios from "axios";
import styled from "styled-components";
import ReviewCard from "./ReviewCard";
import AddReviewForm from "./AddReviewForm";

const CardContainer = styled.div`
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 16px;
  margin: 16px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  background: #fff;

  h2 {
    font-size: 1.5rem;
    margin-bottom: 16px;
  }

  p {
    margin: 8px 0;
    font-size: 1rem;
    color: #555;
  }

  ul {
    list-style-type: none;
    padding-left: 0;
    margin: 0;
  }

  li {
    margin-bottom: 8px;
  }

  .reviews-section {
    margin-top: 24px; /* Отступ между формой и отзывами */
    border-top: 1px solid #ddd;
    padding-top: 16px;
  }

  .show-all-button {
    margin-top: 16px; /* Отступ для кнопки "Показать все комментарии" */
    text-align: center;
  }
`;

const Title = styled.h2`
  font-size: 1.5rem;
  margin-bottom: 16px;
`;

const Detail = styled.p`
  margin: 8px 0;
  font-size: 1rem;
  color: #555;
`;

const OrderCard = () => {
  const { orderId } = useParams();
  const [orderDetails, setOrderDetails] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const userRole = parseInt(localStorage.getItem("userRole"), 10);
  const [reviews, setReviews] = useState([]);
  const [showAllComments, setShowAllComments] = useState(false);

  const fetchReviews = async () => {
    try {
      const response = await axios.get(`http://localhost:8080/api/reviews/order/${orderId}`);
      const loadedReviews = response.data;

      const reviewsWithReplies = await Promise.all(
        loadedReviews.map(async (review) => {
          const repliesResponse = await axios.get(
            `http://localhost:8080/api/review-replies/review/${review.id}`
          );
          return {
            ...review,
            replies: repliesResponse.data || [],
          };
        })
      );

      setReviews(reviewsWithReplies);
    } catch (err) {
      console.error("Ошибка при загрузке отзывов:", err);
    }
  };

  const handleReplyAdded = (newReply) => {
    setReviews((prevReviews) =>
      prevReviews.map((review) =>
        review.id === newReply.reviewId
          ? { ...review, replies: [...(review.replies || []), newReply] }
          : review
      )
    );
  };

  const handleReactionAdded = (newReaction) => {
    setReviews((reviews) =>
      reviews.map((review) =>
        review.id === newReaction.reviewId
          ? { ...review, reactions: [...(review.reactions || []), newReaction] }
          : review
      )
    );
  };

  const handleReviewAdded = (newReview) => {
    setReviews((reviews) => [newReview, ...reviews]);
  };

  const fetchOrderDetails = async () => {
    try {
      const response = await axios.get(`http://localhost:8080/api/orders/${orderId}`, {
        params: { role: userRole },
      });
      setOrderDetails(response.data);
    } catch (err) {
      setError("Ошибка при загрузке данных");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrderDetails();
    fetchReviews();
  }, [orderId]);

  if (loading) {
    return <p>Загрузка...</p>;
  }

  if (error) {
    return <p>{error}</p>;
  }

  if (!orderDetails || orderDetails.length === 0) {
    return <p>Заказ не найден.</p>;
  }

  const totalAmount = orderDetails.reduce((sum, item) => sum + item.price * item.quantity, 0);

  return (
    <CardContainer>
      <Title>Детали заказа #{orderId}</Title>

      <Detail>Сумма: {totalAmount} ₽</Detail>

      {userRole === 4 && (
        <Detail>
          Покупатель: {orderDetails[0].contactPerson} ({orderDetails[0].contactData})
        </Detail>
      )}
      {userRole === 3 && (
        <Detail>
          Поставщик: {orderDetails[0].contactPerson} ({orderDetails[0].contactData})
        </Detail>
      )}

      <Detail>Товары:</Detail>
      <ul>
        {orderDetails.map((item) => (
          <li key={item.orderDetailId}>
            {item.productName} - {item.quantity} шт. ({item.price} ₽)
          </li>
        ))}
      </ul>

      <div className="reviews-section">
        <h2>Отзывы</h2>
        <AddReviewForm orderId={orderId} onReviewAdded={handleReviewAdded} />

        <div className="show-all-button">
          <button onClick={() => setShowAllComments(!showAllComments)}>
            {showAllComments ? "Скрыть все комментарии" : "Показать все комментарии"}
          </button>
        </div>

        {showAllComments ? (
          reviews.map((review) => (
            <ReviewCard
              key={review.id}
              review={review}
              onReplyAdded={handleReplyAdded}
              onReactionAdded={handleReactionAdded}
            />
          ))
        ) : (
          <p>Отзывов пока нет.</p>
        )}
      </div>
    </CardContainer>
  );
};

export default OrderCard;