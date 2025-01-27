import React, { useState } from 'react';
import styled from 'styled-components';

const ProfileContainer = styled.div`
  max-width: 400px;
  margin: 50px auto; /* Центрируем по горизонтали и вертикали */
  padding: 40px; /* Внутренние отступы */
  border-radius: 10px;
  background: #f9f9f9; /* Светло-серый фон для формы */
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1); /* Легкая тень для эффекта приподнятости */
  transition: transform 0.3s;

  &:hover {
    transform: translateY(-5px); /* Плавный подъем при наведении на форму */
  }
`;

const Title = styled.h1`
  text-align: center;
  color: #333; /* Темный цвет текста */
  font-size: 26px; /* Увеличенный размер шрифта */
  margin-bottom: 30px; /* Отступ снизу */
`;

const FormGroup = styled.div`
  margin-bottom: 20px; /* Отступ между элементами */
`;

const Label = styled.label`
  display: block;
  margin-bottom: 5px; /* Отступ снизу от метки */
  font-weight: 500; /* Полужирный текст для меток */
  color: #555; /* Темный цвет меток */
  font-size: 14px; /* Размер шрифта для меток */
`;

const Input = styled.input`
  width: 100%; /* Полное расширение */
  padding: 12px; /* Внутренние отступы */
  border: 1px solid #ddd; /* Светло-серая рамка */
  border-radius: 5px; /* Закругленные углы */
  font-size: 16px; /* Размер шрифта для полей ввода */
  transition: border-color 0.3s, background 0.3s;

  &:focus {
    outline: none; /* Убираем стандартный контур */
    border-color: #007bff; /* Синяя рамка при фокусе */
    background: #fff; /* Белый фон при фокусе */
  }
`;

const Button = styled.button`
  width: 100%;
  padding: 10px; /* Увеличенные внутренние отступы кнопки */
  background-color: #007bff; /* Синяя кнопка */
  color: white; /* Белый текст на кнопке */
  border: none;
  border-radius: 5px; /* Закругленные углы */
  font-size: 18px; /* Размер шрифта для кнопки */
  cursor: pointer;
  transition: background-color 0.3s;

  &:hover {
    background-color: #0056b3; /* Более светлый цвет при наведении */
  }
`;

const Profile = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault(); // Предотвращаем перезагрузку страницы
    console.log('Логин:', username);
    console.log('Пароль:', password);
    // Здесь можно добавить логику для аутентификации пользователя
  };

  return (
    <ProfileContainer>
      <Title>Вход в личный профиль</Title>
      <form onSubmit={handleSubmit}>
        <FormGroup>
          <Label htmlFor="username">Логин</Label>
          <Input
            type="text"
            id="username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            required
          />
        </FormGroup>
        <FormGroup>
          <Label htmlFor="password">Пароль</Label>
          <Input
            type="password"
            id="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
        </FormGroup>
        <Button type="submit">Войти</Button>
      </form>
    </ProfileContainer>
  );
};

export default Profile;