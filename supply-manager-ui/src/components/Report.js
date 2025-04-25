// Report.js

import React, { useState, useEffect } from "react";
import styled from "styled-components";
import { ratingsConfig } from "../utils/ratingConfig";
import RatingCard from "./RatingCard";
import useCategories from "../utils/useCategories";

const Container = styled.div`
  padding: 0 2rem; /* Отступы по бокам */
  max-width: 1200px; /* Максимальная ширина контейнера */
  margin: 0 auto; /* Центрирование контейнера */
`;

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
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); /* Минимальный размер 300px */
  gap: 2rem; /* Увеличенные отступы между элементами */
`;

const CategorySelector = styled.select`
  margin-bottom: 1rem;
  padding: 0.5rem;
  border-radius: 4px;
  border: 1px solid #ddd;
  font-size: 1rem;
`;

const Report = () => {
  const { categories, loading, error } = useCategories();
  const [selectedCategory, setSelectedCategory] = useState(null);
  const [ratingsData, setRatingsData] = useState({});

  const fetchRatings = async (endpoint, key) => {
    try {
      const response = await fetch(endpoint);
      const data = await response.json();
      setRatingsData((prevData) => ({
        ...prevData,
        [key]: data,
      }));
    } catch (error) {
      console.error("Ошибка загрузки данных:", error);
    }
  };

  const handleCategoryChange = (event) => {
    const category = event.target.value;
    setSelectedCategory(category);

    const productRatingConfig = ratingsConfig.find((rating) => rating.title === "Рейтинг популярности товаров");
    if (productRatingConfig) {
      const endpoint = productRatingConfig.endpoint(category);
      fetchRatings(endpoint, productRatingConfig.title);
    }
  };

  useEffect(() => {
    ratingsConfig.forEach((rating) => {
      if (typeof rating.endpoint === "string") {
        fetchRatings(rating.endpoint, rating.title);
      }
    });
  }, []);

  if (loading) {
    return <p>Загрузка категорий...</p>;
  }

  if (error) {
    return <p>{error}</p>;
  }

  return (
    <Container>
      <Title>Отчеты</Title>
      <Subtitle>Эта информация включает отчеты по заказам и поставкам.</Subtitle>

      <CategorySelector onChange={handleCategoryChange}>
        <option value="">Выберите категорию</option>
        {categories.map((category) => (
          <option key={category.id} value={category.name}>
            {category.name}
          </option>
        ))}
      </CategorySelector>

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