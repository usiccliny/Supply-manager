import React, { useState } from 'react';
import styled from 'styled-components';
import { useNavigate } from 'react-router-dom'; // Импортируем useNavigate
import axios from 'axios'; // Импортируем axios

const RegisterContainer = styled.div`
  max-width: 400px;
  margin: 50px auto;
  padding: 40px;
  border-radius: 10px;
  background: #f9f9f9;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s;
  &:hover {
    transform: translateY(-5px);
  }
`;

const Title = styled.h1`
  text-align: center;
  color: #333;
  font-size: 26px;
  margin-bottom: 30px;
`;

const FormGroup = styled.div`
  margin-bottom: 15px;
`;

const Label = styled.label`
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
  color: #555;
  font-size: 14px;
`;

const Input = styled.input`
  width: 100%;
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 5px;
  font-size: 16px;
  transition: border-color 0.3s, background 0.3s;
  &:focus {
    outline: none;
    border-color: #007bff;
    background: #fff;
  }
`;

const Button = styled.button`
  width: 100%;
  padding: 10px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 5px;
  font-size: 18px;
  cursor: pointer;
  transition: background-color 0.3s;
  &:hover {
    background-color: #0056b3;
  }
`;

const ErrorMessage = styled.p`
  color: red; /* Красный текст для ошибок */
  text-align: center;
  margin-top: 10px;
`;

const SuccessMessage = styled.p`
  color: green; /* Зелёный текст для успешных сообщений */
  text-align: center;
  margin-top: 10px;
`;

const Register = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [email, setEmail] = useState('');
  const [message, setMessage] = useState(''); // Для отображения сообщений
  const navigate = useNavigate(); // Создаем экземпляр navigate

  const handleSubmit = async (e) => {
    e.preventDefault(); // Предотвращаем перезагрузку страницы

    try {
      const response = await axios.post('http://localhost:8080/api/auth/register', {
        username,
        password,
        email,
      });

      setMessage(response.data); // Отображаем успешное сообщение

      setUsername('');
      setPassword('');
      setEmail('');

      // Переходим на главную страницу после успешной регистрации
      if (response.data === 'User registered successfully') {
        navigate('/'); // Замените '/' на нужный вам маршрут
      }
    } catch (error) {
      setMessage(error.response?.data || 'Registration failed'); // Отображаем ошибку
    }
  };

  return (
    <RegisterContainer>
      <Title>Создайте аккаунт</Title>
      <form onSubmit={handleSubmit}>
        <FormGroup>
          <Label htmlFor="username">Имя пользователя</Label>
          <Input
            type="text"
            id="username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            required
          />
        </FormGroup>
        <FormGroup>
          <Label htmlFor="email">Электронная почта</Label>
          <Input
            type="email"
            id="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
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
        <Button type="submit">Зарегистрироваться</Button>
      </form>
      {message && (
        <>
          {message === 'User registered successfully' ? (
            <SuccessMessage>{message}</SuccessMessage>
          ) : (
            <ErrorMessage>{message}</ErrorMessage>
          )}
        </>
      )}
    </RegisterContainer>
  );
};

export default Register;