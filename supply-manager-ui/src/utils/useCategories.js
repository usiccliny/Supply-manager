import { useState, useEffect } from "react";
import axios from "axios";

const useCategories = () => {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const response = await axios.get("http://localhost:8080/api/products/category");
        const filteredCategories = response.data.filter((category) => category.nestingLevel === 3);
        setCategories(filteredCategories);
        setLoading(false);
      } catch (err) {
        setError("Ошибка загрузки категорий.");
        setLoading(false);
      }
    };

    fetchCategories();
  }, []);

  return { categories, loading, error };
};

export default useCategories;