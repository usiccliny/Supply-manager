import React, { useState, useEffect } from 'react';
import axios from 'axios';
import styled from 'styled-components';
import AddProductForm from './AddProduct'; // Форма добавления/редактирования товара

// Стили для таблицы
const ProductTable = styled.table`
  width: 100%;
  border-collapse: collapse;

  th,
  td {
    padding: 0.6rem;
    text-align: left;
    border-bottom: 1px solid #ddd;
  }

  th {
    background: #f4f4f4;
    font-weight: bold;
  }

  tr:hover {
    background: #f9f9f9;
  }
`;

const ProductRegistryWidget = styled.div`
  width: 100%;
  max-width: 1200px;
  padding: 1.5rem;
  border-radius: 10px;
  color: #333;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
  background: #f9f9f9;
`;

const FiltersContainer = styled.div`
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
`;

const FilterButton = styled.button`
  padding: 0.6rem 1rem;
  font-size: 0.9rem;
  color: #fff;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  transition: transform 0.3s, box-shadow 0.3s;

  &.active {
    transform: scale(1.05);
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
  }

  &.all {
    background: linear-gradient(135deg, rgba(71, 159, 255, 0.8) 0%, rgba(128, 196, 255, 0.6) 100%);
  }

  &.available {
    background: #a8dadc;
  }

  &.ended {
    background: #ffafcc;
  }

  &.coming {
    background: #ffd6a5;
  }
`;

const AddProductButton = styled.button`
  margin-top: 1rem;
  padding: 0.8rem 1.5rem;
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

const ActionButton = styled.button`
  padding: 0.4rem 0.8rem;
  font-size: 0.8rem;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  transition: transform 0.3s, box-shadow 0.3s;

  &:hover {
    transform: scale(1.05);
  }

  &.edit {
    background: #a8dadc;
    color: #333;
  }

  &.delete {
    background: #ffafcc;
    color: #fff;
  }
`;

const ProductRegistry = () => {
  const [products, setProducts] = useState([]); // Все товары
  const [filteredProducts, setFilteredProducts] = useState([]); // Отфильтрованные товары
  const [activeFilter, setActiveFilter] = useState('all'); // Активный фильтр
  const [isFormVisible, setIsFormVisible] = useState(false); // Видимость формы
  const [editingProduct, setEditingProduct] = useState(null); // Товар для редактирования

  // Загрузка данных из API
  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const response = await axios.get('http://localhost:8080/api/products/catalog');
        setProducts(response.data);
        setFilteredProducts(response.data); // Изначально показываем все товары
      } catch (err) {
        console.error(err);
      }
    };
    fetchProducts();
  }, []);

  // Функция для обновления данных после добавления/редактирования
  const refreshProducts = async () => {
    try {
      const response = await axios.get('http://localhost:8080/api/products/catalog');
      setProducts(response.data);
      setFilteredProducts(response.data); // Обновляем отфильтрованные товары
    } catch (err) {
      console.error(err);
    }
  };

  // Фильтрация товаров
  const handleFilterChange = (status) => {
    setActiveFilter(status);
    if (status === 'all') {
      setFilteredProducts(products); // Показать все товары
    } else {
      const filtered = products.filter((product) => product.productStatus === status);
      setFilteredProducts(filtered); // Показать товары только с выбранным статусом
    }
  };

  // Обработка редактирования товара
  const handleEditProduct = (product) => {
    setEditingProduct(product); // Устанавливаем товар для редактирования
    setIsFormVisible(true); // Показываем форму
  };

  // Обработка удаления товара
  const handleDeleteProduct = async (product) => {
    if (window.confirm(`Вы уверены, что хотите удалить товар "${product.productName}"?`)) {
      try {
        await axios.delete(`http://localhost:8080/api/products/delete/${product.productId}`);
        alert('Товар успешно удален!');
        refreshProducts(); // Обновляем список товаров
      } catch (err) {
        console.error(err);
        alert('Ошибка при удалении товара.');
      }
    }
  };

  return (
    <ProductRegistryWidget>
      <h3>Реестр продуктов</h3>

      {/* Фильтры */}
      <FiltersContainer>
        <FilterButton
          className={`all ${activeFilter === 'all' ? 'active' : ''}`}
          onClick={() => handleFilterChange('all')}
        >
          Все товары
        </FilterButton>
        <FilterButton
          className={`available ${activeFilter === 'Есть в наличии' ? 'active' : ''}`}
          onClick={() => handleFilterChange('Есть в наличии')}
        >
          Доступные
        </FilterButton>
        <FilterButton
          className={`ended ${activeFilter === 'Закончился' ? 'active' : ''}`}
          onClick={() => handleFilterChange('Закончился')}
        >
          Закончившиеся
        </FilterButton>
        <FilterButton
          className={`coming ${activeFilter === 'Скоро появится' ? 'active' : ''}`}
          onClick={() => handleFilterChange('Скоро появится')}
        >
          Ожидающие
        </FilterButton>
      </FiltersContainer>

      {/* Таблица товаров */}
      {filteredProducts.length > 0 ? (
        <ProductTable>
          <thead>
            <tr>
              <th>Категория</th>
              <th>Статус</th>
              <th>Название товара</th>
              <th>Цена</th>
              <th>Количество</th>
              <th>Дата создания</th>
              <th>Действия</th>
            </tr>
          </thead>
          <tbody>
            {filteredProducts.map((product, idx) => (
              <tr key={idx}>
                <td>{product.categoryName}</td>
                <td>{product.productStatus}</td>
                <td>{product.productName}</td>
                <td>{product.price.toLocaleString('ru-RU', { style: 'currency', currency: 'RUB' })}</td>
                <td>{product.quantity}</td>
                <td>{new Date(product.createdDate).toLocaleDateString()}</td>
                <td>
                  <ActionButton className="edit" onClick={() => handleEditProduct(product)}>
                    Редактировать
                  </ActionButton>
                  <ActionButton
                    className="delete"
                    onClick={() => handleDeleteProduct(product)}
                    style={{ marginLeft: '0.5rem' }}
                  >
                    Удалить
                  </ActionButton>
                </td>
              </tr>
            ))}
          </tbody>
        </ProductTable>
      ) : (
        <p>Нет товаров в этой категории.</p>
      )}

      {/* Кнопка добавления товара */}
      <AddProductButton onClick={() => setIsFormVisible(true)}>Добавить товар</AddProductButton>

      {/* Модальное окно формы */}
      {isFormVisible && (
        <AddProductForm
          onClose={() => {
            setIsFormVisible(false);
            setEditingProduct(null); // Сбрасываем состояние редактирования
          }}
          onProductAdded={refreshProducts}
          productToEdit={editingProduct} // Передаем товар для редактирования
        />
      )}
    </ProductRegistryWidget>
  );
};

export default ProductRegistry;