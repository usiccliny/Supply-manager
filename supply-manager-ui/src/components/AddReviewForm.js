import React, { useState } from 'react';
import axios from "axios";
import styled from "styled-components";

const FormContainer = styled.form`
  display: flex;
  flex-direction: column;
  gap: 12px; /* Уменьшенные отступы */
  max-width: 400px; /* Ограничение ширины для компактности */
  width: 100%;

  label {
    display: flex;
    flex-direction: column;
    gap: 4px; /* Уменьшенные отступы */
    font-size: 0.9rem; /* Меньший размер текста */
    color: #333; /* Нейтральный цвет текста */
  }

  input[type="number"] {
    padding: 8px;
    border: 1px solid #ddd; /* Более светлая граница */
    border-radius: 4px;
    font-size: 0.9rem; /* Меньший размер текста */
    width: 100px; /* Фиксированная ширина для поля ввода оценки */
    text-align: center; /* Выравнивание текста по центру */
  }

  textarea {
    padding: 8px;
    border: 1px solid #ddd; /* Более светлая граница */
    border-radius: 4px;
    font-size: 0.9rem; /* Меньший размер текста */
    resize: none; /* Отключаем изменение размера textarea */
    height: 80px; /* Фиксированная высота для textarea */
  }

  button {
    padding: 8px 16px;
    background-color: #007bff;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.3s;
    font-size: 0.9rem; /* Меньший размер текста */
    width: auto; /* Автоматическая ширина кнопки */

    &:hover {
      background-color: #0056b3;
    }
  }
`;

const AddReviewForm = ({ orderId, onReviewAdded }) => {
    const [rating, setRating] = useState(5);
    const [comment, setComment] = useState('');

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const response = await axios.post("http://localhost:8080/api/reviews", {
                orderId,
                authorId: localStorage.getItem("userId"),
                authorVersionId: localStorage.getItem("userId"),
                rating,
                comment,
            });
            const newReview = response.data;
            onReviewAdded(newReview);
            setRating(5);
            setComment("");
        } catch (error) {
            console.error("Ошибка при добавлении отзыва:", error);
        }
    };

    return (
        <FormContainer onSubmit={handleSubmit}>
            <label>
                Оценка:
                <input
                    type="number"
                    value={rating}
                    onChange={(e) => setRating(Number(e.target.value))}
                    min="1"
                    max="5"
                />
            </label>
            <label>
                Комментарий:
                <textarea
                    value={comment}
                    onChange={(e) => setComment(e.target.value)}
                    placeholder="Введите ваш комментарий..."
                />
            </label>
            <button type="submit">Оставить отзыв</button>
        </FormContainer>
    );
};

export default AddReviewForm;