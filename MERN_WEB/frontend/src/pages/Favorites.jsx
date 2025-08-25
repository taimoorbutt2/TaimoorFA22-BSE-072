import React, { useState, useEffect } from 'react'
import { useCart } from '../contexts/CartContext'
import { Link } from 'react-router-dom'
import { 
  FiHeart, 
  FiShoppingCart, 
  FiTrash2, 
  FiEye, 
  FiPackage,
  FiStar,
  FiShare2,
  FiArrowRight
} from 'react-icons/fi'
import toast from 'react-hot-toast'

const Favorites = () => {
  const { addItem: addToCart } = useCart()
  const [favorites, setFavorites] = useState([])
  const [loading, setLoading] = useState(false)

  // Mock favorites data - will be replaced with real API calls
  const mockFavorites = [
    {
      id: 1,
      name: 'Handmade Ceramic Vase',
      description: 'Beautiful handcrafted ceramic vase with unique patterns',
      price: 89.99,
      category: 'Home Decor',
      image: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=400&fit=crop',
      vendorName: 'Sarah Chen Artistry',
      rating: 4.8,
      reviews: 24,
      inStock: true,
      addedToFavorites: '2024-01-15'
    },
    {
      id: 2,
      name: 'Artisan Leather Wallet',
      description: 'Premium leather wallet hand-stitched with care',
      price: 45.00,
      category: 'Accessories',
      image: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop',
      vendorName: 'Marcus Leatherworks',
      rating: 4.9,
      reviews: 18,
      inStock: true,
      addedToFavorites: '2024-01-14'
    },
    {
      id: 3,
      name: 'Handcrafted Wooden Bowl',
      description: 'Unique wooden bowl carved from sustainable oak',
      price: 65.50,
      category: 'Home Decor',
      image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=400&fit=crop',
      vendorName: 'David Kim Woodcraft',
      rating: 4.7,
      reviews: 31,
      inStock: false,
      addedToFavorites: '2024-01-13'
    }
  ]

  useEffect(() => {
    // Load favorites (mock data for now)
    setFavorites(mockFavorites)
  }, [])

  const handleAddToCart = (product) => {
    if (!product.inStock) {
      toast.error('This product is currently out of stock')
      return
    }

    const cartItem = {
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      category: product.category,
      image: product.image,
      vendorName: product.vendorName,
      vendorId: `vendor-${product.id}`,
      quantity: 1
    }

    addToCart(cartItem)
    toast.success(`${product.name} added to cart!`)
  }

  const handleRemoveFromFavorites = (productId) => {
    if (window.confirm('Remove this item from your favorites?')) {
      setFavorites(favorites.filter(item => item.id !== productId))
      toast.success('Item removed from favorites')
    }
  }

  const handleShareProduct = (product) => {
    if (navigator.share) {
      navigator.share({
        title: product.name,
        text: `Check out this amazing ${product.category} by ${product.vendorName}!`,
        url: window.location.href
      })
    } else {
      // Fallback: copy to clipboard
      navigator.clipboard.writeText(`${product.name} - ${product.vendorName}`)
      toast.success('Product link copied to clipboard!')
    }
  }

  const getCategoryColor = (category) => {
    const colors = {
      'Jewelry': 'bg-purple-100 text-purple-800',
      'Home Decor': 'bg-blue-100 text-blue-800',
      'Accessories': 'bg-green-100 text-green-800',
      'Art': 'bg-red-100 text-red-800',
      'Clothing': 'bg-yellow-100 text-yellow-800',
      'Beauty': 'bg-pink-100 text-pink-800',
      'Kitchen': 'bg-orange-100 text-orange-800',
      'Garden': 'bg-emerald-100 text-emerald-800'
    }
    return colors[category] || 'bg-gray-100 text-gray-800'
  }

  if (favorites.length === 0) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div className="max-w-md w-full text-center">
          <div className="mx-auto h-24 w-24 bg-gray-200 rounded-full flex items-center justify-center mb-6">
            <FiHeart className="w-12 h-12 text-gray-400" />
          </div>
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Your favorites list is empty</h2>
          <p className="text-gray-600 mb-8">Start adding products you love to your wishlist!</p>
          <div className="space-y-3">
            <Link
              to="/products"
              className="w-full bg-gradient-to-r from-primary-600 to-artisan-600 text-white px-6 py-3 rounded-lg hover:from-primary-700 hover:to-artisan-700 transition-all duration-200 inline-block"
            >
              Browse Products
            </Link>
            <Link
              to="/"
              className="w-full border border-gray-300 text-gray-700 px-6 py-3 rounded-lg hover:bg-gray-50 transition-colors duration-200 inline-block"
            >
              Go Home
            </Link>
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
              <h1 className="text-3xl font-bold text-gray-900">My Favorites</h1>
              <p className="text-gray-600 mt-2">You have {favorites.length} item{favorites.length !== 1 ? 's' : ''} in your wishlist</p>
            </div>
            <Link
              to="/products"
              className="bg-gradient-to-r from-primary-600 to-artisan-600 text-white px-6 py-3 rounded-lg hover:from-primary-700 hover:to-artisan-700 transition-all duration-200 flex items-center space-x-2"
            >
              <FiPackage className="w-4 h-4" />
              <span>Browse More</span>
            </Link>
          </div>
        </div>

        {/* Favorites Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {favorites.map((product) => (
            <div key={product.id} className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden hover:shadow-md transition-shadow duration-200 group">
              {/* Product Image */}
              <div className="relative">
                <img
                  src={product.image}
                  alt={product.name}
                  className="w-full h-48 object-cover group-hover:scale-105 transition-transform duration-300"
                />
                
                {/* Stock Status Badge */}
                {!product.inStock && (
                  <div className="absolute top-3 left-3 bg-red-500 text-white px-2 py-1 rounded-full text-xs font-medium">
                    Out of Stock
                  </div>
                )}

                {/* Quick Actions */}
                <div className="absolute top-3 right-3 flex flex-col space-y-2 opacity-0 group-hover:opacity-100 transition-opacity duration-200">
                  <button
                    onClick={() => handleShareProduct(product)}
                    className="w-8 h-8 bg-white rounded-full shadow-lg flex items-center justify-center hover:bg-gray-50 transition-colors duration-200"
                  >
                    <FiShare2 className="w-4 h-4 text-gray-600" />
                  </button>
                  <button
                    onClick={() => handleRemoveFromFavorites(product.id)}
                    className="w-8 h-8 bg-white rounded-full shadow-lg flex items-center justify-center hover:bg-red-50 transition-colors duration-200"
                  >
                    <FiTrash2 className="w-4 h-4 text-red-600" />
                  </button>
                </div>

                {/* Category Badge */}
                <div className="absolute bottom-3 left-3">
                  <span className={`px-3 py-1 rounded-full text-xs font-medium ${getCategoryColor(product.category)}`}>
                    {product.category}
                  </span>
                </div>
              </div>

              {/* Product Info */}
              <div className="p-4">
                <div className="flex items-start justify-between mb-2">
                  <h3 className="text-lg font-semibold text-gray-900 line-clamp-2">{product.name}</h3>
                  <div className="text-right">
                    <p className="text-xl font-bold text-primary-600">${product.price}</p>
                  </div>
                </div>

                <p className="text-sm text-gray-600 mb-3 line-clamp-2">{product.description}</p>

                {/* Vendor & Rating */}
                <div className="flex items-center justify-between mb-4">
                  <div className="flex items-center space-x-2">
                    <FiPackage className="w-4 h-4 text-gray-400" />
                    <span className="text-sm text-gray-600">{product.vendorName}</span>
                  </div>
                  <div className="flex items-center space-x-1">
                    <FiStar className="w-4 h-4 text-yellow-400 fill-current" />
                    <span className="text-sm font-medium text-gray-900">{product.rating}</span>
                    <span className="text-xs text-gray-500">({product.reviews})</span>
                  </div>
                </div>

                {/* Added Date */}
                <div className="text-xs text-gray-500 mb-4">
                  Added on {new Date(product.addedToFavorites).toLocaleDateString()}
                </div>

                {/* Action Buttons */}
                <div className="flex space-x-2">
                  <button
                    onClick={() => handleAddToCart(product)}
                    disabled={!product.inStock}
                    className={`flex-1 flex items-center justify-center space-x-2 py-2 px-4 rounded-lg font-medium transition-all duration-200 ${
                      product.inStock
                        ? 'bg-gradient-to-r from-primary-600 to-artisan-600 text-white hover:from-primary-700 hover:to-artisan-700'
                        : 'bg-gray-200 text-gray-500 cursor-not-allowed'
                    }`}
                  >
                    <FiShoppingCart className="w-4 h-4" />
                    <span>{product.inStock ? 'Add to Cart' : 'Out of Stock'}</span>
                  </button>
                  
                  <Link
                    to={`/product/${product.id}`}
                    className="flex items-center justify-center w-12 h-10 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors duration-200"
                  >
                    <FiEye className="w-4 h-4 text-gray-600" />
                  </Link>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Bottom CTA */}
        <div className="mt-12 text-center">
          <div className="bg-gradient-to-r from-primary-50 to-artisan-50 rounded-2xl p-8 border border-primary-100">
            <h3 className="text-2xl font-bold text-gray-900 mb-4">Discover More Amazing Products</h3>
            <p className="text-gray-600 mb-6 max-w-2xl mx-auto">
              Explore our curated collection of handmade treasures from talented artisans around the world.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link
                to="/products"
                className="bg-gradient-to-r from-primary-600 to-artisan-600 text-white px-8 py-3 rounded-lg hover:from-primary-700 hover:to-artisan-700 transition-all duration-200 font-medium flex items-center justify-center space-x-2"
              >
                <span>Browse All Products</span>
                <FiArrowRight className="w-4 h-4" />
              </Link>
              <Link
                to="/artisans"
                className="border border-primary-600 text-primary-600 px-8 py-3 rounded-lg hover:bg-primary-50 transition-colors duration-200 font-medium flex items-center justify-center space-x-2"
              >
                <span>Meet Our Artisans</span>
                <FiArrowRight className="w-4 h-4" />
              </Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Favorites
