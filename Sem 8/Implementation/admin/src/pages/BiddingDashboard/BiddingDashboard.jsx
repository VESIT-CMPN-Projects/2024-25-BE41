import React, { useState, useEffect } from "react";
import axios from "axios";
import "./biddingDashboard.css";

const BiddingDashboard = ({ url }) => {
  const [queries, setQueries] = useState([]);
  const [bids, setBids] = useState([]);
  const [selectedQuery, setSelectedQuery] = useState(null);
  const [bidDetails, setBidDetails] = useState({ bidPrice: "", estimatedDeliveryTime: "", additionalInfo: "" });

  useEffect(() => {
    axios.get(url + "/api/bids/queries")
      .then(response => {
        setQueries(response.data)
        console.log(response.data)
      })
      .catch(error => console.error("Error fetching queries:", error));
  }, []);

  const fetchBids = (queryId) => {
    axios.get(url + "/api/bids/" + queryId)
      .then(response => setBids(response.data))
      .catch(error => console.error("Error fetching bids:", error));
  };

  const submitBid = () => {
    if (!selectedQuery) return;

    const bidData = {
      queryId: selectedQuery.query_id,
      userId: localStorage.getItem('user_id'),
      bidPrice: parseFloat(bidDetails.bidPrice),
      estimatedDeliveryTime: parseInt(bidDetails.estimatedDeliveryTime),
      additionalInfo: bidDetails.additionalInfo,
    };

    axios.post(url + "/api/bids/submit", bidData)
      .then(response => {
        alert("Bid submitted successfully!");
        setBidDetails({ bidPrice: "", estimatedDeliveryTime: "", additionalInfo: "" });
        fetchBids(selectedQuery.query_id);
      })
      .catch(error => console.error("Error submitting bid:", error));
  };

  return (
    <div className="bidding-container">
      <h1 className="bidding-header">Restaurant Bidding Dashboard</h1>

      <div className="grid grid-cols-2 gap-4">
        <div className="bidding-queries">
          <h2 className="bidding-header">Active Queries</h2>
          {queries.map(query => (
            <div key={query.query_id} className="bidding-query-card" onClick={() => setSelectedQuery(query)}>

              <p><strong>Name :</strong> {query.full_name}</p>
              <p><strong>Contact:</strong> {query.user_email}</p>
              <p><strong>Food Type:</strong> {query.food_type}</p>
              <p><strong>Items:</strong> {query.food_items}</p>
              <p><strong>Event Date:</strong> {query.event_date}</p>
              <p><strong>Event Time:</strong> {query.event_time}</p>
              <p><strong>Occasion:</strong> {query.occasion}</p>
              <p><strong>People:</strong> {query.people}</p>
              <p><strong>Budget:</strong> ₹{query.budget}</p>
            </div>
          ))}
        </div>

        {selectedQuery && (
          <div className="bidding-form">
            <h2 className="bidding-header">Placing Your Bid for {selectedQuery.full_name}'s query </h2>
            <div>
              <label>Bid Price (₹):</label>
              <input type="number" className="bidding-form-input" value={bidDetails.bidPrice} onChange={e => setBidDetails({ ...bidDetails, bidPrice: e.target.value })} />

              <label>Estimated Delivery Time (mins):</label>
              <input type="number" className="bidding-form-input" value={bidDetails.estimatedDeliveryTime} onChange={e => setBidDetails({ ...bidDetails, estimatedDeliveryTime: e.target.value })} />

              <label>Additional Info:</label>
              <textarea className="bidding-form-input" value={bidDetails.additionalInfo} onChange={e => setBidDetails({ ...bidDetails, additionalInfo: e.target.value })}></textarea>

              <button className="bidding-submit-btn" onClick={submitBid}>Submit Bid</button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default BiddingDashboard;
