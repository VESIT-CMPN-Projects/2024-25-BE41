import userModel from "../models/userModel.js"

// add items to cart 
const addToCart = async (req,res) =>{
  try {
    let userData = await userModel.findOne({_id:req.body.userId})
    if(!userData){
      return res.json({
        success:false,
        message:"User not found"
      })
    }
    let cartData = await userData.cartData;
    if(!cartData[req.body.itemId]){
      cartData[req.body.itemId] = 1;
    }
    else
    {
      cartData[req.body.itemId] += 1;
    }
    await userModel.findByIdAndUpdate(req.body.userId , {cartData});
    return res.json({
      success:true,
      message:"Item added to cart"
    })
  } catch (error) {
    return res.json({
      success:false,
    message:error.message  
    })
  }

}
//  remove items from user Cart
const removeFromCart = async (req,res) =>{
try {
  let userData = await userModel.findById(req.body.userId);
  let cartData = userData.cartData;
  if(cartData[req.body.itemId]>0){
    cartData[req.body.itemId] -= 1;
  }
  await userModel.findByIdAndUpdate(req.body.userId , {cartData});
  return res.json({
    success:true,
    message:"Item removed from cart"
  })
} catch (error) {
  return res.json({
    success:false,
    message:"Item  not removed from cart"
  }) 
}
}
// fetch user cart data 
const getCart = async (req,res) =>{
  try {
    let userData = await userModel.findById(req.body.userId);
    let cartData = userData.cartData;
    return res.json({
      success:true,
      cartData
    })

  } catch (error) {
    return res.json({
      success:false,
      message:"Cart data not found"
    })
    
  }

}

export {addToCart,removeFromCart,getCart}