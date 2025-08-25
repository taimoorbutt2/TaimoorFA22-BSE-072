import React from 'react'
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { Toaster } from 'react-hot-toast'
import { AuthProvider } from './contexts/AuthContext'
import { CartProvider } from './contexts/CartContext'
import { FavoritesProvider } from './contexts/FavoritesContext'
import { StripeProvider } from './contexts/StripeContext'
import Navbar from './components/layout/Navbar'
import Footer from './components/layout/Footer'
import Home from './pages/Home'
import Products from './pages/Products'
import ProductDetail from './pages/ProductDetail'
import VendorProfile from './pages/VendorProfile'
import About from './pages/About'
import Artisans from './pages/Artisans'
import Cart from './pages/Cart'
import Favorites from './pages/Favorites'
import Checkout from './pages/Checkout'
import Login from './pages/auth/Login'
import Register from './pages/auth/Register'
import Dashboard from './pages/dashboard/Dashboard'
import ProtectedRoute from './components/auth/ProtectedRoute'

function App() {
  console.log('🎨 App component rendering...')
  
  return (
    <Router>
      <AuthProvider>
        <CartProvider>
          <FavoritesProvider>
            <StripeProvider>
            <div className="min-h-screen flex flex-col">
              <Navbar />
              <main className="flex-grow">
                <Routes>
                  <Route path="/" element={<Home />} />
                  <Route path="/products" element={<Products />} />
                  <Route path="/products/:id" element={<ProductDetail />} />
                  <Route path="/vendors/:id" element={<VendorProfile />} />
                  <Route path="/about" element={<About />} />
                  <Route path="/artisans" element={<Artisans />} />
                  <Route path="/cart" element={<Cart />} />
                  <Route path="/favorites" element={<Favorites />} />
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
                      <Dashboard />
                    </ProtectedRoute>
                  } />

                </Routes>
              </main>
              <Footer />
            </div>
            <Toaster position="top-right" />
            </StripeProvider>
          </FavoritesProvider>
        </CartProvider>
      </AuthProvider>
    </Router>
  )
}

export default App
