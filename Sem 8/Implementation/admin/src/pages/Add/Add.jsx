import React, { useState } from 'react'
import './Add.css'
import { assets } from '../../assets/assets'
import axios from 'axios'
import { toast } from 'react-toastify'

const Add = ({url , userData}) => {

 
  const [image, setImage] = useState(false);
  const [data, setData] = useState({
    name: '',
    description: '',
    category: 1,
    price: ''
  });

  const onChangeHandler = (event) => {
    const name = event.target.name;
    const value = event.target.value;
    setData({ ...data, [name]: value });
  }
  const onSubmitHandler = async (event) => {
    event.preventDefault();
    const formData = new FormData();
    formData.append('name', data.name);
    formData.append('description', data.description);
    formData.append('category', data.category);
    formData.append('price', Number(data.price));
    formData.append('user_id', localStorage.getItem("user_id"));
    console.log(formData);
    const response = await axios.post(`${url}/api/food/add`, formData, {
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true"
      }
    });
    console.log(response);
    if (response.data.success) {
      setData(
        {
          name: '',
          description: '',
          category: '1',
          price: ''
        }
      )
      setImage(false);
      toast.success(response.data.message)
    }
    else {
      toast.error(response.data.message);
    }
  }

  return (
    <div className='add'>
      <form className='flex-col' onSubmit={onSubmitHandler} >
        <div className="add-image-upload flex-col">
          {/* <p>Upload Image</p>
          <label htmlFor="image">
            <img src={image ? URL.createObjectURL(image) : assets.upload_area} alt="" />
          </label> */}
          {/* <input onChange={(e) => {
            setImage(e.target.files[0]);
          }} type="file" id="image" hidden required /> */}
        </div>
        <div className="add-product-name flex-col">
          <p>Product Name</p>
          <input onChange={onChangeHandler} value={data.name} type="text" name="name" id="" placeholder='Type Here..' />
        </div>
        <div className="add-product-description flex-col">
          <p>Product Description</p>
          <textarea onChange={onChangeHandler} value={data.description} name="description" rows="6" placeholder='Write Content here' required id=""></textarea>
        </div>
        <div className="add-category-price">
          <div className="add-category flex-col">
            <p> Product Category</p>
            <select onChange={onChangeHandler} name="category" id="">
              <option value="1">Veg</option>
              <option value="2">NonVeg</option>
            </select>
          </div>
          <div className="add-price flex-col">
            <p>Product Price</p>
            <input onChange={onChangeHandler} value={data.price} type="number" name="price" id="" placeholder='Type Here..' />
          </div>
        </div>
        <button type="submit" className='add-button' >Add</button>
      </form>


    </div>
  )
}

export default Add
