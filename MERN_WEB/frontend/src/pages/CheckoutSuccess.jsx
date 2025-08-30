import React from 'react'
import { Link } from 'react-router-dom'
import { FiCheckCircle, FiHome, FiShoppingBag, FiTruck } from 'react-icons/fi'

const CheckoutSuccess = () => {
  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-emerald-50 to-teal-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full text-center">
        {/* Success Icon */}
        <div className="mx-auto h-24 w-24 bg-gradient-to-br from-green-400 to-emerald-500 rounded-full flex items-center justify-center mb-6 animate-bounce">
          <FiCheckCircle className="w-12 h-12 text-white" />
        </div>

        {/* Success Message */}
        <h1 className="text-3xl font-bold text-gray-900 mb-4">Payment Successful!</h1>
        <p className="text-lg text-gray-600 mb-6">
          Thank you for your purchase. Your order has been confirmed and will be processed shortly.
        </p>

        {/* Order Details */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-8">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">What happens next?</h2>
          <div className="space-y-4">
            <div className="flex items-start space-x-3">
              <div className="bg-blue-100 p-2 rounded-full">
                <FiCheckCircle className="w-5 h-5 text-blue-600" />
              </div>
              <div className="text-left">
                <h3 className="font-medium text-gray-900">Order Confirmed</h3>
                <p className="text-sm text-gray-600">Your order has been received and confirmed</p>
              </div>
            </div>
            <div className="flex items-start space-x-3">
              <div className="bg-yellow-100 p-2 rounded-full">
                <FiShoppingBag className="w-5 h-5 text-yellow-600" />
              </div>
              <div className="text-left">
                <h3 className="font-medium text-gray-900">Processing</h3>
                <p className="text-sm text-gray-600">Vendors are preparing your items</p>
              </div>
            </div>
            <div className="flex items-start space-x-3">
              <div className="bg-purple-100 p-2 rounded-full">
                <FiTruck className="w-5 h-5 text-purple-600" />
              </div>
              <div className="text-left">
                <h3 className="font-medium text-gray-900">Shipping</h3>
                <p className="text-sm text-gray-600">Your order will be shipped soon</p>
              </div>
            </div>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="space-y-3">
          <Link
            to="/"
            className="w-full bg-gradient-to-r from-green-600 to-emerald-600 text-white px-6 py-3 rounded-lg hover:from-green-700 hover:to-emerald-700 transition-all duration-200 inline-block font-medium shadow-lg hover:shadow-xl transform hover:scale-105"
          >
            <FiHome className="w-5 h-5 inline mr-2" />
            Continue Shopping
          </Link>
          <Link
            to="/dashboard"
            className="w-full border-2 border-gray-300 text-gray-700 px-6 py-3 rounded-lg hover:bg-gray-100 hover:border-gray-400 transition-all duration-200 inline-block font-medium"
          >
            View Orders
          </Link>
        </div>

        {/* Additional Info */}
        <div className="mt-8 p-4 bg-white rounded-lg border border-gray-200 shadow-sm">
          <p className="text-xs text-gray-500">
            You will receive an email confirmation with order details and tracking information.
          </p>
        </div>
      </div>
    </div>
  )
}

export default CheckoutSuccess
