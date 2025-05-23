### README.md

#### Проект: **Supply Manager**

Это репозиторий для системы управления поставками (**Supply Manager**). Проект включает **backend API** и **frontend UI**, а также различные документы и диаграммы для описания архитектуры и структуры данных.

---

## 📂 Структура проекта

### Корневая директория

- **supply-manager-api/**: Backend API.
- **supply-manager-ui/**: Frontend UI.
- **ER APM.drawio.html**: Интерактивная ER-диаграмма базы данных.
- **ER-диаграмма.png**: Изображение ER-диаграммы.
- **UML архитектура системы.png**: UML-диаграмма архитектуры.
- **supply_manager_db - supply_manager.png**: Диаграмма базы данных.
- **supply_manager_schema.txt**: Описание схемы базы данных.

---

## 🖥️ 1. Backend API (`supply-manager-api`)

Backend API реализован на **Java** с использованием **Spring Boot**. Он обеспечивает взаимодействие с базой данных и предоставляет RESTful API для frontend-приложения.

### Основные директории:

#### `src/main/resources/db/`: Конфигурация базы данных
- **function/**: Хранит SQL-функции.
- **system-function/**: Содержит системные функции, такие как справочник ролей, функция максимального времени и таблица пользователей.
- **table/**: SQL-скрипты для создания и миграции таблиц.
- **view/**: SQL-запросы для представлений.
- **db.changelog-master.yaml**: Файл для управления миграциями базы данных (используется Liquibase).

#### `src/main/java/`: Исходный код приложения
- **config/**: Конфигурационные классы.
- **controller/**: Контроллеры для обработки HTTP-запросов.
- **dto/**: Data Transfer Objects (DTO) для передачи данных между слоями.
- **model/**: Модели данных, соответствующие сущностям в базе данных.
- **repository/**: Репозитории для работы с базой данных (например, JpaRepository).
- **service/**: Бизнес-логика и сервисы.

### Зависимости:
- **Spring Boot**
- **Spring Data JPA**
- **PostgreSQL** (или другая БД)
- **Liquibase** для миграций базы данных
- **JWT** для аутентификации

---

## 🖥️ 2. Frontend UI (`supply-manager-ui`)

Frontend UI разработан на **React**.

### Основные директории:

#### `public/`: Статические файлы (например, favicon.ico).

#### `src/`: Исходный код frontend-приложения.

##### Поддиректория `src/components/`: Компоненты пользовательского интерфейса.
- **AddProduct.js**: Компонент для добавления нового продукта.
- **AddReviewForm.js**: Форма для добавления отзыва.
- **CategoryOrderList.js**: Компонент для списка заказов по категориям.
- **Dashboard.js**: Панель администрирования.
- **Navbar.js**: Навигационная панель.
- **OrderCard.js**: Карточка заказа.
- **OrderList.js**: Список заказов.
- **ProductCard.js**: Карточка продукта.
- **ProductRegistry.js**: Регистрация продукта.
- **Profile.js**: Профиль пользователя.
- **RatingCard.js**: Карточка рейтинга.
- **Register.js**: Страница регистрации.
- **Report.js**: Отчеты.
- **ReviewCard.js**: Карточка отзыва.
- **SupplierList.js**: Список поставщиков.

##### Поддиректория `src/utils/`: Вспомогательные функции и хуки.
- **Breadcrumbs.js**: Компонент навигационных хлебных крошек.
- **categoryUtils.js**: Утилиты для работы с категориями.
- **ratingConfig.js**: Конфигурация рейтингов.
- **useCategories.js**: Хук для получения и использования категорий.

##### Дополнительные файлы:
- **App.js**: Главный компонент приложения.
- **App.css**: Стили для главного компонента.
- **index.js**: Точка входа приложения.
- **logo.svg**: Логотип приложения.

### Зависимости:
- **React**
- **React Router**
- **Axios** (для запросов к API)
- **Styled Components** (или CSS-in-JS)

---

## ▶️ Как запустить проект

### Backend (`supply-manager-api`)

1. Перейдите в директорию `supply-manager-api`:
   ```bash
   cd supply-manager-api
   ```

2. Установите зависимости:
   ```bash
   mvn clean install
   ```

3. Настройте переменные окружения (например, URL базы данных).

4. Запустите сервер:
   ```bash
   mvn spring-boot:run
   ```

### Frontend (`supply-manager-ui`)

1. Перейдите в директорию `supply-manager-ui`:
   ```bash
   cd supply-manager-ui
   ```

2. Установите зависимости:
   ```bash
   npm install
   ```

3. Запустите frontend-приложение:
   ```bash
   npm start
   ```