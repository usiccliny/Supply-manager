import React, { useState, useEffect, useContext } from "react";
import styled from "styled-components";
import { ratingsConfig } from "../utils/ratingConfig";
import RatingCard from "./RatingCard";
import useCategories from "../utils/useCategories";
import { DateContext } from "../DateContext";

const Container = styled.div`
  padding: 0 2rem;
  max-width: 1200px;
  margin: 0 auto;
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
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 2rem;
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
  const { selectedDate } = useContext(DateContext); 

  // Функция для загрузки данных рейтинга
  const fetchRatings = async (endpoint, key) => {
    try {
      const response = await fetch(endpoint);
      if (!response.ok) {
        throw new Error(`Ошибка загрузки данных: ${response.statusText}`);
      }
      const data = await response.json();
      setRatingsData((prevData) => ({
        ...prevData,
        [key]: data,
      }));
    } catch (error) {
      console.error("Ошибка загрузки данных:", error);
    }
  };

  // Обработчик изменения категории
  const handleCategoryChange = (event) => {
    const category = event.target.value;
    setSelectedCategory(category);

    const productRatingConfig = ratingsConfig.find(
      (rating) => rating.title === "Рейтинг популярности товаров"
    );
    if (productRatingConfig && typeof productRatingConfig.endpoint === "function") {
      const endpoint = productRatingConfig.endpoint(category);
      fetchRatings(`${endpoint}&date=${selectedDate.toISOString().split("T")[0]}`, productRatingConfig.title);
    }
  };

  // Загрузка данных при изменении даты
  useEffect(() => {
    const loadRatings = () => {
      ratingsConfig.forEach((rating) => {
        let endpoint;

        if (typeof rating.endpoint === "string") {
          // Если эндпоинт - строка, добавляем параметр даты
          endpoint = `${rating.endpoint}?date=${selectedDate.toISOString().split("T")[0]}`;
        } else if (selectedCategory && typeof rating.endpoint === "function") {
          // Если эндпоинт - функция, вызываем её с категорией и добавляем дату
          endpoint = `${rating.endpoint(selectedCategory)}&date=${selectedDate.toISOString().split("T")[0]}`;
        }

        if (endpoint) {
          fetchRatings(endpoint, rating.title);
        }
      });
    };

    loadRatings();
  }, [selectedDate, selectedCategory]);

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

      {/* Выбор категории */}
      <CategorySelector onChange={handleCategoryChange}>
        <option value="">Выберите категорию</option>
        {categories.map((category) => (
          <option key={category.id} value={category.name}>
            {category.name}
          </option>
        ))}
      </CategorySelector>

      {/* Отображение рейтингов */}
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