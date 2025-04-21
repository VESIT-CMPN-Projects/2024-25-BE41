import React, { useState } from 'react';
import './LoginPopup.css'; // Optional: For styling
import axios from 'axios'
const LoginPopup = ({ setIsAuthenticated, setUserData, url }) => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = async (e) => {
    e.preventDefault();
    console.log(url)
    let newUrl = url + "/api/user/login";
    const data = {
      username: username,
      password: password
    };

    const response = await axios.post(newUrl, data, {
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true"
      }
    },);
    console.log(response)
    if (response.status === 200 && response.data.user_role_id === 2) {
      console.log(response.data)
      setUserData(response.data);  // Save the token on success
      localStorage.setItem("token", response.data.token);

      localStorage.setItem("user_id", response.data.user_id);
      // navigate to orders page
      setIsAuthenticated(true)

      // setShowLogin(false);
    } else {
      alert(response.data.message);
    }
  };

  return (
    <div className="login-popup">
      <form onSubmit={handleLogin} className="login-popup-container">
        <div className="login-popup-title">Login</div>
        <div className="login-popup-input">
          <input
            type="text"
            name="username"
            onChange={(e) => setUsername(e.target.value)}
            placeholder='Your Username'
            required
            value={username}
          />
          <input
            type="password"
            name="password"
            onChange={(e) => setPassword(e.target.value)}
            placeholder='Your Password'
            value={password}
            required
          />
          <button type="submit">Login</button>    </div>
      </form>

    </div >
  );
};

export default LoginPopup;
