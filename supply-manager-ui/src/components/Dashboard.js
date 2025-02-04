import React, { useState } from 'react';
import styled, { keyframes } from 'styled-components';

// Стили для контейнера панели управления
const DashboardContainer = styled.div`
  position: relative; /* Для позиционирования кнопки */
  padding: 2rem;
`;

// Стили для анимации
const expandAnimation = keyframes`
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(135deg); /* Угол поворота кнопки при активном состоянии */
  }
`;

// Стили для кнопки переключения
const ToggleButton = styled.button`
  position: absolute;
  top: 1rem; /* От верхнего края */
  right: 1rem; /* От правого края */
  padding: 0; /* Убираем отступы для кнопки */
  background: none; /* Без фона */
  border: none; /* Без рамки */
  cursor: pointer;
  outline: none; /* Убираем обводку */
  
  &:hover {
    opacity: 0.8; /* Уменьшаем непрозрачность при наведении */
  }

  &.active {
    animation: ${expandAnimation} 0.3s linear forwards; /* Анимация при активном состоянии */
  }
`;

// Стили для иконки
const Icon = styled.i`
  font-size: 30px; /* Устанавливаем размер иконки */
  transition: transform 0.3s ease; /* Плавный переход для анимации */
`;

// Стили для карточки компании
const CompanyCard = styled.div`
  display: flex;
  background-color: #f9f9f9;
  border: 1px solid #ddd;
  border-radius: 8px;
  margin: 1rem 0;
  padding: 1rem;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  max-width: ${(props) => (props.isExpanded ? '100%' : '600px')}; /* Ширина карточек в зависимости от состояния */
  width: 100%;
  transition: transform 0.2s;

  &:hover {
    transform: scale(1.02);
  }
`;

// Стили для логотипа компании
const Logo = styled.img`
  width: 80px;
  height: 80px;
  border-radius: 5px;
`;

// Стили для информации о компании
const InfoContainer = styled.div`
  display: flex;
  flex-direction: column; 
  justify-content: center; 
  padding-left: 1rem; 
`;

// Стили для заголовка и других текстов
const CompanyName = styled.h3`
  margin: 0 0 0.25rem 0;
  font-size: 1.5rem; 
`;

const CompanyWebsite = styled.a`
  color: #007bff; 
  text-decoration: none; 

  &:hover {
    text-decoration: underline; 
  }
`;

const CompanyRating = styled.p`
  margin: 0; 
  font-weight: bold; 
`;

// Компонент карточки компании
const Company = ({ logo, name, website, rating, isExpanded }) => (
  <CompanyCard isExpanded={isExpanded}>
    <Logo src={logo} alt={`${name} logo`} />
    <InfoContainer>
      <CompanyName>{name}</CompanyName>
      <CompanyWebsite href={website} target="_blank" rel="noopener noreferrer">
        {website}
      </CompanyWebsite>
      <CompanyRating>Рейтинг: {rating}</CompanyRating>
    </InfoContainer>
  </CompanyCard>
);

// Основной компонент Dashboard
const Dashboard = () => {
  const [isExpanded, setIsExpanded] = useState(false); // Состояние для управления режимом
  const [isActive, setIsActive] = useState(false); // Состояние для анимации кнопки

  const toggleExpansion = () => {
    setIsExpanded((prev) => !prev); // Переключаем состояние
    setIsActive(true); // Активируем анимацию

    // Убираем анимацию через 300 мс
    setTimeout(() => setIsActive(false), 300);
  };

  const companies = [
    {
      logo: 'https://via.placeholder.com/80',
      name: 'Компания A',
      website: 'https://www.companya.com',
      rating: 4.8,
    },
    {
      logo: 'https://via.placeholder.com/80',
      name: 'Компания B',
      website: 'https://www.companyb.com',
      rating: 4.2,
    },
    {
      logo: 'https://via.placeholder.com/80',
      name: 'Компания C',
      website: 'https://www.companyc.com',
      rating: 3.9,
    },
    {
      logo: 'https://via.placeholder.com/80',
      name: 'Компания D',
      website: 'https://www.companyd.com',
      rating: 4.6,
    },
    {
      logo: 'https://via.placeholder.com/80',
      name: 'Компания E',
      website: 'https://www.companye.com',
      rating: 4.0,
    },
    {
      logo: 'https://via.placeholder.com/80',
      name: 'Компания F',
      website: 'https://www.companyf.com',
      rating: 4.3,
    },
  ];

  return (
    <DashboardContainer>
      <h1>Добро пожаловать в систему управления закупками!</h1>
      <p>Здесь вы можете управлять всеми своими заказами и поставками.</p>
      <ToggleButton onClick={toggleExpansion} className={isActive ? 'active' : ''}>
        <Icon className={`fas fa-expand-arrows-alt`} />
      </ToggleButton>
      {companies.map((company, index) => (
        <Company
          key={index}
          logo={company.logo}
          name={company.name}
          website={company.website}
          rating={company.rating}
          isExpanded={isExpanded} // Передаем в карточку как вспомогательный проп
        />
      ))}
    </DashboardContainer>
  );
};

export default Dashboard;