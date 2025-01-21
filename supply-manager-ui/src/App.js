import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar';
import Dashboard from './components/Dashboard';
import OrderList from './components/OrderList';
import SupplierList from './components/SupplierList';
import Report from './components/Report';

const App = () => {
  return (
    <Router>
      <Navbar />
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/orders" element={<OrderList />} />
        <Route path="/suppliers" element={<SupplierList />} />
        <Route path="/reports" element={<Report />} />
      </Routes>
    </Router>
  );
};

export default App;