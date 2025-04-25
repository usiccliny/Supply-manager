// Report.js

import React, { useEffect, useState } from "react";
import styled from "styled-components";
import { ratingsConfig } from "../utils/ratingConfig";
import RatingCard from "./RatingCard";
import axios from "axios";

// Стилизованные компоненты
const Title = styled.h2`
  font-size: 1.5rem;
  margin-bottom: 1rem;
  color: #333;
`;

const Subtitle = styled.p`
  font-size: 1rem;
  margin-bottom: 1.5rem;
  color: #666;
`;

const RatingsGrid = styled.div`
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); /* Адаптивная сетка */
  gap: 1rem; /* Расстояние между элементами */
`;

// Контейнер с отступами
const Container = styled.div`
  padding: 0 2rem; /* Отступы по бокам */
  max-width: 1200px; /* Максимальная ширина контейнера */
  margin: 0 auto; /* Центрирование контейнера */
`;

const Report = () => {
  const [ratingsData, setRatingsData] = useState({});

  // Функция для загрузки данных о рейтингах
  const fetchRatings = async () => {
    try {
      for (const rating of ratingsConfig) {
        const response = await axios.get(rating.endpoint);
        setRatingsData((prevData) => ({
          ...prevData,
          [rating.title]: response.data,
        }));
      }
    } catch (error) {
      console.error("Ошибка загрузки данных:", error);
    }
  };

  useEffect(() => {
    fetchRatings();
  }, []);

  return (
    <Container>
      <Title>Отчеты</Title>
      <Subtitle>Эта информация включает отчеты по заказам и поставкам.</Subtitle>

      {/* Сетка для рейтингов */}
      <RatingsGrid>
        {ratingsConfig.map((rating, index) => (
          <RatingCard
            key={index}
            title={rating.title}
            data={ratingsData[rating.title] || []}
          />
        ))}
      </RatingsGrid>
    </Container>
  );
};

export default Report;