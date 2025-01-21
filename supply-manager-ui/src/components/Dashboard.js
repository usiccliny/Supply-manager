import React from 'react';
import styled from 'styled-components';

const DashboardContainer = styled.div`
  padding: 2rem;
`;

const Dashboard = () => {
  return (
    <DashboardContainer>
      <h1>Добро пожаловать в систему управления закупками!</h1>
      <p>Здесь вы можете управлять всеми своими заказами и поставками.</p>
    </DashboardContainer>
  );
};

export default Dashboard;