import React from 'react';
import styled from 'styled-components';

const ReportContainer = styled.div`
  padding: 2rem;
`;

const Report = () => {
  return (
    <ReportContainer>
      <h2>Отчеты</h2>
      <p>Эта информация будет включать отчеты по заказам и поставкам.</p>
    </ReportContainer>
  );
};

export default Report;