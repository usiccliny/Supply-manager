export const ratingsConfig = [
    {
      title: "Общий рейтинг поставщиков",
      description: "Рейтинг по текущим выставленным и заказанным товарам",
      endpoint: "http://localhost:8080/api/rating/supplier-total",
      position: { gridRow: 1, gridColumn: 1 },
    },
    {
      title: "Рейтинг популярности товаров",
      description: "Рейтинг товаров по выбранной категории",
      endpoint: (category) => `http://localhost:8080/api/rating/product-total?category=${encodeURIComponent(category)}`,
      position: { gridRow: 1, gridColumn: 2 },
    },
  ];