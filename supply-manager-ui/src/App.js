import React, { useEffect, useState } from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Navbar from "./components/Navbar";
import Dashboard from "./components/Dashboard";
import OrderList from "./components/OrderList";
import SupplierList from "./components/SupplierList";
import Report from "./components/Report";
import Profile from "./components/Profile";
import Register from "./components/Register";
import ProductCard from "./components/ProductCard";
import { DateProvider } from "./DateContext"; // Импортируем провайдер

const App = () => {
  const [loggedIn, setLoggedIn] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem("token");
    if (token) {
      setLoggedIn(true);
    }
  }, []);

  return (
    <DateProvider>
      <Router>
        <Navbar />
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/orders" element={<OrderList />} />
          <Route path="/suppliers" element={<SupplierList />} />
          <Route path="/reports" element={<Report />} />
          <Route path="/profile" element={<Profile loggedIn={loggedIn} />} />
          <Route path="/register" element={<Register />} />
          <Route path="/products/:productId" element={<ProductCard />} />
        </Routes>
      </Router>
    </DateProvider>
  );
};

export default App;