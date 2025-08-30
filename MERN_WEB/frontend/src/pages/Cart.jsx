import React, { useState, useEffect } from 'react'
import { useCart } from '../contexts/CartContext'
import { useAuth } from '../contexts/AuthContext'
import { Link, useNavigate } from 'react-router-dom'
import { 
  FiTrash2, 
  FiPlus, 
  FiMinus, 
  FiShoppingBag, 
  FiHeart, 
  FiArrowRight,
  FiPackage,
  FiTruck,
  FiShield,
  FiCreditCard
} from 'react-icons/fi'
import toast from 'react-hot-toast'

const Cart = () => {
  const { items: cart, removeItem: removeFromCart, updateQuantity, clearCart, addItem } = useCart()
  const { isAuthenticated } = useAuth()
  const navigate = useNavigate()
  const [loading, setLoading] = useState(false)

  // Show real-time cart updates
  useEffect(() => {
    if (cart.length > 0) {
      console.log('Cart updated:', cart.length, 'items')
    }
  }, [cart])

  // Group cart items by vendor
  const cartByVendor = cart.reduce((acc, item) => {
    const vendorId = item.vendorId || 'unknown'
    if (!acc[vendorId]) {
      acc[vendorId] = {
        vendorName: item.vendorName || 'Unknown Vendor',
        items: [],
        subtotal: 0
      }
    }
    acc[vendorId].items.push(item)
    acc[vendorId].subtotal += item.price * item.quantity
    return acc
  }, {})

  const totalItems = cart.reduce((sum, item) => sum + item.quantity, 0)
  const totalAmount = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0)
  const shippingCost = totalAmount > 100 ? 0 : 9.99
  const finalTotal = totalAmount + shippingCost

  const handleQuantityChange = (itemId, newQuantity) => {
    if (newQuantity < 1) {
      removeFromCart(itemId)
      toast.success('Item removed from cart')
    } else {
      updateQuantity(itemId, newQuantity)
    }
  }

  const handleRemoveItem = (itemId) => {
    removeFromCart(itemId)
    toast.success('Item removed from cart')
  }

  const handleCheckout = () => {
    if (!isAuthenticated) {
      toast.error('Please login to checkout')
      navigate('/login')
      return
    }
    
    if (cart.length === 0) {
      toast.error('Your cart is empty')
      return
    }

    setLoading(true)
    // Simulate checkout process
    setTimeout(() => {
      navigate('/checkout')
      setLoading(false)
    }, 1000)
  }

  if (cart.length === 0) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-50 via-blue-50 to-purple-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div className="max-w-md w-full text-center">
          <div className="mx-auto h-24 w-24 bg-gradient-to-br from-gray-200 to-gray-300 rounded-full flex items-center justify-center mb-6 animate-pulse">
            <FiShoppingBag className="w-12 h-12 text-gray-400" />
          </div>
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Your cart is empty</h2>
          <p className="text-gray-600 mb-6">Looks like you haven't added any products to your cart yet.</p>
          <p className="text-sm text-gray-500 mb-8">Add products from our featured collection or browse all categories!</p>
          <div className="space-y-3">
            <Link
              to="/products"
              className="w-full bg-gradient-to-r from-blue-600 to-purple-600 text-white px-6 py-3 rounded-lg hover:from-blue-700 hover:to-purple-700 transition-all duration-200 inline-block font-medium shadow-lg hover:shadow-xl transform hover:scale-105"
            >
              Browse All Products
            </Link>
            <Link
              to="/"
              className="w-full border-2 border-gray-300 text-gray-700 px-6 py-3 rounded-lg hover:bg-gray-100 hover:border-gray-400 transition-all duration-200 inline-block font-medium"
            >
              Continue Shopping
            </Link>
          </div>
          
          {/* Real-time cart status */}
          <div className="mt-8 p-4 bg-white rounded-lg border border-gray-200 shadow-sm">
            <p className="text-xs text-gray-500">
              Cart updates in real-time • Items persist across sessions
            </p>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Shopping Cart</h1>
              <p className="text-gray-600 mt-2">You have {totalItems} item{totalItems !== 1 ? 's' : ''} in your cart</p>
            </div>
            <div className="flex items-center space-x-4">
              <div className="bg-gradient-to-r from-blue-600 to-purple-600 text-white px-4 py-2 rounded-lg">
                <span className="text-sm font-medium">Total: ${totalAmount.toFixed(2)}</span>
              </div>
              <div className="bg-green-100 text-green-800 px-3 py-2 rounded-lg">
                <span className="text-sm font-medium">Items: {totalItems}</span>
              </div>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Cart Items */}
          <div className="lg:col-span-2">
            {/* Cart by Vendor */}
            {Object.entries(cartByVendor).map(([vendorId, vendorData]) => (
              <div key={vendorId} className="bg-white rounded-xl shadow-sm border border-gray-200 mb-6 overflow-hidden">
                {/* Vendor Header */}
                <div className="bg-gradient-to-r from-gray-50 to-gray-100 px-6 py-4 border-b border-gray-200">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-3">
                      <FiPackage className="w-5 h-5 text-primary-600" />
                      <h3 className="font-semibold text-gray-900">{vendorData.vendorName}</h3>
                    </div>
                    <span className="text-sm text-gray-600">
                      {vendorData.items.length} item{vendorData.items.length !== 1 ? 's' : ''}
                    </span>
                  </div>
                </div>

                {/* Vendor Items */}
                <div className="divide-y divide-gray-200">
                                   {vendorData.items.map((item) => (
                   <div key={item._id} className="p-6">
                      <div className="flex items-center space-x-4">
                        {/* Product Image */}
                        <div className="flex-shrink-0">
                          <img
                            src={item.image}
                            alt={item.name}
                            className="w-20 h-20 rounded-lg object-cover border border-gray-200"
                          />
                        </div>

                        {/* Product Details */}
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center justify-between">
                            <div>
                              <h4 className="text-lg font-medium text-gray-900 mb-1">{item.name}</h4>
                              <p className="text-sm text-gray-600 mb-2">{item.description}</p>
                              <div className="flex items-center space-x-4 text-sm text-gray-500">
                                <span>Category: {item.category}</span>
                                <span>Vendor: {item.vendorName}</span>
                              </div>
                            </div>
                            <div className="text-right">
                              <p className="text-lg font-semibold text-gray-900">${item.price}</p>
                              <p className="text-sm text-gray-500">${(item.price * item.quantity).toFixed(2)}</p>
                            </div>
                          </div>

                          {/* Quantity Controls */}
                          <div className="flex items-center justify-between mt-4">
                            <div className="flex items-center space-x-3">
                                                         <button
                             onClick={() => handleQuantityChange(item._id, item.quantity - 1)}
                             className="w-8 h-8 rounded-full border border-gray-300 flex items-center justify-center hover:bg-gray-50 transition-colors duration-200"
                           >
                             <FiMinus className="w-3 h-3 text-gray-600" />
                           </button>
                           <span className="w-12 text-center font-medium text-gray-900">{item.quantity}</span>
                           <button
                             onClick={() => handleQuantityChange(item._id, item.quantity + 1)}
                             className="w-8 h-8 rounded-full border border-gray-300 flex items-center justify-center hover:bg-gray-50 transition-colors duration-200"
                           >
                             <FiPlus className="w-3 h-3 text-gray-600" />
                           </button>
                         </div>
                         <button
                           onClick={() => handleRemoveItem(item._id)}
                           className="text-red-600 hover:text-red-800 p-2 rounded-lg hover:bg-red-50 transition-colors duration-200"
                         >
                           <FiTrash2 className="w-4 h-4" />
                         </button>
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>

                {/* Vendor Subtotal */}
                <div className="bg-gray-50 px-6 py-4 border-t border-gray-200">
                  <div className="flex items-center justify-between">
                    <span className="text-sm font-medium text-gray-700">Vendor Subtotal:</span>
                    <span className="text-lg font-semibold text-gray-900">${vendorData.subtotal.toFixed(2)}</span>
                  </div>
                </div>
              </div>
            ))}

            {/* Cart Actions */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
              <div className="flex items-center justify-between">
                <button
                  onClick={clearCart}
                  className="text-red-600 hover:text-red-800 font-medium hover:bg-red-50 px-4 py-2 rounded-lg transition-colors duration-200"
                >
                  Clear Cart
                </button>
                <Link
                  to="/products"
                  className="text-primary-600 hover:text-primary-800 font-medium hover:bg-primary-50 px-4 py-2 rounded-lg transition-colors duration-200"
                >
                  Continue Shopping
                </Link>
              </div>
            </div>
          </div>

          {/* Order Summary */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 sticky top-8">
              <h2 className="text-xl font-bold text-gray-900 mb-6">Order Summary</h2>
              
              {/* Summary Details */}
              <div className="space-y-4 mb-6">
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Subtotal ({totalItems} items)</span>
                  <span className="font-medium text-gray-900">${totalAmount.toFixed(2)}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Shipping</span>
                  <span className="font-medium text-gray-900">
                    {shippingCost === 0 ? 'Free' : `$${shippingCost.toFixed(2)}`}
                  </span>
                </div>
                {shippingCost > 0 && (
                  <div className="text-xs text-green-600 bg-green-50 p-2 rounded-lg">
                    🎉 Add ${(100 - totalAmount).toFixed(2)} more for free shipping!
                  </div>
                )}
                <div className="border-t border-gray-200 pt-4">
                  <div className="flex justify-between text-lg font-bold">
                    <span>Total</span>
                    <span>${finalTotal.toFixed(2)}</span>
                  </div>
                </div>
              </div>

              {/* Checkout Button */}
              <button
                onClick={handleCheckout}
                disabled={loading || cart.length === 0}
                className="w-full bg-gradient-to-r from-primary-600 to-artisan-600 text-white py-3 px-6 rounded-lg hover:from-primary-700 hover:to-artisan-700 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2 font-medium"
              >
                {loading ? (
                  <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                ) : (
                  <>
                    <span>Proceed to Checkout</span>
                    <FiArrowRight className="w-4 h-4" />
                  </>
                )}
              </button>

              {/* Security & Trust */}
              <div className="mt-6 pt-6 border-t border-gray-200">
                <div className="space-y-3">
                  <div className="flex items-center space-x-3 text-sm text-gray-600">
                    <FiShield className="w-4 h-4 text-green-600" />
                    <span>Secure checkout</span>
                  </div>
                  <div className="flex items-center space-x-3 text-sm text-gray-600">
                    <FiTruck className="w-4 h-4 text-blue-600" />
                    <span>Fast delivery</span>
                  </div>
                  <div className="flex items-center space-x-3 text-sm text-gray-600">
                    <FiCreditCard className="w-4 h-4 text-purple-600" />
                    <span>Multiple payment options</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Cart
