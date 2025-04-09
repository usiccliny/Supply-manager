import React, { useState } from 'react';
import styled from 'styled-components';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

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
  color: red;
  text-align: center;
  margin-top: 10px;
`;

const SuccessMessage = styled.p`
  color: green;
  text-align: center;
  margin-top: 10px;
`;

const RoleSwitcher = styled.div`
  display: flex;
  justify-content: space-around;
  margin-bottom: 20px;
`;

const RadioLabel = styled.label`
  display: flex;
  align-items: center;
  font-weight: 500;
  color: #555;
  cursor: pointer;
  transition: color 0.3s;

  input {
    margin-right: 5px;
  }

  &:hover {
    color: #007bff;
  }
`;

const Register = () => {
  const [role, setRole] = useState('user'); // Состояние для роли
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [email, setEmail] = useState('');
  const [contactPerson, setContactPerson] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [address, setAddress] = useState('');
  const [companyName, setCompanyName] = useState('');
  const [position, setPosition] = useState('');
  const [message, setMessage] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      const response = await axios.post('http://localhost:8080/api/auth/register', {
        role,
        username,
        password,
        email,
        contactPerson,
        phoneNumber,
        address,
        companyName,
        position,
      });

      setMessage(response.data);

      // Сброс состояния формы
      setUsername('');
      setPassword('');
      setEmail('');
      setContactPerson('');
      setPhoneNumber('');
      setAddress('');
      setCompanyName('');
      setPosition('');

      if (response.data === 'User registered successfully') {
        navigate('/');
      }
    } catch (error) {
      setMessage(error.response?.data || 'Registration failed');
    }
  };

  return (
    <RegisterContainer>
      <Title>Создайте аккаунт</Title>
      <RoleSwitcher>
        <RadioLabel>
          <input
            type="radio"
            value="user"
            checked={role === 'user'}
            onChange={() => setRole('user')}
          /> 
          Пользователь
        </RadioLabel>
        <RadioLabel>
          <input
            type="radio"
            value="supplier"
            checked={role === 'supplier'}
            onChange={() => setRole('supplier')}
          /> 
          Поставщик
        </RadioLabel>
      </RoleSwitcher>
      <form onSubmit={handleSubmit}>
        {role === 'user' ? (
          <>
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
          </>
        ) : (
          <>
            <FormGroup>
              <Label htmlFor="contactPerson">Контактное лицо</Label>
              <Input
                type="text"
                id="contactPerson"
                value={contactPerson}
                onChange={(e) => setContactPerson(e.target.value)}
                required
              />
            </FormGroup>
            <FormGroup>
              <Label htmlFor="phoneNumber">Номер телефона</Label>
              <Input
                type="text"
                id="phoneNumber"
                value={phoneNumber}
                onChange={(e) => setPhoneNumber(e.target.value)}
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
              <Label htmlFor="address">Адрес</Label>
              <Input
                type="text"
                id="address"
                value={address}
                onChange={(e) => setAddress(e.target.value)}
              />
            </FormGroup>
            <FormGroup>
              <Label htmlFor="companyName">Имя компании</Label>
              <Input
                type="text"
                id="companyName"
                value={companyName}
                onChange={(e) => setCompanyName(e.target.value)}
                required
              />
            </FormGroup>
            <FormGroup>
              <Label htmlFor="position">Должность</Label>
              <Input
                type="text"
                id="position"
                value={position}
                onChange={(e) => setPosition(e.target.value)}
                required
              />
            </FormGroup>
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
          </>
        )}
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