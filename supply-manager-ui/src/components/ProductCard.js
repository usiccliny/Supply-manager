import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useParams, useNavigate } from 'react-router-dom';
import styled from 'styled-components';

const FullScreenContainer = styled.div`
  display: flex;
  flex-direction: column;
  height: 100vh;
  padding: 2rem;
  background: #f5f7fa;
`;

const Header = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;

  h1 {
    font-size: 2rem;
    color: #333;
  }
`;

const BackButton = styled.button`
  padding: 0.8rem 1.5rem;
  font-size: 1rem;
  color: #fff;
  background: linear-gradient(135deg, rgba(71, 159, 255, 0.8) 0%, rgba(128, 196, 255, 0.6) 100%);
  border: none;
  border-radius: 5px;
  cursor: pointer;
  transition: transform 0.3s;

  &:hover {
    transform: translateY(-2px);
  }
`;

const ContentWrapper = styled.div`
  display: flex;
  flex: 1;
  gap: 2rem;
`;

const MediaSection = styled.div`
  flex: 1;
  position: relative;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);

  img,
  video {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
`;

const MediaControls = styled.div`
  position: absolute;
  top: 50%;
  left: 0;
  right: 0;
  display: flex;
  justify-content: space-between;
  transform: translateY(-50%);
  z-index: 10;

  button {
    background: rgba(0, 0, 0, 0.6);
    color: #fff;
    border: none;
    padding: 0.8rem;
    border-radius: 50%;
    cursor: pointer;
    transition: background 0.3s;

    &:hover {
      background: rgba(0, 0, 0, 0.8);
    }
  }
`;

const InfoSection = styled.div`
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
`;

const SectionTitle = styled.h3`
  font-size: 1.2rem;
  margin-bottom: 0.8rem;
  color: #555;
  text-transform: uppercase;
  letter-spacing: 1px;
`;

const CardField = styled.div`
  margin-bottom: 0.6rem;

  span {
    font-weight: bold;
    color: #777;
    margin-right: 0.5rem;
  }
`;

const AttributesList = styled.ul`
  list-style: none;
  padding: 0;
  margin: 0;

  li {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 0.5rem;

    span {
      font-weight: bold;
      color: #333;
    }

    div {
      display: flex;
      gap: 0.5rem;
    }
  }
`;

const AttributeInput = styled.input`
  padding: 0.5rem;
  border: 1px solid #ccc;
  border-radius: 5px;
  margin-right: 0.5rem;
`;

const ActionButton = styled.button`
  padding: 0.5rem 1rem;
  font-size: 0.9rem;
  color: #fff;
  background: ${(props) => (props.danger ? '#e74c3c' : '#3498db')};
  border: none;
  border-radius: 5px;
  cursor: pointer;
  transition: transform 0.3s;

  &:hover {
    transform: translateY(-2px);
  }
`;

const AddAttributeForm = styled.form`
  display: flex;
  gap: 0.5rem;
  margin-top: 1rem;

  input {
    flex: 1;
    padding: 0.5rem;
    border: 1px solid #ccc;
    border-radius: 5px;
  }

  button {
    padding: 0.5rem 1rem;
    font-size: 0.9rem;
    color: #fff;
    background: #2ecc71;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    transition: transform 0.3s;

    &:hover {
      transform: translateY(-2px);
    }
  }
`;

const ProductCard = () => {
  const { productId } = useParams();
  const [product, setProduct] = useState(null);
  const [attributes, setAttributes] = useState([]);
  const [mediaIndex, setMediaIndex] = useState(0);
  const navigate = useNavigate();
  const userId = localStorage.getItem('userId');

  useEffect(() => {
    const fetchProduct = async () => {
      try {
        const response = await axios.get(`http://localhost:8080/api/products/${productId}`);
        setProduct(response.data);
        setAttributes(response.data.attributes || []);
      } catch (err) {
        console.error(err);
        alert('Ошибка при загрузке данных товара.');
      }
    };
    fetchProduct();
  }, [productId]);

  const handleBack = () => {
    navigate('/suppliers');
  };

  const handleNextMedia = () => {
    setMediaIndex((prev) => (prev + 1) % media.length);
  };

  const handlePrevMedia = () => {
    setMediaIndex((prev) => (prev - 1 + media.length) % media.length);
  };

  const handleUpdateAttribute = async (attributeId, value) => {
    if (!isEditable()) return;

    try {
      await axios.put(`http://localhost:8080/api/products/${productId}/attributes/${attributeId}`, null, {
        params: { value },
      });
      setAttributes((prev) =>
        prev.map((attr) => (attr.id === attributeId ? { ...attr, value } : attr))
      );
    } catch (err) {
      console.error(err);
      alert('Ошибка при обновлении атрибута.');
    }
  };

  const handleDeleteAttribute = async (attributeId) => {
    if (!isEditable()) return;

    try {
      await axios.delete(`http://localhost:8080/api/products/${productId}/attributes/${attributeId}`);
      setAttributes((prev) => prev.filter((attr) => attr.id !== attributeId));
    } catch (err) {
      console.error(err);
      alert('Ошибка при удалении атрибута.');
    }
  };

  const handleAddAttribute = async (e) => {
    if (!isEditable()) return;

    e.preventDefault();
    const { name, value } = e.target.elements;

    try {
      const response = await axios.post(`http://localhost:8080/api/products/${productId}/attributes/add`, {
        productId: product.productId,
        productVersionId: product.productVersionId,
        name: name.value,
        value: value.value,
        type: 'string',
        unit: '',
      });

      setAttributes((prev) => [
        ...prev,
        { id: response.data.attributeId, name: response.data.name, value: response.data.value },
      ]);

      e.target.reset();
    } catch (err) {
      console.error(err);
      alert('Ошибка при добавлении атрибута.');
    }
  };

  const isEditable = () => {
    return userId && product?.userId === parseInt(userId, 10);
  };

  const photos = product?.photo?.split(';').filter((item) => item.trim()) || [];
  const videos = product?.video?.split(';').filter((item) => item.trim()) || [];
  const media = [...photos, ...videos];

  return (
    <FullScreenContainer>
      <Header>
        <h1>{product?.productName}</h1>
        <BackButton onClick={handleBack}>Назад</BackButton>
      </Header>

      <ContentWrapper>
        <MediaSection>
          {media.length > 0 ? (
            <>
              {media[mediaIndex].match(/\.(mp4|webm|ogg)$/i) ? (
                <video controls autoPlay muted>
                  <source src={media[mediaIndex]} type="video/mp4" />
                  Ваш браузер не поддерживает видео.
                </video>
              ) : (
                <img src={media[mediaIndex]} alt={`Фото ${mediaIndex + 1}`} />
              )}
              <MediaControls>
                <button onClick={handlePrevMedia}>&#10094;</button>
                <button onClick={handleNextMedia}>&#10095;</button>
              </MediaControls>
            </>
          ) : (
            <p>Нет доступных фото или видео.</p>
          )}
        </MediaSection>

        <InfoSection>
          <div>
            <SectionTitle>Основная информация</SectionTitle>
            <CardField>
              <span>Категория:</span> {product?.categoryName}
            </CardField>
            <CardField>
              <span>Статус:</span> {product?.productStatus}
            </CardField>
            <CardField>
              <span>Цена:</span> {product?.price.toLocaleString('ru-RU', { style: 'currency', currency: 'RUB' })}
            </CardField>
            <CardField>
              <span>Количество:</span> {product?.quantity}
            </CardField>
            <CardField>
              <span>Дата создания:</span> {new Date(product?.createdDate).toLocaleDateString()}
            </CardField>
          </div>

          <div>
            <SectionTitle>Атрибуты товара</SectionTitle>
            {attributes.length > 0 ? (
              <AttributesList>
                {attributes.map((attr) => (
                  <li key={attr.id}>
                    <span>{attr.name}:</span>
                    <div>
                      {isEditable() ? (
                        <>
                          <AttributeInput
                            defaultValue={attr.value}
                            onBlur={(e) => handleUpdateAttribute(attr.id, e.target.value)}
                          />
                          <ActionButton danger onClick={() => handleDeleteAttribute(attr.id)}>
                            Удалить
                          </ActionButton>
                        </>
                      ) : (
                        <span>{attr.value}</span>
                      )}
                    </div>
                  </li>
                ))}
              </AttributesList>
            ) : (
              <p>Нет атрибутов.</p>
            )}

            {isEditable() && (
              <AddAttributeForm onSubmit={handleAddAttribute}>
                <input type="text" name="name" placeholder="Название атрибута" required />
                <input type="text" name="value" placeholder="Значение атрибута" required />
                <button type="submit">Добавить</button>
              </AddAttributeForm>
            )}
          </div>
        </InfoSection>
      </ContentWrapper>
    </FullScreenContainer>
  );
};

export default ProductCard;