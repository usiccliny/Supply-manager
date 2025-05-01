import React, { useState, useEffect, useContext } from 'react';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import { Link } from 'react-router-dom';
import { FaHome, FaClipboardList, FaPeopleArrows, FaFileAlt, FaUser, FaUserPlus, FaBars, FaTimes } from 'react-icons/fa';
import styled from 'styled-components';
import { DateContext } from "../DateContext";

const NavbarContainer = styled.nav`
  display: flex;
  align-items: center;
  background: #333;
  color: white;
  padding: 1rem;
  position: relative; 
`;

const BurgerMenu = styled.div`
  display: flex;
  align-items: center;
  cursor: pointer;
  margin-right: 20px;
  position: relative; 
  z-index: 1100; 
`;

const LeftNavItems = styled.div`
  display: flex;
  flex-grow: 1; 
`;

const RightNavItems = styled.div`
  margin-left: auto; 
`;

const NavItem = styled(Link)`
  margin-right: 20px;
  color: white;
  text-decoration: none;
  cursor: pointer;
  display: flex;
  align-items: center;

  &:hover {
    text-decoration: underline;
  }

  svg {
    margin-right: 8px;
  }
`;

const DropdownMenu = styled(({ isOpen, ...props }) => <div {...props} />)`
  position: absolute;
  top: 0; 
  left: 0; 
  background: #333;
  color: white;
  width: 200px; 
  height: 100vh; 
  display: ${props => (props.isOpen ? 'block' : 'none')}; 
  z-index: 1000; 
  padding-top: 60px; /* Добавляем отступ сверху, чтобы освободить место под бургер-меню */
`;

const DropdownItem = styled(Link)`
  display: block;
  padding: 10px 15px;
  color: white;
  text-decoration: none;

  &:hover {
    background: #444; 
  }
`;

const Overlay = styled(({ isOpen, ...props }) => <div {...props} />)`
  position: fixed; 
  top: 0;
  left: 0;
  width: 100vw; 
  height: 100vh; 
  background: rgba(0, 0, 0, 0.5); 
  display: ${props => (props.isOpen ? 'block' : 'none')}; 
  z-index: 900; 
`;

const Navbar = () => {
  const { selectedDate, handleDateChange } = useContext(DateContext);
  const [isOpen, setIsOpen] = useState(false);

  const toggleMenu = () => {
    setIsOpen(!isOpen);
  };

  return (
    <NavbarContainer>
      <BurgerMenu onClick={toggleMenu}>
        {isOpen ? <FaTimes size={24} /> : <FaBars size={24} />}
      </BurgerMenu>

      <LeftNavItems>
        <NavItem to="/">
          <FaHome /> Главная
        </NavItem>
        <NavItem to="/orders">
          <FaClipboardList /> Заказы
        </NavItem>
        <NavItem to="/suppliers">
          <FaPeopleArrows /> Поставщики
        </NavItem>
        <NavItem to="/reports">
          <FaFileAlt /> Рейтинг
        </NavItem>
      </LeftNavItems>

      <div className="date-picker">
        <DatePicker
          selected={selectedDate}
          onChange={handleDateChange}
          dateFormat="dd.MM.yyyy"
          placeholderText="Выберите дату"
        />
      </div>

      <RightNavItems>
        <NavItem to="/profile">
          <FaUser /> Личный профиль
        </NavItem>
        <NavItem to="/register">
          <FaUserPlus /> Регистрация
        </NavItem>
      </RightNavItems>

      <Overlay isOpen={isOpen} onClick={toggleMenu} />

      <DropdownMenu isOpen={isOpen}>
        <DropdownItem to="/" onClick={toggleMenu}>Главная</DropdownItem>
        <DropdownItem to="/orders" onClick={toggleMenu}>Заказы</DropdownItem>
        <DropdownItem to="/suppliers" onClick={toggleMenu}>Поставщики</DropdownItem>
        <DropdownItem to="/reports" onClick={toggleMenu}>Рейтинг</DropdownItem>
        <DropdownItem to="/profile" onClick={toggleMenu}>Личный профиль</DropdownItem>
        <DropdownItem to="/register" onClick={toggleMenu}>Регистрация</DropdownItem>
      </DropdownMenu>
    </NavbarContainer>
  );
};

export default Navbar;