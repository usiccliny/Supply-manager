import React, { useEffect, useState } from 'react';
import axios from 'axios';
import styled from 'styled-components';
import Select from 'react-select';
import { buildCategoryTree } from '../utils/categoryUtils';
import Breadcrumbs from '../utils/Breadcrumbs';

// Стили
const ModalOverlay = styled.div`
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
`;

const ModalContent = styled.div`
  width: 800px; // Фиксированная ширина
  height: 600px; // Фиксированная высота
  padding: 2rem;
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
  position: relative;
  display: flex;
  flex-direction: column;
`;

const ProductsContainer = styled.div`
  flex: 1;
  overflow-y: auto; // Добавляем вертикальный скролл
  margin-top: 1rem;
  padding: 0.5rem;
  border: 1px solid #ccc;
  border-radius: 5px;
  background: #f9f9f9;
`;

const CloseButton = styled.button`
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: transparent;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #333;
  transition: transform 0.3s;
  &:hover {
    transform: scale(1.1);
  }
`;

const OrderFormContainer = styled.div`
  margin-top: 2rem;
  padding: 1rem;
  border: 1px solid #ccc;
  border-radius: 5px;
`;

const ProductItem = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 1rem;
  margin-bottom: 0.5rem;
  border-radius: 5px;
  cursor: ${({ isAvailable }) => (isAvailable ? 'pointer' : 'not-allowed')};
  background: ${({ isAvailable }) => (isAvailable ? '#f9f9f9' : '#e0e0e0')};
  transition: background 0.3s;

  &:hover {
    background: ${({ isAvailable }) => (isAvailable ? '#e6f7ff' : '#e0e0e0')};
  }
`;

const SelectedProductsContainer = styled.div`
  position: fixed;
  top: 80px;
  left: 20px;
  width: 300px;
  max-height: 600px;
  overflow-y: auto;
  padding: 1rem;
  border: 1px solid #ccc;
  border-radius: 5px;
  background: #f9f9f9;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
`;

const SelectedProductItem = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem;
  margin-bottom: 0.5rem;
  border-radius: 5px;
  background: #fff;
  position: relative;
  transition: background 0.3s;

  &:hover {
    background: #e6f7ff;
  }
`;

const QuantitySelector = styled.input`
  width: 50px;
  padding: 0.3rem;
  text-align: center;
  border: 1px solid #ccc;
  border-radius: 5px;
`;

const SubmitButton = styled.button`
  margin-top: 1rem;
  padding: 0.6rem 1.2rem;
  font-size: 0.9rem;
  color: #fff;
  background: linear-gradient(135deg, rgba(71, 159, 255, 0.8) 0%, rgba(128, 196, 255, 0.6) 100%);
  border: none;
  border-radius: 5px;
  cursor: pointer;
  transition: transform 0.3s, box-shadow 0.3s;
  &:hover {
    transform: scale(1.05);
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
  }
`;

const ProceedButton = styled.button`
  margin-top: 1rem;
  padding: 0.6rem 1.2rem;
  font-size: 0.9rem;
  color: #fff;
  background: linear-gradient(135deg, rgba(71, 159, 255, 0.8) 0%, rgba(128, 196, 255, 0.6) 100%);
  border: none;
  border-radius: 5px;
  cursor: pointer;
  transition: transform 0.3s, box-shadow 0.3s;
  &:hover {
    transform: scale(1.05);
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
  }
`;

const StatusIcon = styled.div`
  position: absolute;
  top: 0.5rem;
  right: 0.5rem;
  font-size: 1.2rem;
  color: ${({ status }) => (status === 'Нет в наличии' ? '#ff4d4d' : '#ffcc00')};
  cursor: help;
`;

const CategoryOrderList = ({ onClose }) => {
  const [categories, setCategories] = useState([]);
  const [categoryTree, setCategoryTree] = useState([]);
  const [breadcrumbs, setBreadcrumbs] = useState([]);
  const [selectedCategory, setSelectedCategory] = useState(null);
  const [products, setProducts] = useState([]);
  const [paymentMethodId, setPaymentMethodId] = useState('');
  const [shippingAddress, setShippingAddress] = useState('');
  const [isCheckoutVisible, setIsCheckoutVisible] = useState(false);

  const getSelectedProductsFromLocalStorage = () => {
    const storedProducts = localStorage.getItem('selectedProducts');
    return storedProducts ? JSON.parse(storedProducts) : [];
  };
  
  const [selectedProducts, setSelectedProducts] = useState(getSelectedProductsFromLocalStorage());
  
  const saveSelectedProductsToLocalStorage = (products) => {
    localStorage.setItem('selectedProducts', JSON.stringify(products));
  };

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const response = await axios.get('http://localhost:8080/api/products/category');
        const tree = buildCategoryTree(response.data);
        setCategories(response.data);
        setCategoryTree(tree);
        setBreadcrumbs([tree.find((cat) => cat.parentId === null)]);
      } catch (err) {
        console.error(err);
      }
    };
    fetchCategories();
  }, []);

  const handleCategorySelect = (category) => {
    if (category.children && category.children.length > 0) {
      setBreadcrumbs((prev) => [...prev, category]);
    } else {
      setSelectedCategory(category);
      fetchProductsByCategory(category.name);
    }
  };

  // Переход по хлебным крошкам
  const handleBreadcrumbClick = (category) => {
    const newBreadcrumbs = breadcrumbs.slice(0, breadcrumbs.indexOf(category) + 1);
    setBreadcrumbs(newBreadcrumbs);

    const selectedCategory = newBreadcrumbs[newBreadcrumbs.length - 1];
    if (selectedCategory.children && selectedCategory.children.length > 0) {
      setSelectedCategory(null);
      setProducts([]);
    }
  };

  // Загрузка товаров для выбранной категории
  const fetchProductsByCategory = async (categoryName) => {
    try {
      const response = await axios.get('http://localhost:8080/api/products/catalog');
      const filteredProducts = response.data.filter(
        (product) => product.categoryName === categoryName
      );
      setProducts(filteredProducts);
    } catch (err) {
      console.error(err);
    }
  };

  const handleProductSelect = (product) => {
    if (product.productStatus !== 'Есть в наличии') return;
  
    const existingProduct = selectedProducts.find(
      (p) => p.productId === product.productId && p.supplierId === product.supplierId
    );
  
    if (existingProduct) {
      setSelectedProducts((prev) =>
        prev.map((p) =>
          p.productId === product.productId &&
          p.supplierId === product.supplierId
            ? { ...p, quantity: Math.min(p.quantity + 1, product.quantity) }
            : p
        )
      );
    } else {
      setSelectedProducts((prev) => [
        ...prev,
        {
          productId: product.productId,
          supplierId: product.supplierId,
          productName: product.productName,
          price: product.price,
          quantity: 1,
        },
      ]);
    }
    saveSelectedProductsToLocalStorage(selectedProducts);
  };
  
  const handleRemoveProduct = (productId, supplierId) => {
    setSelectedProducts((prev) =>
      prev.filter(
        (p) => !(p.productId === productId && p.supplierId === supplierId)
      )
    );
    saveSelectedProductsToLocalStorage(selectedProducts);
  };

  const handleSubmit = async () => {
    if (!paymentMethodId || !shippingAddress) {
      alert('Пожалуйста, заполните все поля.');
      return;
    }
  
    const totalAmount = selectedProducts.reduce((sum, product) => sum + product.price * product.quantity,0);
  
    const orderData = {
      userId: parseInt(localStorage.getItem('userId'), 10),
      paymentMethodId: parseInt(paymentMethodId, 10),
      shippingAddress,
      billingAddress: null,
      totalAmount,
      orderDetails: selectedProducts.map((product) => ({
        productId: product.productId,
        supplierId: product.supplierId,
        quantity: product.quantity,
      })),
    };
  
    try {
      await axios.post('http://localhost:8080/api/orders', orderData);
      alert('Заказ успешно создан!');
      onClose();
      localStorage.removeItem('selectedProducts');
    } catch (err) {
      console.error(err);
      alert('Ошибка при создании заказа.');
    }
  };

  return (
    <ModalOverlay>
      <ModalContent>
        <CloseButton onClick={onClose}>&times;</CloseButton>
        <h3>Выбор товаров</h3>
  
        {/* Хлебные крошки */}
        <Breadcrumbs breadcrumbs={breadcrumbs} onSelect={handleBreadcrumbClick} />
  
        {/* Выбор категории */}
        <div style={{ marginBottom: '1.5rem' }}>
          <label style={{ fontWeight: 'bold', display: 'block', marginBottom: '0.5rem' }}>
            Категория товара
          </label>
          <Select
            options={
              breadcrumbs[breadcrumbs.length - 1]?.children.map((cat) => ({
                value: cat.id,
                label: cat.name,
              })) || []
            }
            onChange={(selected) => {
              const category = breadcrumbs[breadcrumbs.length - 1]?.children.find(
                (cat) => cat.id === selected.value
              );
              handleCategorySelect(category);
            }}
            placeholder="Выберите категорию"
            isSearchable
            styles={{
              control: (base) => ({
                ...base,
                borderRadius: '5px',
                fontSize: '1rem',
                padding: '0.5rem',
              }),
            }}
          />
        </div>
  
        {/* Список товаров */}
        {!isCheckoutVisible && selectedCategory && (
          <ProductsContainer>
            <h4>Товары в категории "{selectedCategory.name}"</h4>
            {products.map((product, index) => (
              <ProductItem
                key={index}
                isAvailable={product.productStatus === 'Есть в наличии'}
                onClick={() => handleProductSelect(product)}
              >
                <div>
                  <p>{product.productName}</p>
                  <p>Цена: {product.price} руб.</p>
                  <p>Количество: {product.quantity}</p>
                </div>
                <div style={{ position: 'relative' }}>
                  {product.productStatus !== 'Есть в наличии' && (
                    <StatusIcon
                      status={product.productStatus}
                      title={
                        product.productStatus === 'Нет в наличии'
                          ? 'Товар недоступен'
                          : 'Товар в пути'
                      }
                      style={{
                        position: 'absolute',
                        top: '0.5rem',
                        right: '0.5rem',
                        fontSize: '1.2rem',
                        color:
                          product.productStatus === 'Нет в наличии' ? '#ff4d4d' : '#ffcc00',
                        cursor: 'help',
                      }}
                    >
                      ⓘ
                    </StatusIcon>
                  )}
                  {product.productStatus === 'Есть в наличии' && (
                    <QuantitySelector
                      type="number"
                      min="1"
                      max={product.quantity}
                      value={
                        selectedProducts.find(
                          (p) =>
                            p.productId === product.productId &&
                            p.supplierId === product.supplierId
                        )?.quantity || 1
                      }
                      onChange={(e) => {
                        const quantity = parseInt(e.target.value, 10);
                        if (quantity > product.quantity) return;
  
                        setSelectedProducts((prev) =>
                          prev.map((p) =>
                            p.productId === product.productId &&
                            p.supplierId === product.supplierId
                              ? { ...p, quantity }
                              : p
                          )
                        );
                      }}
                    />
                  )}
                </div>
              </ProductItem>
            ))}
          </ProductsContainer>
        )}
  
        {/* Список выбранных товаров */}
        {selectedProducts.length > 0 && (
  <SelectedProductsContainer>
    <h4>Выбранные товары</h4>
    {selectedProducts.map((product, index) => (
      <SelectedProductItem key={index}>
        <div>
          <p>{product.productName}</p>
          <p>Количество: {product.quantity} шт.</p>
        </div>
        <button
          style={{
            position: 'absolute',
            top: '0.5rem',
            right: '0.5rem',
            background: 'transparent',
            border: 'none',
            fontSize: '1rem',
            color: '#ff4d4d',
            cursor: 'pointer',
          }}
          onClick={() => handleRemoveProduct(product.productId, product.supplierId)}
        >
          &times;
        </button>
      </SelectedProductItem>
    ))}
  </SelectedProductsContainer>
)}
  
        {selectedProducts.length > 0 && !isCheckoutVisible && (
            <ProceedButton onClick={() => setIsCheckoutVisible(true)}>
                Перейти к оформлению
            </ProceedButton>
            )}

        {selectedProducts.length > 0 && isCheckoutVisible && (
          <ProceedButton onClick={() => setIsCheckoutVisible(false)}>
                Назад
          </ProceedButton>
        )}
  
        {/* Форма заказа */}
        {isCheckoutVisible && (
          <OrderFormContainer>
            <h4>Оформление заказа</h4>
            <div style={{ marginBottom: '1rem' }}>
              <label style={{ fontWeight: 'bold', display: 'block', marginBottom: '0.5rem' }}>
                Метод оплаты
              </label>
              <Select
                options={[
                  { value: '1', label: 'Кредитная карта' },
                  { value: '2', label: 'Дебетовая карта' },
                  { value: '3', label: 'Наличный расчет' },
                ]}
                onChange={(selected) => setPaymentMethodId(selected.value)}
                placeholder="Выберите метод оплаты"
                isSearchable
                styles={{
                  control: (base) => ({
                    ...base,
                    borderRadius: '5px',
                    fontSize: '1rem',
                    padding: '0.5rem',
                  }),
                }}
              />
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <label style={{ fontWeight: 'bold', display: 'block', marginBottom: '0.5rem' }}>
                Адрес доставки
              </label>
              <input
                type="text"
                placeholder="Введите адрес доставки"
                value={shippingAddress}
                onChange={(e) => setShippingAddress(e.target.value)}
                style={{
                  padding: '0.5rem',
                  fontSize: '1rem',
                  border: '1px solid #ccc',
                  borderRadius: '5px',
                  width: '100%',
                }}
              />
            </div>
            <SubmitButton onClick={handleSubmit}>Оформить заказ</SubmitButton>
          </OrderFormContainer>
        )}
      </ModalContent>
    </ModalOverlay>
  );
}

export default CategoryOrderList;