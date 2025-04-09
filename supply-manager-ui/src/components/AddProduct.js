import React, { useEffect, useState } from 'react';
import axios from 'axios';
import styled from 'styled-components';
import Select from 'react-select'; // Библиотека для автодополнения
import { buildCategoryTree } from '../utils/categoryUtils';
import Breadcrumbs from '../utils/Breadcrumbs';

// Стили для модального окна
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
  width: 100%;
  max-width: 800px; // Увеличенная ширина формы
  padding: 3rem;
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
  position: relative;
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

const FormField = styled.div`
  margin-bottom: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
`;

const FormLabel = styled.label`
  font-size: 1rem;
  font-weight: bold;
  color: #333;
`;

const FormInput = styled.input`
  padding: 1rem;
  font-size: 1rem;
  border: 1px solid #ccc;
  border-radius: 5px;
  transition: border-color 0.3s;
  &:focus {
    border-color: #71a7ff;
    outline: none;
  }
`;

const FormButton = styled.button`
  padding: 1rem;
  font-size: 1rem;
  color: #fff;
  background: linear-gradient(135deg, rgba(71, 159, 255, 0.8) 0%, rgba(128, 196, 255, 0.6) 100%);
  border: none;
  border-radius: 5px;
  cursor: pointer;
  transition: transform 0.3s, box-shadow 0.3s;
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
  }
`;

const ErrorMessage = styled.p`
  color: red;
  font-size: 0.9rem;
  margin-top: 0.5rem;
`;

const AddProductForm = ({ onClose, onProductAdded, productToEdit }) => {
  const [categories, setCategories] = useState([]);
  const [statuses, setStatuses] = useState([]);
  const [productData, setProductData] = useState({
    username: localStorage.getItem('username'),
    categoryProduct: '',
    statusProduct: '',
    productName: '',
    price: '',
    quantity: '',
  });
  const [errors, setErrors] = useState({});
  const [categoryTree, setCategoryTree] = useState([]); // Древовидная структура категорий
  const [breadcrumbs, setBreadcrumbs] = useState(
    categoryTree.length > 0 ? [categoryTree.find((cat) => cat.parentId === null)] : []
  );

  // Инициализация состояния при редактировании
  useEffect(() => {
    if (productToEdit) {
      setProductData({
        username: localStorage.getItem('username'),
        categoryProduct: productToEdit.categoryName || '',
        statusProduct: productToEdit.productStatus || '',
        productName: productToEdit.productName || '',
        price: productToEdit.price || '',
        quantity: productToEdit.quantity || '',
      });

      // Устанавливаем хлебные крошки для категории
      const getCategoryBreadcrumbs = (tree, categoryId) => {
        const findCategory = (nodes, id) => {
          for (const node of nodes) {
            if (node.id === id) return [node];
            if (node.children) {
              const result = findCategory(node.children, id);
              if (result) return [node, ...result];
            }
          }
          return null;
        };
        return findCategory(tree, categoryId);
      };

      const breadcrumbs = getCategoryBreadcrumbs(categoryTree, productToEdit.categoryId);
      if (breadcrumbs) setBreadcrumbs(breadcrumbs);
    } else {
      setProductData({
        username: localStorage.getItem('username'),
        categoryProduct: '',
        statusProduct: '',
        productName: '',
        price: '',
        quantity: '',
      });
      setBreadcrumbs([categoryTree.find((cat) => cat.parentId === null)]); // Возвращаемся к корневой категории
    }
  }, [productToEdit, categoryTree]);

  // Загрузка данных категорий и статусов
  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const response = await axios.get('http://localhost:8080/api/products/category');
        const tree = buildCategoryTree(response.data);
        setCategories(response.data);
        setCategoryTree(tree);
        setBreadcrumbs([tree.find((cat) => cat.parentId === null)]); // Начинаем с корневой категории
      } catch (err) {
        console.error(err);
      }
    };

    const fetchStatuses = async () => {
      try {
        const response = await axios.get('http://localhost:8080/api/products/status');
        setStatuses(response.data.map((status) => ({ value: status.id, label: status.name })));
      } catch (err) {
        console.error(err);
      }
    };

    fetchCategories();
    fetchStatuses();
  }, []);

  // Обработка выбора категории
  const handleCategorySelect = (category) => {
    if (category.children.length > 0) {
      setBreadcrumbs((prev) => [...prev, category]);
    } else {
      setProductData({ ...productData, categoryProduct: category.name });
      setBreadcrumbs((prev) => [...prev, category]);
    }
  };

  // Обработка перехода по хлебным крошкам
  const handleBreadcrumbClick = (category) => {
    const newBreadcrumbs = breadcrumbs.slice(0, breadcrumbs.indexOf(category) + 1);
    setBreadcrumbs(newBreadcrumbs);

    // Сбрасываем состояние категории, если выбранная категория имеет дочерние элементы
    const selectedCategory = newBreadcrumbs[newBreadcrumbs.length - 1];
    if (selectedCategory.children && selectedCategory.children.length > 0) {
      setProductData({ ...productData, categoryProduct: '' });
      setErrors({ ...errors, categoryProduct: null });
    }
  };

  // Обработка изменений полей формы
  const handleInputChange = (field, value) => {
    setProductData({ ...productData, ['username']: localStorage.getItem('username'), [field]: value });
    setErrors({ ...errors, [field]: null }); // Очищаем ошибки при изменении поля
  };

  // Валидация формы
  const validateForm = () => {
    const newErrors = {};
    if (!productData.categoryProduct) {
      newErrors.categoryProduct = 'Категория обязательна для заполнения.';
    }
    if (!productData.statusProduct) {
      newErrors.statusProduct = 'Статус обязателен для заполнения.';
    }
    if (!productData.productName) {
      newErrors.productName = 'Название товара обязательно для заполнения.';
    }
    if (!productData.price || productData.price < 0) {
      newErrors.price = 'Цена должна быть больше или равна 0.';
    }
    if (!productData.quantity || productData.quantity <= 0) {
      newErrors.quantity = 'Количество должно быть больше или равно 0.';
    }
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0; // Форма валидна, если нет ошибок
  };

  // Отправка формы
  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validateForm()) return;

    try {
      const method = productToEdit ? 'put' : 'post';
      const url = productToEdit
        ? `http://localhost:8080/api/products/update`
        : 'http://localhost:8080/api/products/add';

      await axios[method](url, productData);
      alert(`${productToEdit ? 'Товар обновлен' : 'Товар добавлен'} успешно!`);
      onClose();
      onProductAdded();
    } catch (err) {
      console.error(err);
      alert(`Ошибка при ${productToEdit ? 'обновлении' : 'добавлении'} товара.`);
    }
  };

  return (
    <ModalOverlay>
      <ModalContent>
        <CloseButton onClick={onClose}>&times;</CloseButton>
        <h3 style={{ marginBottom: '2rem' }}>
          {productToEdit ? 'Редактирование товара' : 'Добавление товара'}
        </h3>
        <form onSubmit={handleSubmit}>
          {/* Хлебные крошки */}
          <Breadcrumbs breadcrumbs={breadcrumbs} onSelect={handleBreadcrumbClick} />

          {/* Выбор категории */}
          <FormField>
            <FormLabel>Категория товара</FormLabel>
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
            {errors.categoryProduct && <ErrorMessage>{errors.categoryProduct}</ErrorMessage>}
          </FormField>

          {/* Выбор статуса */}
          <FormField>
            <FormLabel>Статус товара</FormLabel>
            <Select
              options={statuses}
              onChange={(selected) => handleInputChange('statusProduct', selected?.label)}
              placeholder="Выберите статус"
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
            {errors.statusProduct && <ErrorMessage>{errors.statusProduct}</ErrorMessage>}
          </FormField>

          {/* Название товара */}
          <FormField>
            <FormLabel>Название товара</FormLabel>
            <FormInput
              type="text"
              placeholder="Введите наименование товара"
              value={productData.productName}
              onChange={(e) => handleInputChange('productName', e.target.value)}
              required
            />
            {errors.productName && <ErrorMessage>{errors.productName}</ErrorMessage>}
          </FormField>

          {/* Цена товара */}
          <FormField>
            <FormLabel>Цена товара</FormLabel>
            <FormInput
              type="number"
              placeholder="Введите цену товара"
              value={productData.price}
              min="0"
              onChange={(e) => {
                const value = Math.max(0, e.target.value);
                handleInputChange('price', value);
              }}
              required
            />
            {errors.price && <ErrorMessage>{errors.price}</ErrorMessage>}
          </FormField>

          {/* Количество товара */}
          <FormField>
            <FormLabel>Количество товара</FormLabel>
            <FormInput
              type="number"
              placeholder="Введите количество товара"
              value={productData.quantity}
              min="0"
              onChange={(e) => {
                const value = Math.max(0, e.target.value);
                handleInputChange('quantity', value);
              }}
              required
            />
            {errors.quantity && <ErrorMessage>{errors.quantity}</ErrorMessage>}
          </FormField>

          {/* Кнопка отправки формы */}
          <FormButton type="submit">
            {productToEdit ? 'Сохранить изменения' : 'Добавить товар'}
          </FormButton>
        </form>
      </ModalContent>
    </ModalOverlay>
  );
};

export default AddProductForm;