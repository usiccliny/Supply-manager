import React, { useEffect, useState } from 'react';
import axios from 'axios';
import styled from 'styled-components';

const SupplierListContainer = styled.div`
  padding: 2rem;
`;

const SupplierItem = styled.li`
  margin-bottom: 1rem;
  padding: 1rem;
  border: 1px solid #ddd;
  border-radius: 5px;
  background-color: #fafafa;
`;

const SupplierList = () => {
  const [suppliers, setSuppliers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchSuppliers = async () => {
      const userId = localStorage.getItem('userId'); // Получаем userId из localStorage
      if (!userId) {
        setError('User ID is not available.');
        setLoading(false);
        return;
      }

      try {
        const response = await axios.get(`http://localhost:8080/api/suppliers/${userId}`);
        setSuppliers(response.data); // Предполагается, что ваш API возвращает массив поставщиков
      } catch (err) {
        console.error(err);
        setError('Failed to fetch suppliers.'); // Обработка ошибок
      } finally {
        setLoading(false);
      }
    };

    fetchSuppliers();
  }, []);

  if (loading) {
    return <div>Loading...</div>; // Показать индикатор загрузки
  }

  if (error) {
    return <div>{error}</div>; // Показать сообщение об ошибке
  }

  return (
    <SupplierListContainer>
      <h2>Список поставщиков</h2>
      <ul>
        {suppliers.length > 0 ? (
          suppliers.map(supplier => (
            <SupplierItem key={supplier.supplierId}>
              <h3>{supplier.companyName}</h3>
              <p><strong>Контактное лицо:</strong> {supplier.contactPerson}</p>
              <p><strong>Телефон:</strong> {supplier.phoneNumber}</p>
              <p><strong>Email:</strong> {supplier.email}</p>
              <p><strong>Адрес:</strong> {supplier.address}</p>
              <p><strong>Должность:</strong> {supplier.postName} ({supplier.postShortName})</p>
            </SupplierItem>
          ))
        ) : (
          <li>Поставщиков пока нет.</li> // Если поставщиков нет
        )}
      </ul>
    </SupplierListContainer>
  );
};

export default SupplierList;