// RatingCard.js

import React from 'react';
import styled from 'styled-components';

// Стилизованные компоненты
const Card = styled.div`
  position: relative;
  width: 350px; /* Размер карточки */
  height: 300px; /* Размер карточки */
  border-radius: 8px;
  background: linear-gradient(135deg, #a8dadc, #457b9d); /* Градиентный фон */
  color: #ffffff; /* Белый текст */
  display: flex;
  flex-direction: column;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* Тень для карточки */
`;

const Title = styled.h3`
  margin-top: 0;
  padding: 1rem;
  font-size: 1.2rem;
  text-align: center;
  background-color: rgba(0, 0, 0, 0.1); /* Полупрозрачный фон для заголовка */
  border-bottom: 1px solid rgba(255, 255, 255, 0.2); /* Легкая граница под заголовком */
  border-top-left-radius: 8px;
  border-top-right-radius: 8px;
`;

const ScrollableContent = styled.div`
  flex: 1;
  overflow-y: auto; /* Включаем вертикальный скролл */
  padding: 1rem;
`;

const RatingList = styled.ul`
  list-style-type: none;
  padding: 0;
  margin: 0;
  text-align: left;
`;

const RatingItem = styled.li`
  margin-bottom: 0.5rem;
  font-size: 18px;
  color: #ffffff; /* Белый текст */
`;

const RatingCard = ({ title, data }) => {
  return (
    <Card>
      {/* Название рейтинга */}
      <Title>{title}</Title>

      {/* Прокручиваемое содержимое */}
      <ScrollableContent>
        <RatingList>
          {data.map((item, index) => (
            <RatingItem key={index}>
              <strong>{item.totalRank}. {item.contactPerson}</strong> (Рейтинг: {item.totalRating.toFixed(2)})
            </RatingItem>
          ))}
        </RatingList>
      </ScrollableContent>
    </Card>
  );
};

export default RatingCard;