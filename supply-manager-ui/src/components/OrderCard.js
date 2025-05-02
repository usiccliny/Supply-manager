import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import axios from "axios";
import styled from "styled-components";

const CardContainer = styled.div`
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 16px;
  margin: 16px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  background: #fff;
`;

const Title = styled.h2`
  font-size: 1.5rem;
  margin-bottom: 16px;
`;

const Detail = styled.p`
  margin: 8px 0;
  font-size: 1rem;
  color: #555;
`;

const OrderCard = () => {
  const { orderId } = useParams();
  const [orderDetails, setOrderDetails] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const userRole = parseInt(localStorage.getItem("userRole"), 10);

  useEffect(() => {
    const fetchOrderDetails = async () => {
      try {
        const response = await axios.get(`http://localhost:8080/api/orders/${orderId}`, {
          params: { role: userRole },
        });
        setOrderDetails(response.data);
      } catch (err) {
        setError("Ошибка при загрузке данных");
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchOrderDetails();
  }, [orderId]);

  if (loading) {
    return <p>Загрузка...</p>;
  }

  if (error) {
    return <p>{error}</p>;
  }

  if (!orderDetails || orderDetails.length === 0) {
    return <p>Заказ не найден.</p>;
  }

  // Общая сумма заказа
  const totalAmount = orderDetails.reduce((sum, item) => sum + item.price * item.quantity, 0);

  return (
    <CardContainer>
      <Title>Детали заказа #{orderId}</Title>

      {/* Общая сумма */}
      <Detail>Сумма: {totalAmount} ₽</Detail>

      {/* Информация о пользователе или поставщике */}
      {userRole === 4 && (
        <Detail>
          Покупатель: {orderDetails[0].contactPerson} ({orderDetails[0].contactData})
        </Detail>
      )}
      {userRole === 3 && (
        <Detail>
          Поставщик: {orderDetails[0].contactPerson} ({orderDetails[0].contactData})
        </Detail>
      )}

      {/* Список товаров */}
      <Detail>Товары:</Detail>
      <ul>
        {orderDetails.map((item) => (
          <li key={item.orderDetailId}>
            {item.productName} - {item.quantity} шт. ({item.price} ₽)
          </li>
        ))}
      </ul>
    </CardContainer>
  );
};

export default OrderCard;