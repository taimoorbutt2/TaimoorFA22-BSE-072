import React, { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { FiArrowRight, FiStar, FiHeart, FiShoppingBag, FiUsers } from 'react-icons/fi'
import ThreeDCarousel from '../components/3DCarousel'
import { useFavorites } from '../contexts/FavoritesContext'
import { useCart } from '../contexts/CartContext'
import toast from 'react-hot-toast'

const Home = () => {
  const { addToFavorites, removeFromFavorites, isInFavorites } = useFavorites()
  const { addItem: addToCart } = useCart()
  const [featuredProducts, setFeaturedProducts] = useState([])
  const [loading, setLoading] = useState(true)
  const [apiError, setApiError] = useState(false)

  // Sample products that will always be shown
  const sampleProducts = [
    {
      _id: 'demo1',
      name: 'Handcrafted Silver Necklace',
      price: 89.99,
      rating: 4.8,
      reviewCount: 24,
      vendorName: 'SilverCraft Studio',
      image: 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=400&h=300&fit=crop'
    },
    {
      _id: 'demo2',
      name: 'Ceramic Vase Collection',
      price: 45.50,
      rating: 4.6,
      reviewCount: 18,
      vendorName: 'Earth & Fire Pottery',
      image: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop'
    },
    {
      _id: 'demo3',
      name: 'Handwoven Cotton Scarf',
      price: 32.00,
      rating: 4.9,
      reviewCount: 31,
      vendorName: 'Textile Traditions',
      image: 'https://images.unsplash.com/photo-1520903920243-00d872a2d1c9?w=400&h=300&fit=crop'
    },
    {
      _id: 'demo4',
      name: 'Wooden Wall Art',
      price: 125.00,
      rating: 4.7,
      reviewCount: 15,
      vendorName: 'Timber Creations',
      image: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop'
    }
  ]

  useEffect(() => {
    // Simulate loading and then show sample products
    const timer = setTimeout(() => {
      setFeaturedProducts(sampleProducts)
      setLoading(false)
      setApiError(true) // Show that we're using demo data
    }, 1000)

    return () => clearTimeout(timer)
  }, [])

  const categories = [
    { name: 'Jewelry', icon: '💍', count: '150+ items' },
    { name: 'Home Decor', icon: '🏠', count: '200+ items' },
    { name: 'Art & Prints', icon: '🎨', count: '100+ items' },
    { name: 'Clothing', icon: '👕', count: '120+ items' },
    { name: 'Pottery', icon: '🏺', count: '80+ items' },
    { name: 'Textiles', icon: '🧵', count: '90+ items' },
  ]

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Hero Section with 3D Carousel Background */}
      <section className="relative bg-gradient-to-br from-slate-900 via-slate-800 to-gray-900 min-h-screen flex items-center justify-center overflow-hidden">
        {/* 3D Carousel Background */}
        <ThreeDCarousel />
        
        {/* Content Overlay with Enhanced Visibility */}
        <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h1 className="text-4xl md:text-6xl font-bold text-white mb-6 drop-shadow-2xl">
            Discover Unique
            <span className="block text-transparent bg-clip-text bg-gradient-to-r from-amber-300 via-orange-300 to-red-400 drop-shadow-2xl">
              Handmade Treasures
            </span>
          </h1>
          <p className="text-xl text-gray-100 mb-8 max-w-3xl mx-auto drop-shadow-2xl font-medium">
            Connect with talented artisans from around the world. Find one-of-a-kind pieces 
            that tell a story and bring beauty to your life.
          </p>
          
          {/* Enhanced Attractive Buttons */}
          <div className="flex flex-col sm:flex-row gap-6 justify-center items-center">
            {/* Browse Products Button */}
            <Link 
              to="/products" 
              className="group relative overflow-hidden bg-gradient-to-r from-blue-600 via-indigo-600 to-purple-600 text-white font-bold text-lg px-10 py-4 rounded-2xl shadow-2xl hover:shadow-3xl transition-all duration-500 transform hover:scale-110 hover:-translate-y-1"
            >
              {/* Animated background */}
              <div className="absolute inset-0 bg-gradient-to-r from-blue-700 via-indigo-700 to-purple-700 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
              
              {/* Button content */}
              <div className="relative flex items-center justify-center space-x-3">
                <FiShoppingBag className="w-6 h-6 group-hover:rotate-12 transition-transform duration-300" />
                <span>Browse Products</span>
                <FiArrowRight className="w-5 h-5 group-hover:translate-x-2 transition-transform duration-300" />
              </div>
              
              {/* Glow effect */}
              <div className="absolute inset-0 rounded-2xl bg-gradient-to-r from-blue-500 via-indigo-500 to-purple-500 blur-xl opacity-0 group-hover:opacity-50 transition-opacity duration-500 -z-10"></div>
            </Link>

            {/* Meet Our Artisans Button */}
            <Link 
              to="/register" 
              className="group relative overflow-hidden bg-gradient-to-r from-emerald-600 via-teal-600 to-cyan-600 text-white font-bold text-lg px-10 py-4 rounded-2xl shadow-2xl hover:shadow-3xl transition-all duration-500 transform hover:scale-110 hover:-translate-y-1"
            >
              {/* Animated background */}
              <div className="absolute inset-0 bg-gradient-to-r from-emerald-700 via-teal-700 to-cyan-700 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
              
              {/* Button content */}
              <div className="relative flex items-center justify-center space-x-3">
                <FiUsers className="w-6 h-6 group-hover:rotate-12 transition-transform duration-300" />
                <span>Meet Our Artisans</span>
                <div className="w-5 h-5 group-hover:animate-bounce">
                  <FiArrowRight className="w-5 h-5" />
                </div>
              </div>
              
              {/* Glow effect */}
              <div className="absolute inset-0 rounded-2xl bg-gradient-to-r from-emerald-500 via-teal-500 to-cyan-500 blur-xl opacity-0 group-hover:opacity-50 transition-opacity duration-500 -z-10"></div>
            </Link>
          </div>
        </div>
        
        {/* Enhanced decorative elements */}
        <div className="absolute top-10 left-10 w-20 h-20 bg-blue-400/20 rounded-full animate-pulse"></div>
        <div className="absolute bottom-10 right-10 w-32 h-32 bg-purple-400/20 rounded-full animate-pulse"></div>
        <div className="absolute top-1/2 left-5 w-16 h-16 bg-gradient-to-r from-blue-400/30 to-purple-400/30 rounded-full animate-bounce"></div>
        <div className="absolute top-1/3 right-8 w-12 h-12 bg-gradient-to-r from-purple-400/30 to-blue-400/30 rounded-full animate-ping"></div>
      </section>

      {/* Categories Section */}
      <section className="py-20 bg-gradient-to-br from-white via-gray-50 to-slate-100 relative overflow-hidden">
        {/* Background decorative elements */}
        <div className="absolute inset-0">
          <div className="absolute top-10 left-10 w-32 h-32 bg-gradient-to-r from-blue-200/30 to-purple-200/30 rounded-full blur-3xl animate-pulse"></div>
          <div className="absolute bottom-10 right-10 w-40 h-40 bg-gradient-to-r from-emerald-200/30 to-teal-200/30 rounded-full blur-3xl animate-pulse"></div>
          <div className="absolute top-1/2 left-1/4 w-24 h-24 bg-gradient-to-r from-amber-200/30 to-orange-200/30 rounded-full blur-2xl animate-bounce"></div>
        </div>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-slate-800 via-slate-700 to-gray-800 mb-6">
              Explore by Category
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto leading-relaxed">
              Discover unique treasures organized by craft type. Each category holds a world of 
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-600 font-semibold"> handmade wonders</span> waiting for you.
            </p>
          </div>
          
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-6">
            {categories.map((category, index) => (
              <Link
                key={index}
                to={`/products?category=${category.name.toLowerCase()}`}
                className="group relative overflow-hidden bg-gradient-to-br from-white via-gray-50 to-slate-100 border border-gray-200/50 hover:border-transparent rounded-3xl p-6 hover:shadow-2xl hover:shadow-blue-100/50 transition-all duration-700 transform hover:scale-110 hover:-translate-y-3"
              >
                {/* Enhanced animated background gradient */}
                <div className="absolute inset-0 bg-gradient-to-br from-blue-500/10 via-purple-500/10 to-indigo-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-700"></div>
                
                {/* Category icon with enhanced effects */}
                <div className="relative text-center mb-4">
                  <div className="text-7xl mb-3 group-hover:scale-150 group-hover:rotate-12 transition-all duration-700 transform filter drop-shadow-lg">
                    {category.icon}
                  </div>
                  {/* Enhanced glow effect behind icon */}
                  <div className="absolute inset-0 bg-gradient-to-r from-blue-400/30 to-purple-400/30 rounded-full blur-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-700 -z-10 scale-200 group-hover:scale-300"></div>
                  {/* Secondary glow for depth */}
                  <div className="absolute inset-0 bg-gradient-to-r from-indigo-400/20 to-pink-400/20 rounded-full blur-xl opacity-0 group-hover:opacity-100 transition-opacity duration-1000 -z-20 scale-150 group-hover:scale-250"></div>
                </div>
                
                {/* Category content with enhanced typography */}
                <div className="relative text-center">
                  <h3 className="font-bold text-gray-900 mb-2 text-lg group-hover:text-transparent group-hover:bg-clip-text group-hover:bg-gradient-to-r group-hover:from-blue-600 group-hover:to-purple-600 transition-all duration-500 drop-shadow-sm">
                    {category.name}
                  </h3>
                  <p className="text-sm text-gray-600 font-medium group-hover:text-gray-700 transition-colors duration-500 group-hover:font-semibold">
                    {category.count}
                  </p>
                </div>

                {/* Enhanced hover border effect with gradient */}
                <div className="absolute inset-0 rounded-3xl border-2 border-transparent group-hover:border-gradient-to-r group-hover:from-blue-500 group-hover:via-purple-500 group-hover:to-indigo-500 transition-all duration-700 opacity-0 group-hover:opacity-100"></div>
                
                {/* Floating particles on hover with enhanced animation */}
                <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-700">
                  <div className="absolute top-3 left-3 w-3 h-3 bg-gradient-to-r from-blue-400 to-blue-500 rounded-full animate-ping shadow-lg"></div>
                  <div className="absolute top-6 right-4 w-2.5 h-2.5 bg-gradient-to-r from-purple-400 to-purple-500 rounded-full animate-ping shadow-lg" style={{ animationDelay: '0.3s' }}></div>
                  <div className="absolute bottom-4 left-5 w-2 h-2 bg-gradient-to-r from-indigo-400 to-indigo-500 rounded-full animate-ping shadow-lg" style={{ animationDelay: '0.6s' }}></div>
                  <div className="absolute bottom-6 right-2 w-1.5 h-1.5 bg-gradient-to-r from-pink-400 to-pink-500 rounded-full animate-ping shadow-lg" style={{ animationDelay: '0.9s' }}></div>
                </div>

                {/* Enhanced shine effect on hover */}
                <div className="absolute inset-0 rounded-3xl bg-gradient-to-r from-transparent via-white/40 to-transparent -translate-x-full group-hover:translate-x-full transition-transform duration-1000 ease-out"></div>
                
                {/* Subtle inner shadow for depth */}
                <div className="absolute inset-0 rounded-3xl shadow-inner opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                
                {/* Corner accent elements */}
                <div className="absolute top-0 left-0 w-0 h-0 border-l-[20px] border-l-transparent border-t-[20px] border-t-blue-500/20 opacity-0 group-hover:opacity-100 transition-all duration-500 transform -translate-x-2 -translate-y-2"></div>
                <div className="absolute bottom-0 right-0 w-0 h-0 border-r-[20px] border-r-transparent border-b-[20px] border-b-purple-500/20 opacity-0 group-hover:opacity-100 transition-all duration-500 transform translate-x-2 translate-y-2"></div>
                
                {/* Subtle background pattern */}
                <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-1000">
                  <div className="absolute top-2 right-2 w-8 h-8 border border-blue-300/30 rounded-full"></div>
                  <div className="absolute bottom-2 left-2 w-6 h-6 border border-purple-300/30 rounded-full"></div>
                </div>
              </Link>
            ))}
          </div>

          {/* Enhanced CTA below categories */}
          <div className="text-center mt-16">
            <div className="inline-flex items-center space-x-3 bg-gradient-to-r from-slate-100 via-gray-200 to-slate-200 px-8 py-4 rounded-full border border-gray-300/50 shadow-lg hover:shadow-xl transition-all duration-300 transform hover:scale-105">
              <span className="text-gray-700 font-medium">Can't find what you're looking for?</span>
              <Link 
                to="/products" 
                className="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 font-semibold hover:underline transition-all duration-200"
              >
                Browse All Categories
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Featured Products */}
      <section className="py-20 bg-gradient-to-br from-gray-50 via-gray-100 to-slate-100 relative overflow-hidden">
        {/* Background decorative elements */}
        <div className="absolute inset-0">
          <div className="absolute top-20 right-20 w-36 h-36 bg-gradient-to-r from-blue-200/20 to-indigo-200/20 rounded-full blur-3xl animate-pulse"></div>
          <div className="absolute bottom-20 left-20 w-44 h-44 bg-gradient-to-r from-emerald-200/20 to-teal-200/20 rounded-full blur-3xl animate-pulse"></div>
          <div className="absolute top-1/3 right-1/3 w-28 h-28 bg-gradient-to-r from-amber-200/20 to-orange-200/20 rounded-full blur-2xl animate-bounce"></div>
        </div>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-slate-800 via-slate-700 to-gray-800 mb-6">
              Featured Products
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto leading-relaxed">
              Handpicked treasures from our most talented artisans. Each piece tells a unique story of 
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-600 font-semibold"> craftsmanship and creativity</span>.
            </p>
            {apiError && (
              <div className="mt-6 p-4 bg-gradient-to-r from-amber-50 to-orange-50 border border-amber-200 rounded-2xl shadow-lg">
                <p className="text-amber-800 text-sm font-medium">
                  ⚠️ Showing demo products (Backend API not available)
                </p>
              </div>
            )}
          </div>

          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
              {[...Array(4)].map((_, index) => (
                <div key={index} className="bg-white rounded-2xl p-6 animate-pulse shadow-lg">
                  <div className="bg-gradient-to-br from-gray-200 to-gray-300 h-56 rounded-xl mb-4"></div>
                  <div className="bg-gradient-to-r from-gray-200 to-gray-300 h-4 rounded mb-3"></div>
                  <div className="bg-gradient-to-r from-gray-200 to-gray-300 h-4 rounded w-2/3 mb-4"></div>
                  <div className="bg-gradient-to-r from-gray-200 to-gray-300 h-8 rounded-lg"></div>
                </div>
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
              {featuredProducts.map((product, index) => (
                <div key={product._id} className="group relative bg-white rounded-2xl shadow-lg border border-gray-200/50 overflow-hidden hover:shadow-2xl hover:shadow-blue-100/50 transition-all duration-700 transform hover:scale-105 hover:-translate-y-2">
                  {/* Product Image Container */}
                  <div className="relative overflow-hidden">
                    <img
                      src={product.image}
                      alt={product.name}
                      className="w-full h-56 object-cover group-hover:scale-110 transition-transform duration-700"
                      onError={(e) => {
                        e.target.src = 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=300&fit=crop'
                      }}
                    />
                    
                    {/* Image overlay gradient */}
                    <div className="absolute inset-0 bg-gradient-to-t from-black/20 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
                    
                    {/* Heart button with enhanced design */}
                    <button 
                      onClick={(e) => {
                        e.preventDefault()
                        e.stopPropagation()
                        if (isInFavorites(product._id)) {
                          removeFromFavorites(product._id)
                          toast.success('Removed from favorites')
                        } else {
                          addToFavorites(product)
                          toast.success('Added to favorites!')
                        }
                      }}
                      className={`absolute top-4 right-4 p-3 backdrop-blur-sm rounded-full shadow-lg hover:shadow-xl transition-all duration-300 transform hover:scale-110 ${
                        isInFavorites(product._id) 
                          ? 'bg-red-500/90 hover:bg-red-600/90' 
                          : 'bg-white/90 hover:bg-white'
                      }`}
                    >
                      <FiHeart className={`w-5 h-5 transition-colors duration-300 ${
                        isInFavorites(product._id) 
                          ? 'text-white fill-current' 
                          : 'text-gray-600 group-hover:text-red-500'
                      }`} />
                    </button>
                    
                    {/* Category badge */}
                    <div className="absolute bottom-4 left-4 px-3 py-1 bg-gradient-to-r from-blue-500/90 to-purple-500/90 backdrop-blur-sm text-white text-xs font-semibold rounded-full shadow-lg">
                      Featured
                    </div>
                  </div>
                  
                  {/* Product Content */}
                  <div className="p-6 bg-gradient-to-br from-white to-gray-50">
                    {/* Rating Section */}
                    <div className="flex items-center mb-4">
                      <div className="flex text-amber-400">
                        {[...Array(5)].map((_, i) => (
                          <FiStar
                            key={i}
                            className={`w-4 h-4 ${i < (product.rating || 0) ? 'fill-current' : ''}`}
                          />
                        ))}
                      </div>
                      <span className="text-sm text-gray-500 ml-2 font-medium">
                        ({product.reviewCount || 0})
                      </span>
                      <div className="ml-auto">
                        <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                          ★ Top Rated
                        </span>
                      </div>
                    </div>
                    
                    {/* Product Title */}
                    <h3 className="font-bold text-gray-900 mb-3 text-lg leading-tight group-hover:text-transparent group-hover:bg-clip-text group-hover:bg-gradient-to-r group-hover:from-blue-600 group-hover:to-purple-600 transition-all duration-500 line-clamp-2">
                      {product.name}
                    </h3>
                    
                    {/* Vendor and Price Section */}
                    <div className="flex items-center justify-between mb-4">
                      <div className="flex items-center space-x-2">
                        <div className="w-6 h-6 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full flex items-center justify-center">
                          <span className="text-white text-xs font-bold">A</span>
                        </div>
                        <span className="text-sm text-gray-600 font-medium group-hover:text-gray-800 transition-colors duration-300">
                          by {product.vendorName}
                        </span>
                      </div>
                      <span className="text-xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-600 group-hover:from-blue-700 group-hover:to-purple-700 transition-all duration-300">
                        ${product.price}
                      </span>
                    </div>
                    
                    {/* Action Buttons */}
                    <div className="flex space-x-2">
                      <Link
                        to={`/products/${product._id}`}
                        className="flex-1 text-center bg-gradient-to-r from-blue-600 via-indigo-600 to-purple-600 hover:from-blue-700 hover:via-indigo-700 hover:to-purple-700 text-white font-semibold py-3 px-4 rounded-xl transition-all duration-300 transform hover:scale-105 shadow-lg hover:shadow-xl group-hover:shadow-2xl"
                      >
                        <span className="flex items-center justify-center space-x-2">
                          <span>View Details</span>
                          <FiArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform duration-300" />
                        </span>
                      </Link>
                      
                      <button
                        onClick={(e) => {
                          e.preventDefault()
                          e.stopPropagation()
                          addToCart(product)
                          toast.success('Added to cart!')
                        }}
                        className="flex items-center justify-center w-12 h-10 bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700 text-white rounded-xl transition-all duration-300 transform hover:scale-105 shadow-lg hover:shadow-xl"
                      >
                        <FiShoppingBag className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                  
                  {/* Hover border effect */}
                  <div className="absolute inset-0 rounded-2xl border-2 border-transparent group-hover:border-gradient-to-r group-hover:from-blue-500 group-hover:via-purple-500 group-hover:to-indigo-500 transition-all duration-700 opacity-0 group-hover:opacity-100"></div>
                  
                  {/* Floating particles on hover */}
                  <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-700">
                    <div className="absolute top-6 left-6 w-2 h-2 bg-blue-400 rounded-full animate-ping"></div>
                    <div className="absolute top-8 right-6 w-1.5 h-1.5 bg-purple-400 rounded-full animate-ping" style={{ animationDelay: '0.3s' }}></div>
                    <div className="absolute bottom-6 left-8 w-1 h-1 bg-indigo-400 rounded-full animate-ping" style={{ animationDelay: '0.6s' }}></div>
                  </div>
                  
                  {/* Shine effect on hover */}
                  <div className="absolute inset-0 rounded-2xl bg-gradient-to-r from-transparent via-white/30 to-transparent -translate-x-full group-hover:translate-x-full transition-transform duration-1000 ease-out"></div>
                </div>
              ))}
            </div>
          )}
          
          {/* Enhanced CTA Section */}
          <div className="text-center mt-16">
            <div className="inline-flex items-center space-x-4">
              <Link 
                to="/products" 
                className="inline-flex items-center bg-gradient-to-r from-slate-700 via-slate-800 to-gray-900 hover:from-slate-800 hover:via-slate-900 hover:to-gray-800 text-white font-semibold px-8 py-4 rounded-2xl transition-all duration-300 transform hover:scale-105 shadow-xl hover:shadow-2xl group"
              >
                <span className="flex items-center space-x-2">
                  <FiShoppingBag className="w-5 h-5 group-hover:rotate-12 transition-transform duration-300" />
                  <span>View All Products</span>
                  <FiArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform duration-300" />
                </span>
              </Link>
              
              <div className="text-gray-500 font-medium">
                or
              </div>
              
              <Link 
                to="/vendors" 
                className="inline-flex items-center bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-700 hover:to-teal-700 text-white font-semibold px-8 py-4 rounded-2xl transition-all duration-300 transform hover:scale-105 shadow-xl hover:shadow-2xl group"
              >
                <span className="flex items-center space-x-2">
                  <FiUsers className="w-5 h-5 group-hover:rotate-12 transition-transform duration-300" />
                  <span>Meet Our Artisans</span>
                  <FiArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform duration-300" />
                </span>
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 bg-gradient-to-r from-slate-800 via-slate-900 to-gray-900 text-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl font-bold mb-4">
            Ready to Start Selling?
          </h2>
          <p className="text-xl mb-8 text-gray-300">
            Join our community of artisans and share your unique creations with the world
          </p>
          <Link to="/register" className="inline-flex items-center bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600 text-white font-semibold px-8 py-3 rounded-lg transition-all duration-200 transform hover:scale-105 shadow-lg hover:shadow-xl">
            Become a Vendor
            <FiArrowRight className="ml-2 w-5 h-5" />
          </Link>
        </div>
      </section>
    </div>
  )
}

export default Home
