import React, { useEffect, useState } from 'react';
import axios from 'axios';
import styled from 'styled-components';
import { SlArrowDown, SlArrowUp } from "react-icons/sl";
import CategoryOrderList from './CategoryOrderList';

// Стили компонентов
const OrderListContainer = styled.div`
  padding: 2rem;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  max-width: 1200px;
  margin: 0 auto;
`;

const OrderRegistryWidget = styled.div`
  width: 100%;
  max-width: 1200px; // Увеличение ширины виджета
  padding: 1.5rem;
  border-radius: 10px;
  color: #333;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
  background: #f9f9f9;

  /* Если нужно зафиксировать виджет в левой части экрана */
  position: fixed;
  left: 30px; // Фиксированный отступ слева
`;  

const FiltersContainer = styled.div`
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
  justify-content: space-between;
`;

const FilterButton = styled.div`
  width: auto; // Автоматическая ширина
  margin: 0.5rem;
  padding: 1rem;
  border-radius: 5px;
  background: #fff; // Белый фон
  color: #333; // Темный текст
  transition: transform 0.3s, box-shadow 0.3s;

  &.active {
    background: linear-gradient(135deg, rgba(144, 238, 144, 0.8) 0%, rgba(173, 255, 47, 0.6) 100%);
  }

  &:hover {
    transform: translateY(-5px);
    box-shadow: 0 6px 30px rgba(0, 0, 0, 0.2);
  }
`;

const PaginationControls = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1rem;
`;

const PageButton = styled.button`
  padding: 0.4rem 0.8rem; // Уменьшенные размеры кнопок
  font-size: 0.8rem;
  color: #fff;
  border: none;
  border-radius: 5px;
  background: #457b9d;
  cursor: pointer;
  transition: transform 0.3s, box-shadow 0.3s;

  &:hover {
    transform: scale(1.05);
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
  }

  &.disabled {
    background: #ccc;
    cursor: not-allowed;
  }
`;

const ItemsPerPageSelector = styled.select`
  padding: 0.22rem;
  font-size: 0.8rem;
  border: 1px solid #ccc;
  border-radius: 5px;
  background: #fff;
  cursor: pointer;
`;

const OrderTable = styled.table`
  width: 100%;
  border-collapse: collapse;

  th,
  td {
    padding: 0.6rem;
    text-align: left;
    border-bottom: 1px solid #ddd;
  }

  th {
    background: #f4f4f4;
    font-weight: bold;
  }

  tr:hover {
    background: #f9f9f9;
  }
`;

const StatWidget = styled.div`
  width: 300px;
  margin: 1rem;
  padding: 1rem;
  border-radius: 10px;
  color: #333;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
  background: #f9f9f9;
  font-size: 0.9rem;
  position: fixed;
  top: 80px;
  right: 20px;
  z-index: 10;
  transition: height 0.3s ease; // Плавное изменение высоты
  overflow: hidden; // Скрываем содержимое при уменьшении высоты
`;

const ToggleButton = styled.button`
  margin-bottom: 0.01rem;
  padding: 0.5rem 1.0rem;
  font-size: 1.2rem; // Размер иконки
  color: #457b9d;
  background: transparent;
  border: none;
  cursor: pointer;
  transition: transform 0.3s;

  &:hover {
    transform: scale(1.1);
  }
`;

const MetricBox = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 0.01rem; // Уменьшенный padding
  margin: 0.01rem 0; // Уменьшенный margin
  border-radius: 8px;
  color: #fff;
  font-size: 0.85rem; // Увеличенный текст
  font-weight: bold;
  text-align: center;

  &.pending {
    background: #ffafcc; // Розовый
  }

  &.paid {
    background: #a8dadc; // Голубой
  }

  &.processing {
    background: #ffd6a5; // Оранжевый
  }

  &.delivered {
    background: #c7f9cc; // Светло-зеленый
  }

  &.cancelled {
    background: #ff9aa2; // Красный
  }

  &.return {
    background: #b5eada; // Бирюзовый
  }

  &.total {
    background: #457b9d; // Синий для общей суммы
  }
`;

const OrderListPage = () => {
  const [orders, setOrders] = useState([]);
  const [filteredOrders, setFilteredOrders] = useState([]);
  const [activeFilter, setActiveFilter] = useState('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(5);
  const [isWidgetVisible, setIsWidgetVisible] = useState(true); // Состояние видимости виджета
  const userRole = parseInt(localStorage.getItem('userRole'), 10);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const fetchOrders = async () => {
    try {
      const userId = localStorage.getItem('userId');
      if (!userId) return;

      const response = await axios.get(`http://localhost:8080/api/orders?userId=${userId}`);
      setOrders(response.data);
      setFilteredOrders(response.data);
    } catch (err) {
      console.error(err);
    }
  };

  useEffect(() => {fetchOrders();}, []);

  // Расчет статистики
  const calculateStatistics = () => {
    const statusCounts = {
      "Ожидает оплаты": 0,
      "Оплачен": 0,
      "В процессе обработки": 0,
      "Доставлен": 0,
      "Отменен": 0,
      "В возврате": 0,
    };

    let totalAmount = 0;

    orders.forEach((order) => {
      if (statusCounts[order.orderStatus] !== undefined) {
        statusCounts[order.orderStatus]++;
      }
      totalAmount += order.totalAmount;
    });

    return { statusCounts, totalAmount };
  };

  const calculateFilteredTotal = () => {
    if (activeFilter === 'all') {
      return totalAmount;
    }

    const filtered = orders.filter((order) => order.orderStatus === activeFilter);
    return filtered.reduce((sum, order) => sum + order.totalAmount, 0);
  };

  // Фильтрация заказов
  const handleFilterChange = (status) => {
    setActiveFilter(status);
    setCurrentPage(1); // Сброс страницы при изменении фильтра

    if (status === 'all') {
      setFilteredOrders(orders);
    } else {
      const filtered = orders.filter((order) => order.orderStatus === status);
      setFilteredOrders(filtered);
    }
  };

  // Логика пагинации
  const indexOfLastOrder = currentPage * itemsPerPage;
  const indexOfFirstOrder = indexOfLastOrder - itemsPerPage;
  const currentOrders = filteredOrders.slice(indexOfFirstOrder, indexOfLastOrder);

  const totalPages = Math.ceil(filteredOrders.length / itemsPerPage);

  const handlePageChange = (page) => {
    if (page >= 1 && page <= totalPages) {
      setCurrentPage(page);
    }
  };

  const { statusCounts, totalAmount } = calculateStatistics();
  const filteredTotal = calculateFilteredTotal();

  if (![3, 4].includes(userRole)) {
    return <div>У вас нет доступа к этому разделу.</div>;
  }

  return (
    <OrderListContainer>
    {/* Виджет статистики */}
    <StatWidget style={{ height: isWidgetVisible ? 'auto' : '2' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '5.0rem', marginBottom: '0rem' }}>
        <span style={{ fontSize: '1.1rem', fontWeight: 'bold' }}>
          {'Статистика заказов'}
        </span>
        <ToggleButton onClick={() => setIsWidgetVisible(!isWidgetVisible)}>
          {isWidgetVisible ? <SlArrowUp /> : <SlArrowDown />}
        </ToggleButton>
      </div>

        {isWidgetVisible && (
          <>
            <ul style={{ listStyle: 'none', padding: 0 }}>
              {Object.entries(statusCounts).map(([status, count], idx) => (
                <li key={idx} style={{ marginBottom: '0.5rem' }}>
                  <MetricBox className={getClassNameForStatus(status)}>
                    <p>{status}:</p>
                    <p>{count}</p>
                  </MetricBox>
                </li>
              ))}
              <li style={{ marginBottom: '0.5rem' }}>
                <MetricBox className="total">
                  <p>Общая сумма заказов:</p>
                  <p>{filteredTotal.toLocaleString('ru-RU', { style: 'currency', currency: 'RUB' })}</p>
                </MetricBox>
              </li>
            </ul>
          </>
        )}
      </StatWidget>

    {/* Реестр заказов */}
    <OrderRegistryWidget>
      <h3>Реестр заказов</h3>

      {/* Фильтры */}
      <FiltersContainer>
        <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap' }}>
          <FilterButton
            className={`all ${activeFilter === 'all' ? 'active' : ''}`}
            onClick={() => handleFilterChange('all')}
          >
            Все заказы
          </FilterButton>
          <FilterButton
            className={`pending ${activeFilter === 'Ожидает оплаты' ? 'active' : ''}`}
            onClick={() => handleFilterChange('Ожидает оплаты')}
          >
            Ожидает оплаты
          </FilterButton>
          <FilterButton
            className={`paid ${activeFilter === 'Оплачен' ? 'active' : ''}`}
            onClick={() => handleFilterChange('Оплачен')}
          >
            Оплачен
          </FilterButton>
          <FilterButton
            className={`processing ${activeFilter === 'В процессе обработки' ? 'active' : ''}`}
            onClick={() => handleFilterChange('В процессе обработки')}
          >
            В процессе обработки
          </FilterButton>
          <FilterButton
            className={`delivered ${activeFilter === 'Доставлен' ? 'active' : ''}`}
            onClick={() => handleFilterChange('Доставлен')}
          >
            Доставлен
          </FilterButton>
          <FilterButton
            className={`cancelled ${activeFilter === 'Отменен' ? 'active' : ''}`}
            onClick={() => handleFilterChange('Отменен')}
          >
            Отменен
          </FilterButton>
          <FilterButton
            className={`return ${activeFilter === 'В возврате' ? 'active' : ''}`}
            onClick={() => handleFilterChange('В возврате')}
          >
            В возврате
          </FilterButton>
        </div>
        <ItemsPerPageSelector
          value={itemsPerPage}
          onChange={(e) => {
            setItemsPerPage(parseInt(e.target.value));
            setCurrentPage(1); // Сброс страницы при изменении количества элементов
          }}
        >
          <option value="5">5</option>
          <option value="10">10</option>
          <option value="20">20</option>
        </ItemsPerPageSelector>
      </FiltersContainer>

      {/* Таблица заказов */}
      {currentOrders.length > 0 ? (
        <OrderTable>
          <thead>
            <tr>
              <th>Заказ #</th>
              <th>Статус</th>
              <th>Дата</th>
              <th>Сумма</th>
              <th>Адрес доставки</th>
              <th>Метод оплаты</th>
            </tr>
          </thead>
          <tbody>
            {currentOrders.map((order, idx) => (
              <tr key={idx}>
                <td>{order.orderId}</td>
                <td>{order.orderStatus}</td>
                <td>{new Date(order.orderDate).toLocaleString()}</td>
                <td>{order.totalAmount.toLocaleString('ru-RU', { style: 'currency', currency: 'RUB' })}</td>
                <td>{order.shippingAddress}</td>
                <td>{order.paymentMethod}</td>
              </tr>
            ))}
          </tbody>
        </OrderTable>
      ) : (
        <p>Нет заказов в этой категории.</p>
      )}

        <div>
          <button onClick={() => setIsModalOpen(true)}>Сделать заказ</button>
            {isModalOpen && (
              <CategoryOrderList
                onClose={() => {
                setIsModalOpen(false);
                fetchOrders(); // Обновляем данные при закрытии модального окна
                }}
              />
            )}
        </div>

      {/* Пагинация */}
      <PaginationControls>
        <PageButton
          onClick={() => handlePageChange(currentPage - 1)}
          disabled={currentPage === 1}
          className={currentPage === 1 ? 'disabled' : ''}
        >
          Предыдущая
        </PageButton>
        <span>
          Страница {currentPage} из {totalPages}
        </span>
        <PageButton
          onClick={() => handlePageChange(currentPage + 1)}
          disabled={currentPage === totalPages}
          className={currentPage === totalPages ? 'disabled' : ''}
        >
          Следующая
        </PageButton>
      </PaginationControls>
    </OrderRegistryWidget>
  </OrderListContainer>
  );
};

const getClassNameForStatus = (status) => {
  switch (status) {
    case "Ожидает оплаты":
      return "pending";
    case "Оплачен":
      return "paid";
    case "В процессе обработки":
      return "processing";
    case "Доставлен":
      return "delivered";
    case "Отменен":
      return "cancelled";
    case "В возврате":
      return "return";
    default:
      return "";
  }
};

export default OrderListPage;