import React, { useState } from 'react';
import Sidebar from './components/Sidebar/Sidebar';
import Navbar from './components/Navbar/Navbar';
import { Route, Routes } from 'react-router-dom';
import Add from './pages/Add/Add';
import List from './pages/List/List';
import Orders from './pages/Orders/Orders';
import Query from './pages/Query/Query';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import LoginPopup from './components/LoginPopup/LoginPopup'; // Import the LoginPopup component
import RestaurantDashboard from './pages/Dashboard/RestaurantDashboard';
import BiddingDashboard from './pages/BiddingDashboard/BiddingDashboard';

const App = () => {
  const [isAuthenticated, setIsAuthenticated] = useState(false); // State for authentication
  const [userData , setUserData] = useState({});
  const url = "http://localhost:8080";

  return (
    <div>
      <ToastContainer />
      {/* Show login popup if not authenticated */}
      {!isAuthenticated ? (
        <LoginPopup url ={url} setUserData={setUserData} setIsAuthenticated={setIsAuthenticated} />
      ) : (
        <>
          <Navbar></Navbar>
          <hr />
          <div className="app-content">
            <Sidebar></Sidebar>
            <Routes>
              <Route path='/add' element={<Add url={url} userData={userData}   ></Add>}></Route>
              <Route path='/list' element={<List url={url} userData={userData}  ></List>}></Route>
              <Route path='/orders' element={<Orders url={url} ></Orders>}></Route>
              <Route path='/query' element={<Query url={url} ></Query>}></Route>
              <Route path='/dashboard' element={<RestaurantDashboard url={url} ></RestaurantDashboard>}></Route>
              <Route path='/bid' element={<BiddingDashboard url={url} ></BiddingDashboard>}></Route>
            </Routes>
          </div>
        </>
      )}
    </div>
  );
};

export default App;
