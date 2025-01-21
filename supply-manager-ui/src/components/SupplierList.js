import React from 'react';
import styled from 'styled-components';

const SupplierListContainer = styled.div`
  padding: 2rem;
`;

const SupplierList = () => {
  const suppliers = [
    { id: 1, name: 'Поставщик 1' },
    { id: 2, name: 'Поставщик 2' },
    { id: 3, name: 'Поставщик 3' },
  ];

  return (
    <SupplierListContainer>
      <h2>Список поставщиков</h2>
      <ul>
        {suppliers.map(supplier => (
          <li key={supplier.id}>{supplier.name}</li>
        ))}
      </ul>
    </SupplierListContainer>
  );
};

export default SupplierList;