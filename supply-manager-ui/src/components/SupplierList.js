import React, { useEffect, useState } from 'react';
import axios from 'axios';
import styled from 'styled-components';
import { useLocation } from 'react-router-dom';
import ProductRegistry from './ProductRegistry';

const SupplierListContainer = styled.div`
  padding: 2rem;
  display: flex;
  flex-direction: column; 
  align-items: flex-start; 
`;

const Widget = styled.div`
  width: 50%; 
  margin: 1.5rem 0; 
  padding: 1.5rem;
  border-radius: 10px;
  color: #333; 
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
  cursor: pointer;
  transition: transform 0.3s, box-shadow 0.3s;

  &.current {
    background: linear-gradient(135deg, rgba(144, 238, 144, 0.8) 0%, rgba(173, 255, 47, 0.6) 100%);
  }

  &.noData {
    background: linear-gradient(135deg, rgba(255, 99, 71, 0.8) 0%, rgba(255, 159, 128, 0.6) 100%);
  }

  &:hover {
    transform: translateY(-5px);
    box-shadow: 0 6px 30px rgba(0, 0, 0, 0.2);
  }
`;

const SupplierItem = styled.li`
  margin-bottom: 1rem;
  padding: 1rem;
  border-radius: 5px;
  background: #fff;  
  color: #333; 
  transition: transform 0.2s;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1); 
  border: 1px solid rgba(0, 0, 0, 0.2);
  
  &:hover {
    transform: scale(1.02);
  }
`;

const Role4Widget = styled.div`
  width: 300px; // Компактный размер
  margin: 1rem;
  padding: 1rem;
  border-radius: 10px;
  color: #333;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
  background: #f9f9f9; // Светлый фон
  font-size: 0.9rem; // Меньший текст
  position: fixed; // Фиксированное положение
  top: 80px; // Под шапкой
  right: 20px; // Справа
  z-index: 10; // Чтобы был поверх других элементов
`;

const MetricBox = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 0.8rem;
  margin: 0.5rem 0;
  border-radius: 8px;
  color: #fff;
  font-size: 0.9rem;
  font-weight: bold;
  text-align: center;

  &.available {
    background: #a8dadc; // Спокойный голубой
  }

  &.ended {
    background: #ffafcc; // Спокойный розовый
  }

  &.coming {
    background: #ffd6a5; // Спокойный оранжевый
  }
`;

const SupplierList = () => {
  const [products, setProducts] = useState([]); // Все товары
  const [filteredProducts, setFilteredProducts] = useState([]); // Отфильтрованные товары
  const [activeFilter, setActiveFilter] = useState('all'); // Активный фильтр

  const location = useLocation();
  const [suppliers, setSuppliers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [openWidget, setOpenWidget] = useState(null);
  const userId = localStorage.getItem('userId');
  const userRole = parseInt(localStorage.getItem('userRole'), 10); // Получаем роль пользователя

  const [supplierWidgetData, setSupplierWidgetData] = useState([]);

  // Получаем параметры URL
  const searchParams = new URLSearchParams(location.search);
  const index = searchParams.get('index'); // Получаем индекс

  useEffect(() => {
    const fetchSuppliers = async () => {
      if (!userId) {
        setError('User ID is not available.');
        setLoading(false);
        return;
      }

      try {
        const response = await axios.get(`http://localhost:8080/api/suppliers`);
        setSuppliers(response.data);
      } catch (err) {
        console.error(err);
        setError('Failed to fetch suppliers.');
      } finally {
        setLoading(false);
      }
    };

    fetchSuppliers();
  }, [userId]);

  useEffect(() => {
    const fetchSupplierWidgetData = async () => {
      try {
        const response = await axios.get('http://localhost:8080/api/suppliers/supplierWidget');
        const filteredData = response.data.filter(item => item.userId === parseInt(userId));
        setSupplierWidgetData(filteredData);
      } catch (err) {
        console.error(err);
        setError('Failed to fetch supplier widget data.');
      }
    };
  
    if (userRole === 4) {
      fetchSupplierWidgetData();
    }
  }, [userId, userRole]);

  const currentSuppliers = suppliers.filter(supplier => supplier.userId === parseInt(userId));
  const noDataSuppliers = suppliers.filter(supplier => supplier.userId === null);

  // Фильтрация товаров
  const handleFilterChange = (status) => {
    setActiveFilter(status);
    if (status === 'all') {
      setFilteredProducts(products); // Показать все товары
    } else {
      const filtered = products.filter((product) => product.statusProduct === status);
      setFilteredProducts(filtered); // Показать товары только с выбранным статусом
    }
  };

  useEffect(() => {
    if (currentSuppliers.length > 0 && index) {
      setOpenWidget('current'); // Открываем виджет
      // Прокручиваем к выбранному поставщику
      const targetSupplierId = `supplier-${index}`;
      const targetElement = document.getElementById(targetSupplierId);
      if (targetElement) {
        targetElement.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    }
  }, [currentSuppliers, index]);

  if (loading) {
    return <div>Загрузка...</div>;
  }

  if (error) {
    return <div>{error}</div>;
  }

  // Если роль пользователя равна 4, отображаем только виджет для роли 4
  if (userRole === 4) {
    return (
      <SupplierListContainer>
        <Role4Widget>
          <h3>Статистика поставщиков</h3>
          {supplierWidgetData.length > 0 ? (
            <ul>
              {supplierWidgetData.map((item, idx) => (
                <li key={idx} style={{ marginBottom: '1rem' }}>
                  <p><strong>ID поставщика:</strong> {item.supplierId}</p>
                  <MetricBox className="available">
                    <p>Всего товаров:</p>
                    <p>{item.totalProductCnt}</p>
                  </MetricBox>
                  <MetricBox className="available">
                    <p>Доступно товаров:</p>
                    <p>{item.availableProductCnt}</p>
                  </MetricBox>
                  <MetricBox className="ended">
                    <p>Закончилось товаров:</p>
                    <p>{item.endedProductCnt}</p>
                  </MetricBox>
                  <MetricBox className="coming">
                    <p>Ожидающих товаров:</p>
                    <p>{item.comingProductCnt}</p>
                  </MetricBox>
                </li>
              ))}
            </ul>
          ) : (
            <p>Нет данных для отображения.</p>
          )}
        </Role4Widget>

        <ProductRegistry
          filteredProducts={filteredProducts}
          activeFilter={activeFilter}
          onFilterChange={handleFilterChange}
        />
        
      </SupplierListContainer>
    );
  }

  return (
    <SupplierListContainer>
      <h2 style={{ marginBottom: '1rem' }}>Список поставщиков</h2>

      <Widget className="current" onClick={() => setOpenWidget(openWidget === 'current' ? null : 'current')}>
        <h3>Поставщики, имеющие связь: {currentSuppliers.length}</h3>
        {openWidget === 'current' && (
          <ul>
            {currentSuppliers.map((supplier, idx) => (
              <SupplierItem key={supplier.supplierId} id={`supplier-${idx}`} widgetType="current">
                <h3>{supplier.companyName}</h3>
                <p><strong>Контактное лицо:</strong> {supplier.contactPerson}</p>
                <p><strong>Телефон:</strong> {supplier.phoneNumber}</p>
                <p><strong>Email:</strong> {supplier.email}</p>
                <p><strong>Адрес:</strong> {supplier.address}</p>
                <p><strong>Должность:</strong> {supplier.postName} ({supplier.postShortName})</p>
              </SupplierItem>
            ))}
          </ul>
        )}
      </Widget>

      <Widget className="noData" onClick={() => setOpenWidget(openWidget === 'noData' ? null : 'noData')}>
        <h3>Поставщики с отсутствующим userId: {noDataSuppliers.length}</h3>
        {openWidget === 'noData' && (
          <ul>
            {noDataSuppliers.map(supplier => (
              <SupplierItem key={supplier.supplierId} widgetType="noData">
                <h3>{supplier.companyName}</h3>
                <p><strong>Контактное лицо:</strong> {supplier.contactPerson}</p>
                <p><strong>Телефон:</strong> {supplier.phoneNumber}</p>
                <p><strong>Email:</strong> {supplier.email}</p>
                <p><strong>Адрес:</strong> {supplier.address}</p>
                <p><strong>Должность:</strong> {supplier.postName} ({supplier.postShortName})</p>
              </SupplierItem>
            ))}
          </ul>
        )}
      </Widget>
    </SupplierListContainer>
  );
};

export default SupplierList;