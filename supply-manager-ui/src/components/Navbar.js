import React from 'react';
import { Link } from 'react-router-dom';
import { FaHome, FaClipboardList, FaPeopleArrows, FaFileAlt } from 'react-icons/fa';
import styled from 'styled-components';

const NavbarContainer = styled.nav`
  background: #333;
  color: white;
  padding: 1rem;
`;

const NavItem = styled(Link)`
  margin-right: 20px;
  color: white;
  text-decoration: none;
  cursor: pointer;

  &:hover {
    text-decoration: underline;
  }
`;

const Navbar = () => {
  return (
    <NavbarContainer>
      <NavItem to="/">Главная</NavItem>
      <NavItem to="/orders">Заказы</NavItem>
      <NavItem to="/suppliers">Поставщики</NavItem>
      <NavItem to="/reports">Отчеты</NavItem>
    </NavbarContainer>
  );
};

export default Navbar;