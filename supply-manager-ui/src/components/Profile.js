import React, { useState, useEffect } from 'react';
import axios from 'axios';
import styled from 'styled-components';

const LoginContainer = styled.div`
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
  color: red;
  text-align: center;
  margin-top: 10px;
`;

const SuccessMessage = styled.p`
  color: green;
  text-align: center;
  margin-top: 10px;
`;

const LoginForm = () => {
    const [isLoggedIn, setLoggedIn] = useState(false);
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [message, setMessage] = useState('');
    const [userId, setUserId] = useState('');

    // Проверяем наличие токена в localStorage при загрузке компонента
    useEffect(() => {
        const token = localStorage.getItem('token');
        const savedUsername = localStorage.getItem('username'); // Сохраняем также имя пользователя
        const userId = localStorage.getItem('userId');
        if (token) {
            setLoggedIn(true);
            setUsername(savedUsername); 
            setUserId(userId);
        }
    }, []);

    const handleSubmit = async (e) => {
        e.preventDefault();

        try {
            const response = await axios.post('http://localhost:8080/api/auth/login', {
                username,
                password,
            });

            const { token, userId } = response.data; // Получаем JWT-токен
            localStorage.setItem('token', token); // Сохраняем токен в localStorage
            localStorage.setItem('userId', userId); // Сохраняем ID пользователя
            localStorage.setItem('username', username); // Сохраняем имя пользователя
            setLoggedIn(true); // Устанавливаем состояние входа
            setMessage('Login successful');
            console.log('Token saved:', token);
        } catch (error) {
            setMessage(error.response?.data || 'Login failed');
        }
    };

    const handleLogout = () => {
        localStorage.removeItem('token');
        localStorage.removeItem('userId');
        localStorage.removeItem('username'); // Удаляем имя пользователя
        setLoggedIn(false); // Устанавливаем состояние выхода
        setUsername('');
        setPassword('');
    };

    return (
        <div>
            {isLoggedIn ? (
                <div>
                    <h1>Добро пожаловать, {username}!</h1>
                    <button onClick={handleLogout}>Выйти</button>
                </div>
            ) : (
                <LoginContainer>
                    <Title>Вход</Title>
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
                    {message && (
                        <>
                            {message === 'Login successful' ? (
                                <SuccessMessage>{message}</SuccessMessage>
                            ) : (
                                <ErrorMessage>{message}</ErrorMessage>
                            )}
                        </>
                    )}
                </LoginContainer>
            )}
        </div>
    );
};

export default LoginForm;