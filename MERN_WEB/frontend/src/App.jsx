import React from 'react'
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { Toaster } from 'react-hot-toast'
import { AuthProvider } from './contexts/AuthContext'
import { CartProvider } from './contexts/CartContext'
import { StripeProvider } from './contexts/StripeContext'
import Navbar from './components/layout/Navbar'
import Footer from './components/layout/Footer'
import Home from './pages/Home'
import Products from './pages/Products'
import ProductDetail from './pages/ProductDetail'
import VendorProfile from './pages/VendorProfile'
import Cart from './pages/Cart'
import Checkout from './pages/Checkout'
import Login from './pages/auth/Login'
import Register from './pages/auth/Register'
import UserDashboard from './pages/dashboard/UserDashboard'
import VendorDashboard from './pages/dashboard/VendorDashboard'
import AdminDashboard from './pages/dashboard/AdminDashboard'
import ProtectedRoute from './components/auth/ProtectedRoute'

function App() {
  return (
    <Router>
      <AuthProvider>
        <CartProvider>
          <StripeProvider>
            <div className="min-h-screen flex flex-col">
              <Navbar />
              <main className="flex-grow">
                <Routes>
                  <Route path="/" element={<Home />} />
                  <Route path="/products" element={<Products />} />
                  <Route path="/products/:id" element={<ProductDetail />} />
                  <Route path="/vendors/:id" element={<VendorProfile />} />
                  <Route path="/cart" element={<Cart />} />
                  <Route path="/login" element={<Login />} />
                  <Route path="/register" element={<Register />} />
                  
                  {/* Protected Routes */}
                  <Route path="/checkout" element={
                    <ProtectedRoute>
                      <Checkout />
                    </ProtectedRoute>
                  } />
                  <Route path="/dashboard" element={
                    <ProtectedRoute>
                      <UserDashboard />
                    </ProtectedRoute>
                  } />
                  <Route path="/vendor-dashboard" element={
                    <ProtectedRoute requiredRole="vendor">
                      <VendorDashboard />
                    </ProtectedRoute>
                  } />
                  <Route path="/admin-dashboard" element={
                    <ProtectedRoute requiredRole="admin">
                      <AdminDashboard />
                    </ProtectedRoute>
                  } />
                </Routes>
              </main>
              <Footer />
            </div>
            <Toaster position="top-right" />
          </StripeProvider>
        </CartProvider>
      </AuthProvider>
    </Router>
  )
}

export default App
