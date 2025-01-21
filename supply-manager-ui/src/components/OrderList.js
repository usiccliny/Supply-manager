import React from 'react';
import styled from 'styled-components';

const OrderListContainer = styled.div`
  padding: 2rem;
`;

const OrderList = () => {
  const orders = [
    { id: 1, name: 'Заказ 1', status: 'Выполнен' },
    { id: 2, name: 'Заказ 2', status: 'В ожидании' },
    { id: 3, name: 'Заказ 3', status: 'Отменен' },
  ];

  return (
    <OrderListContainer>
      <h2>Список заказов</h2>
      <ul>
        {orders.map(order => (
          <li key={order.id}>{order.name} - {order.status}</li>
        ))}
      </ul>
    </OrderListContainer>
  );
};

export default OrderList;