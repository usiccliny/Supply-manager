import React, { createContext, useState, useEffect } from "react";

export const DateContext = createContext();

export const DateProvider = ({ children }) => {
  const [selectedDate, setSelectedDate] = useState(() => {
    const storedDate = localStorage.getItem("selectedDate");
    return storedDate ? new Date(storedDate) : new Date();
  });

  const handleDateChange = (date) => {
    setSelectedDate(date);
    localStorage.setItem("selectedDate", date.toISOString());
  };

  return (
    <DateContext.Provider value={{ selectedDate, handleDateChange }}>
      {children}
    </DateContext.Provider>
  );
};