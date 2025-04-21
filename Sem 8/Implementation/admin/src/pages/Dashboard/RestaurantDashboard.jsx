import React, { useEffect, useState } from "react";
import axios from "axios";
import { BarChart, Bar, XAxis, YAxis, Tooltip, Legend, ResponsiveContainer } from "recharts";
import "./RestaurantDashboard.css"; // Import custom CSS file

const RestaurantDashboard = ({ url }) => {
  const [feedbackStats, setFeedbackStats] = useState([]);
  const [topDishes, setTopDishes] = useState([]);
  const [recentFeedback, setRecentFeedback] = useState([]);
  const [customers, setCustomers] = useState([]);

  useEffect(() => {
    fetchFeedbackStats();
    fetchTopDishes();
    fetchRecentFeedback();
    fetchCustomers();
  }, []);

  const restaurantId = 1;

  const fetchFeedbackStats = async () => {
    const response = await axios.get(`${url}/api/restaurant/feedback-stats/${restaurantId}`, {
      headers: { "ngrok-skip-browser-warning": "true" }
    });
    setFeedbackStats(response.data);
  };

  const fetchTopDishes = async () => {
    const response = await axios.get(`${url}/api/restaurant/top-dishes/${restaurantId}`, {
      headers: { "ngrok-skip-browser-warning": "true" }
    });
    setTopDishes(response.data);
  };

  const fetchRecentFeedback = async () => {
    const response = await axios.get(`${url}/api/restaurant/recent-feedback/${restaurantId}`, {
      headers: { "ngrok-skip-browser-warning": "true" }
    });
    setRecentFeedback(response.data);
  };
  const fetchCustomers = async () => {
    const response = await axios.get(`${url}/api/restaurant/customers/${restaurantId}`, {
      headers: { "ngrok-skip-browser-warning": "true" }
    });
    setCustomers(response.data);
  };

  return (
    <div className="dashboard-container">
      {/* Feedback Stats Chart */}
      <div className="card">
        <h2 className="card-title">Feedback Ratings</h2>
        <ResponsiveContainer width="100%" height={300}>
          <BarChart data={feedbackStats}>
            <XAxis dataKey="dishName" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Bar dataKey="averageRating" fill="#4F46E5" />
          </BarChart>
        </ResponsiveContainer>
      </div>

      {/* Top Sold Dishes */}
      <div className="card">
        <h2 className="card-title">Most Sold Dishes</h2>
        <table className="custom-table">
          <thead>
            <tr>
              <th>Dish</th>
              <th>Orders</th>
            </tr>
          </thead>
          <tbody>
            {topDishes.map((dish) => (
              <tr key={dish.dishId}>
                <td>{dish.dishName}</td>
                <td>{dish.orderCount}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Recent Feedback */}
      <div className="card ">
        <h2 className="card-title">Recent Feedback</h2>
        <ul className="feedback-list">
          {recentFeedback.map((feedback) => (
            <li key={feedback.id} className="feedback-item">
              <strong>{feedback.dishName}</strong>: {feedback.comment} (⭐ {feedback.rating})
            </li>
          ))}
        </ul>
      </div>
      <div className="card ">
        <h2 className="card-title">Recent Customers</h2>
        <ul className="feedback-list">
          {customers.map((customer) => (
            <li key={customers.id} className="feedback-item">
              <strong>{customer.full_name}</strong>: {customer.customer_count} 
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
};

export default RestaurantDashboard;
