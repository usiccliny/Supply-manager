import React, { useState, useEffect } from 'react';
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
  background: linear-gradient(135deg, rgba(144, 238, 144, 0.8) 0%, rgba(173, 255, 47, 0.6) 100%); /* Градиентный фон */
  border-radius: 8px;
  margin: 1rem 0;
  padding: 1rem;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  max-width: ${(props) => (props.isExpanded ? '100%' : '600px')}; /* Ширина карточек в зависимости от состояния */
  width: 100%;
  transition: transform 0.2s;
  color: #333; /* Цвет текста */

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
  color: #333; /* Цвет текста */
`;

const CompanyWebsite = styled.a`
  color: #0056b3; /* Цвет для ссылок на вебсайты */
  text-decoration: none; 

  &:hover {
    text-decoration: underline; 
  }
`;

const CompanyRating = styled.p`
  margin: 0; 
  font-weight: bold; 
`;

// Стили для пагинации и выбора количества карточек
const PaginationContainer = styled.div`
  display: flex;
  justify-content: space-between;
  margin-top: 2rem;
`;

const PageButton = styled.button`
  margin: 0 0.5rem;
  padding: 0.5rem 1rem;
  cursor: pointer;
  border: none;
  border-radius: 4px;
  background: linear-gradient(135deg, rgba(144, 238, 144, 0.8) 0%, rgba(173, 255, 47, 0.6) 100%);
  color: #333; /* Цвет текста */
  font-weight: bold;
  transition: background 0.3s ease, transform 0.2s ease; 
  
  &:hover {
    background: linear-gradient(135deg, rgba(173, 255, 47, 0.6) 0%, rgba(144, 238, 144, 0.8) 100%);
    transform: scale(1.05); 
  }

  &.active {
    background: linear-gradient(135deg, rgba(173, 255, 47, 0.6) 0%, rgba(144, 238, 144, 0.8) 100%);
    color: white; 
  }
`;

const SelectItemsPerPage = styled.select`
  padding: 0.5rem;
  margin-left: auto;
  border-radius: 4px;
  border: none;
  background: linear-gradient(135deg, rgba(144, 238, 144, 0.8) 0%, rgba(173, 255, 47, 0.6) 100%);
  color: #333; 

  &:hover {
    background: linear-gradient(135deg, rgba(173, 255, 47, 0.6) 0%, rgba(144, 238, 144, 0.8) 100%);
  }

  &:focus {
    outline: none; 
    box-shadow: 0 0 5px rgba(173, 255, 47, 0.6); 
  }
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
  const [isExpanded, setIsExpanded] = useState(false); 
  const [isActive, setIsActive] = useState(false);
  const [companies, setCompanies] = useState([]); 
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [currentPage, setCurrentPage] = useState(1); // Текущая страница
  const [itemsPerPage, setItemsPerPage] = useState(10); // Количество карточек на странице

  const toggleExpansion = () => {
    setIsExpanded((prev) => !prev);
    setIsActive(true);
    setTimeout(() => setIsActive(false), 300);
  };

  const fetchCompanies = async () => {
    try {
      const response = await fetch('http://localhost:8080/api/companies');
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      const data = await response.json();
      setCompanies(data);
    } catch (error) {
      setError(`Ошибка при загрузке данных: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCompanies();
  }, []);

  const handleItemsPerPageChange = (e) => {
    setItemsPerPage(Number(e.target.value));
    setCurrentPage(1); // Сброс текущей страницы при изменении количества карточек на странице
  };

  const handlePageChange = (page) => {
    setCurrentPage(page);
  };

  // Расчет индексов для текущей страницы
  const indexOfLastCompany = currentPage * itemsPerPage;
  const indexOfFirstCompany = indexOfLastCompany - itemsPerPage;
  const currentCompanies = companies.slice(indexOfFirstCompany, indexOfLastCompany);

  const totalPages = Math.ceil(companies.length / itemsPerPage); // Общее количество страниц

  if (loading) return <p>Загрузка...</p>;
  if (error) return <p>{error}</p>;

  return (
    <DashboardContainer>
      <h1>Добро пожаловать в систему управления закупками!</h1>
      <p>Здесь вы можете управлять всеми своими заказами и поставками.</p>
      <ToggleButton onClick={toggleExpansion} className={isActive ? 'active' : ''}>
        <Icon className={`fas fa-expand-arrows-alt`} />
      </ToggleButton>
      {currentCompanies.map((company) => (
        <Company
          key={company.id} 
          logo={company.logotype || 'https://via.placeholder.com/80'} 
          name={company.name}
          website={company.website}
          rating={company.rating}
          isExpanded={isExpanded} 
        />
      ))}
      <PaginationContainer>
        <div>
          {Array.from({ length: totalPages }, (_, i) => i + 1).map(page => (
            <PageButton 
              key={page} 
              onClick={() => handlePageChange(page)} 
              className={currentPage === page ? 'active' : ''}>
              {page}
            </PageButton>
          ))}
        </div>
        <SelectItemsPerPage onChange={handleItemsPerPageChange} value={itemsPerPage}>
          <option value={10}>10</option>
          <option value={15}>15</option>
          <option value={20}>20</option>
        </SelectItemsPerPage>
      </PaginationContainer>
    </DashboardContainer>
  );
};

export default Dashboard;