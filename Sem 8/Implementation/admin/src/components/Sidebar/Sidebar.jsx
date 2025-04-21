import React from 'react'
import './Sidebar.css'
import { assets } from '../../assets/assets'
import { NavLink } from 'react-router-dom'
const Sidebar = () => {
  return (
    <div className='sidebar'>
      <div className="sidebar-options">
        <NavLink to="/add" className="sidebar-option">
          <img src={assets.add_icon} alt="" />
          <p>Add Items</p>
        </NavLink>
      </div>


      <div className="sidebar-options">
        <NavLink to="/list" className="sidebar-option">
          <img src={assets.order_icon} alt="" />
          <p>list Items</p>
        </NavLink>
      </div>

      <div className="sidebar-options">
        <NavLink to="/orders" className="sidebar-option">
          <img height={"32px"} src={assets.clipboard_icon} alt="" />
          <p>orders</p>
        </NavLink>
      </div>
      {/* <div className="sidebar-options">
        <NavLink to="/query" className="sidebar-option">
          <img height={"32px"} src={assets.question_icon} alt="" />
          <p>Queries</p>
        </NavLink>
      </div> */}
      <div className="sidebar-options">
        <NavLink to="/bid" className="sidebar-option">
          <img height={"32px"} src={assets.question_icon} alt="" />
          <p>Bidding</p>
        </NavLink>
      </div>
      <div className="sidebar-options">
        <NavLink to="/dashboard" className="sidebar-option">
          <img src={assets.bar_chart_icon} alt="" />
          <p>Dashboard</p>
        </NavLink>
      </div>

    </div>
  )
}

export default Sidebar
