import React, { useState, useEffect } from "react";
import "./Orders.css";
import { toast } from "react-toastify";
import axios from "axios";
import { assets } from "../../assets/assets";

const Orders = ({ url }) => {
  const [orders, setOrders] = useState([]);

  const fetchOrders = async () => {
    try {
      const userId = localStorage.getItem("user_id");
      console.log("Fetching orders for user:", userId);

      const response = await axios.get(`${url}/api/food/order/list/${userId}`, {
        headers: { "ngrok-skip-browser-warning": "true" },
      });

      if (response.status === 200) {
        setOrders(response.data);
      } else {
        toast.error("Error fetching orders");
      }
    } catch (error) {
      console.error("Error fetching orders:", error);
      toast.error("Error fetching orders");
    }
  };

  const statusHandler = async (event, orderId) => {
    try {
      const response = await axios.post(
        `${url}/api/order/status`,
        { orderId, status: event.target.value },
        {
          headers: {
            "Content-Type": "application/json",
            "ngrok-skip-browser-warning": "true",
          },
        }
      );

      if (response.data.status === "successful") {
        toast.success("Order status updated");
        fetchOrders(); // Refresh orders after status update
      } else {
        toast.error("Error updating order status");
      }
    } catch (error) {
      console.error("Error updating order status:", error);
      toast.error("Error updating order status");
    }
  };

  useEffect(() => {
    fetchOrders();
  }, []);

  return (
    <div className="order-container">
      <h3 className="order-header">Order Page</h3>
      <div className="order-list">
        {orders.length === 0 ? (
          <p className="no-orders">No orders found</p>
        ) : (
          orders.map((order) => (
            <div key={order.order_id} className="order-item">
              <img src={assets.parcel_icon} alt="Parcel Icon" className="order-icon" />
              <div className="order-info">
                
                {/* User Details */}
                <div className="user-details">
                  <h4>User Details:</h4>
                  <p><strong>Name:</strong> {order.full_name}</p>
                  <p><strong>Email:</strong> {order.user_email}</p>
                  <p><strong>Phone:</strong> {order.user_phone}</p>
                </div>

                {/* Order Details */}
                <p className="restaurant-name">{order.restaurant_name}</p>
                <p>Order Date: {new Date(order.order_date).toLocaleDateString()}</p>
                <p>Total Amount: ₹{order.total_amount.toFixed(2)}</p>

                {/* Order Item Details */}
                <div className="order-details">
                  <h4>Items Ordered:</h4>
                  <ul>
                    {order.order_details?.map((item) => (
                      <li key={item.item_id}>
                        {item.item_name} - {item.quantity} × ₹{item.price} = ₹
                        {item.quantity * item.price}
                      </li>
                    ))}
                  </ul>
                </div>

                {/* Status Update Dropdown */}
                <select
                  className="status-dropdown"
                  onChange={(event) => statusHandler(event, order.order_id)}
                  value={order.order_status}
                >
                  <option value="Pending">Pending</option>
                  <option value="Out for Delivery">Out for Delivery</option>
                  <option value="Delivered">Delivered</option>
                </select>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default Orders;
