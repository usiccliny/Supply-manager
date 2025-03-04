import React, { useEffect, useState } from 'react';
import axios from 'axios';
import styled from 'styled-components';

const OrderListContainer = styled.div`
  padding: 2rem;
`;

const OrderItem = styled.li`
  margin-bottom: 1rem;
  padding: 1rem;
  border: 1px solid #ddd;
  border-radius: 5px;
  background-color: #fafafa;
`;

const OrderList = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchOrders = async () => {
      const userId = localStorage.getItem('userId'); // Получаем userId из localStorage
      if (!userId) {
        setError('User ID is not available.');
        setLoading(false);
        return;
      }

      try {
        const response = await axios.get(`http://localhost:8080/api/orders/${userId}`);
        setOrders(response.data); // Предполагается, что ваш API возвращает массив заказов
      } catch (err) {
        console.error(err);
        setError('Failed to fetch orders.'); // Обработка ошибок
      } finally {
        setLoading(false);
      }
    };

    fetchOrders();
  }, []);

  if (loading) {
    return <div>Loading...</div>; // Показать индикатор загрузки
  }

  if (error) {
    return <div>{error}</div>; // Показать сообщение об ошибке
  }

  return (
    <OrderListContainer>
      <h2>Список заказов</h2>
      <ul>
        {orders.length > 0 ? (
          orders.map(order => (
            <OrderItem key={order.orderId}>
              <h3>Заказ #{order.orderId}</h3>
              <p><strong>Статус:</strong> {order.orderStatus}</p>
              <p><strong>Дата заказа:</strong> {new Date(order.orderDate).toLocaleString()}</p>
              <p><strong>Сумма:</strong> {order.totalAmount.toLocaleString('ru-RU', { style: 'currency', currency: 'RUB' })}</p>
              <p><strong>Адрес доставки:</strong> {order.shippingAddress}</p>
              <p><strong>Способ оплаты:</strong> {order.paymentMethod}</p>
              <p><strong>Трек номер:</strong> {order.trackingNumber}</p>
            </OrderItem>
          ))
        ) : (
          <li>Заказов пока нет.</li> // Если заказов нет
        )}
      </ul>
    </OrderListContainer>
  );
};

export default OrderList;