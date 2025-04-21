import React, { useState, useEffect } from "react";
import axios from "axios";
import "./Query.css"; // Import CSS for styling

const Query = ({ url }) => {
  const [queries, setQueries] = useState([]);

  useEffect(() => {
    fetchQueries();
  }, []);

  const fetchQueries = async () => {
    try {
      const response = await axios.get(
        `${url}/api/order/get-queries/${localStorage.getItem("user_id")}`,
        { headers: { "ngrok-skip-browser-warning": "true" } }
      );
      console.log("API Response:", response.data);
      setQueries(Array.isArray(response.data) ? response.data : []);
    } catch (error) {
      console.error("Error fetching queries:", error);
      setQueries([]);
    }
  };

  const handleDecision = async (queryId, decision) => {
    try {
      console.log("Query ID:", queryId, "Decision:", decision);
      const res = await axios.post(
        `${url}/api/order/query-decision`,
        { queryId: queryId, decision: decision },
        {
          headers: {
            "Content-Type": "application/json",
            "ngrok-skip-browser-warning": "true",
          },
        }
      );
      console.log("API Response:", res.data);
      fetchQueries();
    } catch (error) {
      console.error(`Error ${decision} query:`, error);
    }
  };

  return (
    <div className="queries">
      <h2>Event Queries</h2>
      <div className="container">
        {queries.length === 0 ? (
          <p>No queries available.</p>
        ) : (
          queries.map((query) => (
            <div key={query.query_id} className="query-card">
              <div className="query-header">
                <img src="/icons/event_icon.png" alt="Event" className="query-icon" />
                <div>
                  <h3>{query.food_type.toUpperCase()} | {query.occasion}</h3>
                  <p className="status">
                    <span>Status:</span> <b className={query.query_status}>{query.query_status}</b>
                  </p>
                </div>
              </div>
              
              <div className="query-details">
                <p><b>People:</b> {query.people}</p>
                <p><b>Food Items:</b> {query.food_items}</p>
                <p><b>Budget:</b> ₹{query.budget}</p>
                <p><b>Event Date:</b> {new Date(query.event_date).toLocaleDateString()}</p>
                <p><b>Event Time:</b> {query.event_time}</p>
                <p><b>Additional Info:</b> {query.additional_info}</p>
              </div>

              <div className="customer-details">
                <h4>Customer Details</h4>
                <p><b>Name:</b> {query.full_name}</p>
                <p><b>Phone:</b> {query.user_phone}</p>
                <p><b>Email:</b> {query.user_email}</p>
              </div>

              <div className="query-actions">
                <button
                  onClick={() => handleDecision(query.query_id, "accepted")}
                  className="accept-btn"
                >
                  Accept
                </button>
                <button
                  onClick={() => handleDecision(query.query_id, "rejected")}
                  className="reject-btn"
                >
                  Reject
                </button>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default Query;
