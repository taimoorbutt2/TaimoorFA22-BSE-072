import React, { useState, useEffect } from 'react'
import { useParams, Link, useNavigate } from 'react-router-dom'
import { FiStar, FiHeart, FiShoppingCart, FiTruck, FiPackage, FiShield, FiUser, FiMapPin, FiClock, FiMessageCircle, FiArrowLeft, FiShare2, FiCheck, FiX } from 'react-icons/fi'
import { FaStar, FaHeart, FaRegHeart } from 'react-icons/fa'
import { toast } from 'react-hot-toast'
import ReviewForm from '../components/ReviewForm'
import ReviewList from '../components/ReviewList'
import { useFavorites } from '../contexts/FavoritesContext'
import { useCart } from '../contexts/CartContext'

const ProductDetail = () => {
  // Add custom styles for animations
  useEffect(() => {
    const style = document.createElement('style')
    style.textContent = `
      @keyframes fade-in {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
      }
      
      @keyframes float {
        0%, 100% { transform: translateY(0px); }
        50% { transform: translateY(-10px); }
      }
      
      .animate-fade-in {
        animation: fade-in 0.8s ease-out;
      }
      
      .animate-float {
        animation: float 3s ease-in-out infinite;
      }
    `
    document.head.appendChild(style)
    
    return () => {
      document.head.removeChild(style)
    }
  }, [])
  const { id } = useParams()
  const navigate = useNavigate()
  const [product, setProduct] = useState(null)
  const [loading, setLoading] = useState(true)
  const [selectedImage, setSelectedImage] = useState(0)
  const { favorites, toggleFavorite } = useFavorites()
  const { addItem, isInCart, getItemQuantity } = useCart()
  const [quantity, setQuantity] = useState(1)
  const [activeTab, setActiveTab] = useState('description')
  
  // Check if product is in favorites
  const isProductFavorited = () => {
    return favorites.some(fav => fav.product._id === product?._id)
  }
  const [vendorProfile, setVendorProfile] = useState(null)
  const [contactLoading, setContactLoading] = useState(false)
  const [userReview, setUserReview] = useState(null)
  const [reviewsKey, setReviewsKey] = useState(0)
  
  console.log('ProductDetail component rendering with id:', id)

  useEffect(() => {
    console.log('ProductDetail useEffect triggered with id:', id)
    if (id) {
      // First check if backend is accessible
      checkBackendStatus()
      fetchProductDetails()
      checkUserReview()
    } else {
      console.error('No product ID provided')
    }
  }, [id])

  const checkBackendStatus = async () => {
    try {
      const response = await fetch('/api/products?limit=1')
      console.log('Backend status check - Response status:', response.status)
    } catch (error) {
      console.error('Backend status check failed:', error)
    }
  }

  const checkUserReview = async () => {
    try {
      const token = localStorage.getItem('token')
      if (!token) return

      const response = await fetch(`/api/reviews/product/${id}`)
      if (response.ok) {
        const data = await response.json()
        // Find if current user has reviewed this product
        const decodedToken = JSON.parse(atob(token.split('.')[1]))
        const currentUserReview = data.reviews.find(review => 
          review.user === decodedToken.id
        )
        if (currentUserReview) {
          setUserReview(currentUserReview)
        }
      }
    } catch (error) {
      console.error('Error checking user review:', error)
    }
  }

  const fetchProductDetails = async () => {
    try {
      setLoading(true)
      console.log('Fetching product details for ID:', id)
      
      // Check if this is a sample product
      if (id && id.startsWith('sample')) {
        console.log('Sample product detected, showing sample data')
        // Show sample product data
        const sampleProduct = {
          _id: id,
          name: id === 'sample1' ? 'Handcrafted Silver Filigree Necklace' : 'Ceramic Vase Collection - Earth Tones',
          price: id === 'sample1' ? 89.99 : 45.50,
          originalPrice: id === 'sample1' ? 129.99 : 65.00,
          rating: id === 'sample1' ? 4.8 : 4.6,
          reviewCount: id === 'sample1' ? 127 : 89,
          vendorName: id === 'sample1' ? 'SilverCraft Studio' : 'Earth & Fire Pottery',
          category: id === 'sample1' ? 'Jewelry' : 'Home Decor',
          images: [id === 'sample1' ? 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=500&h=500&fit=crop' : 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=500&h=500&fit=crop'],
          description: id === 'sample1' ? 'Exquisite handcrafted silver necklace with intricate filigree work. Each piece is uniquely designed and crafted with attention to detail.' : 'Beautiful hand-thrown ceramic vases in warm earth tones. Perfect for adding natural elegance to any room.',
          tags: id === 'sample1' ? ['handmade', 'silver', 'filigree', 'necklace', 'artisan'] : ['ceramic', 'handmade', 'vase', 'earth tones', 'pottery'],
          stock: 10,
          inStock: true,
          featured: id === 'sample1',
          vendor: 'sample-vendor',
          dimensions: { length: 10, width: 5, height: 3, unit: 'cm' },
          weight: { value: 500, unit: 'g' },
          materials: ['silver', 'precious stones'],
          careInstructions: 'Store in a cool, dry place. Clean with a soft cloth.'
        }
                        // Ensure inStock is calculated for sample products
                const sampleProductWithInStock = {
                  ...sampleProduct,
                  inStock: sampleProduct.inStock !== undefined ? sampleProduct.inStock : parseInt(sampleProduct.stock) > 0
                }
                console.log('Sample product with calculated inStock:', sampleProductWithInStock)
                setProduct(sampleProductWithInStock)
        setLoading(false)
        return
      }
      
      // Only try to fetch from API if it's not a sample product
      if (id && !id.startsWith('sample')) {
        try {
          console.log('Making API request to:', `/api/products/${id}`)
          const response = await fetch(`/api/products/${id}`)
          console.log('Response status:', response.status)
          
          if (response.ok) {
            const data = await response.json()
            console.log('Product data received:', data)
            console.log('Product stock info:', {
              stock: data.product.stock,
              stockType: typeof data.product.stock,
              inStock: data.product.inStock,
              inStockType: typeof data.product.inStock
            })
            console.log('Product rating data:', {
              rating: data.product.rating,
              reviewCount: data.product.reviewCount,
              ratingType: typeof data.product.rating
            })
            // Ensure inStock is calculated if not provided by API
            const productWithInStock = {
              ...data.product,
              inStock: data.product.inStock !== undefined ? data.product.inStock : parseInt(data.product.stock) > 0
            }
            console.log('Product with calculated inStock:', productWithInStock)
            setProduct(productWithInStock)
            
            // Fetch vendor profile if available
            if (data.product.vendor) {
              try {
                // Handle case where vendor might be an object or string
                const vendorId = typeof data.product.vendor === 'object' ? data.product.vendor._id : data.product.vendor
                console.log('Fetching vendor profile for vendorId:', vendorId)
                
                if (vendorId) {
                  const vendorResponse = await fetch(`/api/vendors/profile/${vendorId}`)
                  if (vendorResponse.ok) {
                    const vendorData = await vendorResponse.json()
                    setVendorProfile(vendorData.profile)
                  }
                }
              } catch (error) {
                console.error('Error fetching vendor profile:', error)
              }
            }
          } else {
            const errorData = await response.json().catch(() => ({}))
            console.error('Failed to fetch product. Status:', response.status, 'Error:', errorData)
            
            if (response.status === 404) {
              // Product not found - show error message
              setProduct(null)
            } else {
              // Other error - redirect to products page
              navigate('/products')
            }
          }
        } catch (fetchError) {
          console.error('Network error fetching product:', fetchError)
          
          // If it's a network error, show a helpful message
          if (fetchError.name === 'TypeError' && fetchError.message.includes('fetch')) {
            console.log('Network error detected, showing error message')
            setProduct(null)
          } else {
            // Other error - redirect to products page
            navigate('/products')
          }
        }
      }
    } catch (error) {
      console.error('Error fetching product:', error)
      navigate('/products')
    } finally {
      setLoading(false)
    }
  }

  const handleQuantityChange = (newQuantity) => {
    if (newQuantity >= 1 && newQuantity <= (product?.stock || 1)) {
      setQuantity(newQuantity)
    }
  }

  const handleReviewSubmitted = async () => {
    setReviewsKey(prev => prev + 1)
    checkUserReview()
    
    // Also refresh the product data to get updated rating and reviewCount
    if (product && !product._id.startsWith('sample')) {
      try {
        console.log('Refreshing product data after review submission')
        const response = await fetch(`/api/products/${product._id}`)
        if (response.ok) {
          const data = await response.json()
          console.log('Updated product data:', data.product)
          setProduct(data.product)
        }
      } catch (error) {
        console.error('Error refreshing product data:', error)
      }
    }
  }



  const addToCart = () => {
    if (!product) return
    
    const cartItem = {
      _id: product._id,
      name: product.name,
      price: product.price,
      category: product.category,
      image: product.images?.[0] || product.image,
      vendorName: product.vendorName || 'Unknown Vendor',
      vendorId: product.vendor?._id || product.vendor,
      description: product.description
    }
    
    addItem(cartItem)
    toast.success(`${product.name} added to cart!`, {
      duration: 3000,
      icon: '🛒',
      style: {
        background: '#10B981',
        color: '#fff',
        borderRadius: '12px',
        padding: '16px',
        fontSize: '14px'
      }
    })
  }

  const contactVendor = async () => {
    try {
      // Show confirmation dialog
      const confirmMessage = `Send inquiry about "${product.name}" to vendor?\n\nThis will send a detailed message including:\n• Product details\n• Price information\n• Direct link to this product\n\nThe vendor will receive this in their chat inbox.`
      
      if (!window.confirm(confirmMessage)) {
        return
      }
      
      setContactLoading(true)
      
      if (!product?.vendor) {
        toast.error('Vendor information not available')
        return
      }

      // Handle case where vendor might be an object or string
      const vendorId = typeof product.vendor === 'object' ? product.vendor._id : product.vendor
      if (!vendorId) {
        toast.error('Vendor ID not available')
        return
      }

      // Create a product inquiry message
      const messageData = {
        recipientId: vendorId,
        message: `Hi! I'm interested in your product "${product.name}" (${product.category}). 

📦 **Product Details:**
• **Name:** ${product.name}
• **Price:** $${product.price}
• **Category:** ${product.category}
• **Stock:** ${product.stock} units available

🔍 **Questions:**
Could you please provide more information about:
• Materials used
• Shipping options and costs
• Customization possibilities
• Production time
• Any bulk discounts

🔗 **Product Link:** ${window.location.href}

Looking forward to hearing from you! 😊`,
        productId: product._id,
        productName: product.name,
        productCategory: product.category,
        productPrice: product.price
      }

      // Send the message using the chat API
      const response = await fetch('/api/chat/send', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify(messageData)
      })

      if (response.ok) {
        const result = await response.json()
        toast.success(
          `Message sent to vendor successfully! 💬\n\nProduct: ${product.name}\nCategory: ${product.category}\nPrice: $${product.price}\n\nCheck your dashboard for vendor responses!`,
          { duration: 4000 }
        )
        console.log('Message sent:', result)
        
        // Show additional success info with chat inbox link
        setTimeout(() => {
          toast.success(
            'Message sent successfully! 💬 Check your dashboard to continue the conversation.',
            { 
              duration: 5000,
              action: {
                text: 'Go to Dashboard',
                onClick: () => navigate('/dashboard')
              }
            }
          )
        }, 1000)
      } else {
        const errorData = await response.json()
        console.error('Failed to send message:', errorData)
        toast.error('Failed to send message. Please try again.')
      }
    } catch (error) {
      console.error('Error contacting vendor:', error)
      toast.error('Failed to send message. Please try again.')
    } finally {
      setContactLoading(false)
    }
  }

  const renderStars = (rating) => {
    return Array.from({ length: 5 }, (_, i) => (
      <FaStar
        key={i}
        className={`w-5 h-5 ${
          i < Math.floor(rating)
            ? 'text-yellow-400 fill-current'
            : i < rating
            ? 'text-yellow-400 fill-current opacity-60'
            : 'text-gray-300'
        }`}
      />
    ))
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-50 via-gray-100 to-slate-100 py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="animate-pulse">
            {/* Back button skeleton */}
            <div className="h-8 bg-gray-300 rounded w-32 mb-8"></div>
            
            {/* Main content skeleton */}
            <div className="grid lg:grid-cols-2 gap-12">
              {/* Left column - Images */}
              <div className="space-y-6">
                <div className="bg-gray-300 h-96 lg:h-[500px] rounded-2xl"></div>
                <div className="grid grid-cols-5 gap-3">
                  {[...Array(5)].map((_, i) => (
                    <div key={i} className="bg-gray-300 h-20 rounded-lg"></div>
                  ))}
                </div>
              </div>
              
              {/* Right column - Product info */}
              <div className="space-y-8">
                <div className="space-y-4">
                  <div className="h-8 bg-gray-300 rounded w-3/4"></div>
                  <div className="h-6 bg-gray-300 rounded w-1/2"></div>
                  <div className="h-12 bg-gray-300 rounded w-1/3"></div>
                  <div className="h-4 bg-gray-300 rounded w-full"></div>
                  <div className="h-4 bg-gray-300 rounded w-2/3"></div>
                </div>
                
                <div className="space-y-4">
                  <div className="h-12 bg-gray-300 rounded-lg w-full"></div>
                  <div className="h-12 bg-gray-300 rounded-lg w-full"></div>
                </div>
                
                <div className="grid grid-cols-2 gap-4">
                  <div className="bg-gray-300 h-20 rounded-xl"></div>
                  <div className="bg-gray-300 h-20 rounded-xl"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }

  if (!product) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-50 via-gray-100 to-slate-100 py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <div className="text-6xl mb-4">❌</div>
          <h3 className="text-2xl font-bold text-gray-900 mb-4">Product Not Found</h3>
          <p className="text-gray-600 mb-6">
            The product with ID <code className="bg-gray-200 px-2 py-1 rounded">{id}</code> doesn't exist or has been removed.
          </p>
          <div className="space-y-4">
            <Link
              to="/products"
              className="inline-block bg-gradient-to-r from-blue-600 to-purple-600 text-white px-6 py-3 rounded-lg font-semibold hover:from-blue-700 hover:to-purple-700 transition-all duration-200"
            >
              Browse All Products
            </Link>
            <div className="text-sm text-gray-500">
              <p>This could happen if:</p>
              <ul className="mt-2 space-y-1">
                <li>• The product was deleted by the vendor</li>
                <li>• The product ID is incorrect</li>
                <li>• There's a database connection issue</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    )
  }

  const images = product.images && product.images.length > 0 ? product.images : [
    'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=500&h=500&fit=crop'
  ]

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 via-gray-100 to-slate-100 py-20 animate-fade-in">
      {/* Background decorative elements */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-20 right-20 w-36 h-36 bg-gradient-to-r from-blue-200/20 to-indigo-200/20 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute bottom-20 left-20 w-44 h-44 bg-gradient-to-r from-emerald-200/20 to-teal-200/20 rounded-full blur-3xl animate-pulse"></div>
        
        {/* Floating particles */}
        <div className="absolute top-32 left-1/3 w-2 h-2 bg-blue-400/40 rounded-full animate-bounce" style={{animationDelay: '0.5s'}}></div>
        <div className="absolute top-48 right-1/3 w-1.5 h-1.5 bg-purple-400/40 rounded-full animate-bounce" style={{animationDelay: '1.5s'}}></div>
        <div className="absolute bottom-32 left-1/2 w-1 h-1 bg-emerald-400/40 rounded-full animate-bounce" style={{animationDelay: '2.5s'}}></div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        {/* Back Button */}
        <div className="mb-8">
          <button
            onClick={() => navigate('/products')}
            className="group flex items-center space-x-3 bg-gradient-to-r from-gray-100 to-blue-50 hover:from-blue-100 hover:to-indigo-50 text-gray-700 hover:text-blue-700 transition-all duration-300 px-4 py-3 rounded-xl border border-gray-200 hover:border-blue-300 hover:shadow-lg transform hover:-translate-x-1"
          >
            <FiArrowLeft className="w-5 h-5 group-hover:animate-pulse" />
            <span className="font-medium">Back to Products</span>
            <span className="text-blue-400 opacity-0 group-hover:opacity-100 transition-opacity duration-300">←</span>
          </button>
        </div>

        {/* Sample Product Notice */}
        {product?._id?.startsWith('sample') && (
          <div className="bg-gradient-to-r from-amber-50 via-orange-50 to-yellow-50 border border-amber-200 rounded-2xl p-6 mb-8 max-w-2xl shadow-lg hover:shadow-xl transition-all duration-300 transform hover:scale-[1.02]">
            <div className="flex items-center space-x-3 text-amber-800 mb-3">
              <span className="text-2xl">📝</span>
              <span className="font-bold text-lg">Demo Product</span>
            </div>
            <p className="text-amber-700 text-base leading-relaxed">
              This is a sample product to demonstrate the marketplace. 
              <Link to="/register" className="text-amber-800 font-bold hover:text-amber-900 hover:underline ml-1 transition-colors duration-200">
                Become a vendor
              </Link> to add real products!
            </p>
            <div className="mt-3 flex items-center space-x-2 text-amber-600 text-sm">
              <span>✨</span>
              <span>Experience the full features</span>
            </div>
          </div>
        )}

        <div className="grid lg:grid-cols-2 gap-12 animate-fade-in">
          {/* Left Column - Product Images */}
          <div className="space-y-6 transform transition-all duration-700 hover:scale-[1.02]">
            {/* Main Image */}
            <div className="relative group">
              <img
                src={images[selectedImage]}
                alt={product.name}
                className="w-full h-96 lg:h-[500px] object-cover rounded-2xl shadow-lg group-hover:shadow-2xl transition-all duration-500"
                onError={(e) => {
                  e.target.src = 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=500&h=500&fit=crop'
                }}
              />
              
              {/* Subtle glow effect on hover */}
              <div className="absolute inset-0 rounded-2xl bg-gradient-to-r from-blue-500/5 via-purple-500/5 to-indigo-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none"></div>
              
              {/* Category Badge */}
              <div className="absolute top-4 left-4 px-4 py-2 bg-gradient-to-r from-blue-500/95 via-purple-500/95 to-indigo-500/95 backdrop-blur-sm text-white text-sm font-bold rounded-full shadow-xl border border-white/20 hover:shadow-2xl transition-all duration-300 transform hover:scale-105">
                <span className="flex items-center space-x-2">
                  <span>🏷️</span>
                  <span>{product.category}</span>
                </span>
              </div>

                             {/* Favorite Button */}
               <button
                 onClick={() => toggleFavorite(product._id)}
                 className="group absolute top-4 right-4 p-4 bg-white/95 backdrop-blur-sm rounded-full shadow-xl hover:shadow-2xl transition-all duration-300 transform hover:scale-110 hover:bg-red-50 border border-gray-200/50"
               >
                 {isProductFavorited() ? (
                   <FaHeart className="w-6 h-6 text-red-500 group-hover:animate-pulse" />
                 ) : (
                   <FaRegHeart className="w-6 h-6 text-gray-600 group-hover:text-red-400 transition-colors duration-300" />
                 )}
                
                {/* Tooltip */}
                <div className="absolute right-full mr-3 top-1/2 transform -translate-y-1/2 bg-gray-900 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity duration-300 whitespace-nowrap">
                  {isProductFavorited() ? 'Remove from favorites' : 'Add to favorites'}
                  <div className="absolute left-full top-1/2 transform -translate-y-1/2 w-0 h-0 border-l-4 border-l-gray-900 border-t-2 border-t-transparent border-b-2 border-b-transparent"></div>
                </div>
              </button>

              {/* Featured Badge */}
              {product.featured && (
                <div className="absolute top-4 left-32 px-4 py-2 bg-gradient-to-r from-amber-500/95 via-orange-500/95 to-yellow-500/95 backdrop-blur-sm text-white text-sm font-bold rounded-full shadow-xl border border-white/20 hover:shadow-2xl transition-all duration-300 transform hover:scale-105 animate-pulse">
                  <span className="flex items-center space-x-2">
                    <span>⭐</span>
                    <span>Featured</span>
                  </span>
                </div>
              )}

              {/* Out of Stock Overlay */}
              {!product.inStock && (
                <div className="absolute inset-0 bg-black/50 rounded-2xl flex items-center justify-center">
                  <span className="text-white font-bold text-2xl">Out of Stock</span>
                </div>
              )}
            </div>

            {/* Thumbnail Images */}
            {images.length > 1 && (
              <div className="grid grid-cols-5 gap-3">
                {images.map((image, index) => (
                  <button
                    key={index}
                    onClick={() => setSelectedImage(index)}
                    className={`group relative overflow-hidden rounded-xl border-2 transition-all duration-300 transform hover:scale-105 ${
                      selectedImage === index
                        ? 'border-blue-500 shadow-lg ring-2 ring-blue-200'
                        : 'border-gray-200 hover:border-blue-300 hover:shadow-md'
                    }`}
                  >
                    <img
                      src={image}
                      alt={`${product.name} ${index + 1}`}
                      className="w-full h-20 object-cover transition-transform duration-300 group-hover:scale-110"
                      onError={(e) => {
                        e.target.src = 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=500&h=500&fit=crop'
                      }}
                    />
                    {selectedImage === index && (
                      <div className="absolute inset-0 bg-gradient-to-r from-blue-500/30 to-purple-500/30 flex items-center justify-center backdrop-blur-sm">
                        <div className="bg-white rounded-full p-1 shadow-lg">
                          <FiCheck className="w-4 h-4 text-blue-600" />
                        </div>
                      </div>
                    )}
                    
                    {/* Hover overlay */}
                    <div className="absolute inset-0 bg-black/0 group-hover:bg-black/10 transition-all duration-300"></div>
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Right Column - Product Information */}
          <div className="space-y-8 transform transition-all duration-700 hover:scale-[1.02]">
            {/* Product Header */}
            <div className="relative">
              <h1 className="text-3xl lg:text-4xl font-bold bg-gradient-to-r from-gray-900 via-blue-900 to-purple-900 bg-clip-text text-transparent mb-4 leading-tight">
                {product.name}
              </h1>
              
              {/* Decorative underline */}
              <div className="absolute bottom-0 left-0 w-24 h-1 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full"></div>
              
              {/* Rating */}
              <div className="flex items-center mb-4">
                <div className="flex mr-3">
                  {product.rating > 0 ? renderStars(product.rating) : (
                    <div className="flex text-gray-300">
                      {[...Array(5)].map((_, i) => (
                        <FaStar key={i} className="w-5 h-5" />
                      ))}
                    </div>
                  )}
                </div>
                <span className="text-gray-600 font-medium">
                  {product.rating > 0 ? `${product.rating} (${product.reviewCount} reviews)` : 'No reviews yet'}
                </span>
              </div>

              {/* Price Section */}
              <div className="mb-6">
                <div className="flex items-baseline space-x-3">
                  <span className="text-4xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-600">
                    ${product.price}
                  </span>
                  {product.originalPrice && product.originalPrice > product.price && (
                    <span className="text-2xl text-gray-400 line-through">
                      ${product.originalPrice}
                    </span>
                  )}
                </div>
                {product.originalPrice && product.originalPrice > product.price && (
                  <span className="text-green-600 font-semibold">
                    Save ${(product.originalPrice - product.price).toFixed(2)} ({Math.round(((product.originalPrice - product.price) / product.originalPrice) * 100)}% off)
                  </span>
                )}
              </div>

              {/* Stock Status */}
              <div className="flex items-center space-x-4 mb-6">
                <div className="flex items-center space-x-2">
                  <div className={`w-3 h-3 rounded-full ${product.inStock ? 'bg-green-500' : 'bg-red-500'}`}></div>
                  <span className={`font-medium ${product.inStock ? 'text-green-600' : 'text-red-600'}`}>
                    {product.inStock ? 'In Stock' : 'Out of Stock'}
                  </span>
                </div>
                {product.inStock && (
                  <span className="text-gray-600">
                    {product.stock} units available
                  </span>
                )}
              </div>
            </div>

            {/* Action Buttons */}
            <div className="space-y-6">
              {/* Quantity Selector */}
              <div className="bg-gradient-to-r from-gray-50 to-blue-50 p-6 rounded-2xl border border-gray-200/50">
                <div className="flex items-center justify-between">
                  <label className="text-gray-700 font-semibold text-lg">Quantity:</label>
                  <div className="flex items-center bg-white border-2 border-gray-200 rounded-xl shadow-sm">
                    <button
                      onClick={() => handleQuantityChange(quantity - 1)}
                      disabled={quantity <= 1}
                      className="px-4 py-3 text-gray-600 hover:text-blue-600 hover:bg-blue-50 disabled:opacity-50 disabled:cursor-not-allowed rounded-l-lg transition-all duration-200"
                    >
                      <FiX className="w-5 h-5" />
                    </button>
                    <span className="px-6 py-3 text-gray-900 font-bold text-lg min-w-[4rem] text-center bg-gray-50">
                      {quantity}
                    </span>
                    <button
                      onClick={() => handleQuantityChange(quantity + 1)}
                      disabled={quantity >= (product.stock || 1)}
                      className="px-4 py-3 text-gray-600 hover:text-blue-600 hover:bg-blue-50 disabled:opacity-50 disabled:cursor-not-allowed rounded-r-lg transition-all duration-200"
                    >
                      <FiCheck className="w-5 h-5" />
                    </button>
                  </div>
                </div>
              </div>

              {/* Add to Cart Button */}
              <button
                onClick={addToCart}
                disabled={!product.inStock}
                className={`group w-full font-bold py-5 px-6 rounded-2xl transition-all duration-300 transform hover:scale-105 hover:shadow-2xl disabled:transform-none disabled:cursor-not-allowed shadow-xl ${
                  isInCart(product._id)
                    ? 'bg-gradient-to-r from-blue-600 via-indigo-600 to-purple-600 hover:from-blue-700 hover:via-indigo-700 hover:to-purple-700'
                    : 'bg-gradient-to-r from-emerald-600 via-teal-600 to-cyan-600 hover:from-emerald-700 hover:via-teal-700 hover:to-cyan-700'
                } disabled:from-gray-400 disabled:to-gray-500 text-white`}
              >
                <span className="flex items-center justify-center space-x-3">
                  <FiShoppingCart className="w-6 h-6 group-hover:animate-bounce" />
                  <span className="text-lg">
                    {!product.inStock 
                      ? 'Out of Stock' 
                      : isInCart(product._id) 
                        ? `In Cart (${getItemQuantity(product._id)})` 
                        : 'Add to Cart'
                    }
                  </span>
                  {product.inStock && !isInCart(product._id) && (
                    <span className="text-emerald-200 text-sm">→</span>
                  )}
                  {isInCart(product._id) && (
                    <span className="text-blue-200 text-sm">✓</span>
                  )}
                </span>
              </button>

              {/* Vendor Info */}
              {product.vendorName && (
                <div className="bg-gradient-to-r from-gray-50 to-blue-50 border border-gray-200 rounded-xl p-4 mb-4">
                  <div className="flex items-center space-x-3">
                    <div className="w-12 h-12 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full flex items-center justify-center text-white font-bold text-lg">
                      {product.vendorName.charAt(0).toUpperCase()}
                    </div>
                    <div>
                      <h4 className="font-semibold text-gray-900">{product.vendorName}</h4>
                      <p className="text-sm text-gray-600">Product Creator & Vendor</p>
                    </div>
                  </div>
                </div>
              )}



              {/* Contact Vendor Button */}
              <button
                onClick={contactVendor}
                disabled={contactLoading}
                className="group w-full bg-gradient-to-r from-gray-50 to-blue-50 border-2 border-gray-200 text-gray-700 hover:border-blue-400 hover:from-blue-50 hover:to-indigo-50 hover:text-blue-700 font-semibold py-4 px-6 rounded-2xl transition-all duration-300 transform hover:scale-105 hover:shadow-lg disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span className="flex items-center justify-center space-x-3">
                  <FiMessageCircle className="w-5 h-5 group-hover:animate-pulse" />
                  <span>{contactLoading ? 'Sending Message...' : `Contact ${product.vendorName || 'Vendor'}`}</span>
                  <span className="text-blue-400 group-hover:text-blue-600 transition-colors">💬</span>
                </span>
              </button>
              
              {/* Quick Info */}
              <div className="text-center text-xs text-gray-500 mt-2">
                💡 Vendor responses will appear in your dashboard
              </div>
            </div>

                                         {/* Quick Info Cards */}
                     <div className="grid grid-cols-2 gap-4">
                       <div className="group bg-gradient-to-br from-blue-50 to-indigo-100 p-5 rounded-2xl border border-blue-200/50 shadow-sm hover:shadow-lg hover:scale-105 transition-all duration-300">
                         <div className="flex items-center space-x-4">
                           <div className="p-3 bg-gradient-to-r from-blue-500 to-indigo-600 rounded-xl shadow-lg group-hover:shadow-xl transition-all duration-300">
                             <FiTruck className="w-6 h-6 text-white" />
                           </div>
                           <div>
                             <p className="text-sm text-blue-600 font-medium">Delivery</p>
                             <p className="font-bold text-gray-900 text-lg">3-7 days</p>
                           </div>
                         </div>
                       </div>

                       <div className="group bg-gradient-to-br from-green-50 to-emerald-100 p-5 rounded-2xl border border-green-200/50 shadow-sm hover:shadow-lg hover:scale-105 transition-all duration-300">
                         <div className="flex items-center space-x-4">
                           <div className="p-3 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl shadow-lg group-hover:shadow-xl transition-all duration-300">
                             <FiShield className="w-6 h-6 text-white" />
                           </div>
                           <div>
                             <p className="text-sm text-green-600 font-medium">Warranty</p>
                             <p className="font-bold text-gray-900 text-lg">1 year</p>
                           </div>
                         </div>
                       </div>
                     </div>
        
                 {/* Quick Actions Summary */}
         <div className="mt-8 p-6 bg-gradient-to-r from-blue-50 via-indigo-50 to-purple-50 rounded-2xl border border-blue-200/50 shadow-sm">
           <h4 className="text-lg font-bold text-blue-800 mb-4 flex items-center">
             <span className="mr-2">⚡</span>
             Quick Actions Guide
           </h4>
           <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
             <div className="flex items-center space-x-3 p-3 bg-white/60 rounded-xl border border-blue-200/30">
               <FiHeart className="w-5 h-5 text-red-500" />
               <span className="text-blue-700 font-medium">Click heart to favorite</span>
             </div>
             <div className="flex items-center space-x-3 p-3 bg-white/60 rounded-xl border border-blue-200/30">
               <FiShoppingCart className="w-5 h-5 text-emerald-500" />
               <span className="text-blue-700 font-medium">Add to cart above</span>
             </div>
                           <div className="flex items-center space-x-3 p-3 bg-white/60 rounded-xl border border-blue-200/30">
                <FiMessageCircle className="w-5 h-5 text-blue-500" />
                <span className="text-blue-700 font-medium">Contact vendor & check dashboard</span>
              </div>
           </div>
         </div>
          </div>
        </div>

        {/* Product Details Tabs */}
        <div className="mt-20">
          <div className="border-b border-gray-200 mb-8">
            <nav className="flex space-x-8">
              {[
                { id: 'description', label: 'Description', icon: FiPackage },
                { id: 'specifications', label: 'Specifications', icon: FiCheck },
                { id: 'vendor', label: 'Vendor Info', icon: FiUser },
                { id: 'reviews', label: 'Reviews', icon: FiStar }
              ].map((tab) => {
                const Icon = tab.icon
                return (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id)}
                    className={`flex items-center space-x-2 py-4 px-1 border-b-2 font-medium text-sm transition-colors duration-200 ${
                      activeTab === tab.id
                        ? 'border-blue-500 text-blue-600'
                        : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                    }`}
                  >
                    <Icon className="w-4 h-4" />
                    <span>{tab.label}</span>
                  </button>
                )
              })}
            </nav>
          </div>

          {/* Tab Content */}
          <div className="min-h-[400px]">
            {activeTab === 'description' && (
              <div className="space-y-6">
                <div>
                  <h3 className="text-xl font-semibold text-gray-900 mb-4">Product Description</h3>
                  <p className="text-gray-700 leading-relaxed text-lg">
                    {product.description || 'Detailed description coming soon...'}
                  </p>
                </div>

                {/* Product Features */}
                {product.tags && product.tags.length > 0 && (
                  <div>
                    <h4 className="text-lg font-semibold text-gray-900 mb-3">Product Features</h4>
                    <div className="flex flex-wrap gap-2">
                      {product.tags.map((tag, index) => (
                        <span
                          key={index}
                          className="px-3 py-1 bg-blue-100 text-blue-800 text-sm font-medium rounded-full"
                        >
                          {tag}
                        </span>
                      ))}
                    </div>
                  </div>
                )}

                {/* Care Instructions */}
                {product.careInstructions && (
                  <div>
                    <h4 className="text-lg font-semibold text-gray-900 mb-3">Care Instructions</h4>
                    <p className="text-gray-700 leading-relaxed">
                      {product.careInstructions}
                    </p>
                  </div>
                )}
              </div>
            )}

            {activeTab === 'specifications' && (
              <div className="space-y-6">
                <h3 className="text-xl font-semibold text-gray-900 mb-4">Product Specifications</h3>
                
                <div className="grid md:grid-cols-2 gap-6">
                  {/* Basic Specs */}
                  <div className="space-y-4">
                    <h4 className="text-lg font-medium text-gray-900">Basic Information</h4>
                    <div className="space-y-3">
                      <div className="flex justify-between py-2 border-b border-gray-100">
                        <span className="text-gray-600">Category</span>
                        <span className="font-medium text-gray-900">{product.category}</span>
                      </div>
                      <div className="flex justify-between py-2 border-b border-gray-100">
                        <span className="text-gray-600">Material</span>
                        <span className="font-medium text-gray-900">
                          {product.materials?.join(', ') || 'Not specified'}
                        </span>
                      </div>
                      <div className="flex justify-between py-2 border-b border-gray-100">
                        <span className="text-gray-600">Weight</span>
                        <span className="font-medium text-gray-900">
                          {product.weight?.value ? `${product.weight.value} ${product.weight.unit}` : 'Not specified'}
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* Dimensions */}
                  <div className="space-y-4">
                    <h4 className="text-lg font-medium text-gray-900">Dimensions</h4>
                    <div className="space-y-3">
                      {product.dimensions ? (
                        <>
                          {product.dimensions.length && (
                            <div className="flex justify-between py-2 border-b border-gray-100">
                              <span className="text-gray-600">Length</span>
                              <span className="font-medium text-gray-900">{product.dimensions.length}</span>
                            </div>
                          )}
                          {product.dimensions.width && (
                            <div className="flex justify-between py-2 border-b border-gray-100">
                              <span className="text-gray-600">Width</span>
                              <span className="font-medium text-gray-900">{product.dimensions.width}</span>
                            </div>
                          )}
                          {product.dimensions.height && (
                            <div className="flex justify-between py-2 border-b border-gray-100">
                              <span className="text-gray-600">Height</span>
                              <span className="font-medium text-gray-900">{product.dimensions.height}</span>
                            </div>
                          )}
                        </>
                      ) : (
                        <p className="text-gray-500">Dimensions not specified</p>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'vendor' && (
              <div className="space-y-6">
                <h3 className="text-xl font-semibold text-gray-900 mb-4">Vendor Information</h3>
                
                {vendorProfile ? (
                  <div className="bg-white rounded-2xl p-6 border border-gray-200 shadow-sm">
                    <div className="flex items-start space-x-4">
                      <img
                        src={vendorProfile.profileImage}
                        alt={vendorProfile.shopName}
                        className="w-20 h-20 rounded-full object-cover border-2 border-gray-200"
                        onError={(e) => {
                          e.target.style.display = 'none'
                        }}
                      />
                      <div className="flex-1">
                        <h4 className="text-xl font-semibold text-gray-900 mb-2">
                          {vendorProfile.shopName}
                        </h4>
                        <p className="text-gray-600 mb-3">
                          {vendorProfile.bio || 'Passionate artisan creating unique handmade treasures.'}
                        </p>
                        
                        <div className="grid md:grid-cols-3 gap-4 mb-4">
                          <div className="text-center">
                            <div className="text-2xl font-bold text-blue-600">
                              {vendorProfile.stats?.totalProducts || 0}
                            </div>
                            <div className="text-sm text-gray-600">Products</div>
                          </div>
                          <div className="text-center">
                            <div className="text-2xl font-bold text-green-600">
                              {vendorProfile.stats?.totalSales || 0}
                            </div>
                            <div className="text-sm text-gray-600">Sales</div>
                          </div>
                          <div className="text-center">
                            <div className="text-2xl font-bold text-purple-600">
                              {vendorProfile.rating || 0}
                            </div>
                            <div className="text-sm text-gray-600">Rating</div>
                          </div>
                        </div>

                        {vendorProfile.location?.address && (
                          <div className="flex items-center text-gray-600 mb-3">
                            <FiMapPin className="w-4 h-4 mr-2" />
                            <span>{vendorProfile.location.address}</span>
                          </div>
                        )}

                        <div className="flex space-x-3">
                          <button
                            onClick={contactVendor}
                            className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors duration-200"
                          >
                            <span className="flex items-center space-x-2">
                              <FiMessageCircle className="w-4 h-4" />
                              <span>Message Vendor</span>
                            </span>
                          </button>
                          <Link
                            to={`/profile/${vendorProfile.userId}`}
                            className="border border-gray-300 text-gray-700 hover:border-blue-500 hover:text-blue-600 px-4 py-2 rounded-lg font-medium transition-colors duration-200"
                          >
                            View Profile
                          </Link>
                        </div>
                      </div>
                    </div>
                  </div>
                ) : (
                  <div className="text-center py-12">
                    <div className="text-4xl mb-4">👤</div>
                    <h4 className="text-lg font-medium text-gray-900 mb-2">Vendor Information</h4>
                    <p className="text-gray-600">Vendor profile details not available</p>
                  </div>
                )}
              </div>
            )}

                         {activeTab === 'reviews' && (
               <div className="space-y-6">
                 <h3 className="text-xl font-semibold text-gray-900 mb-4">Customer Reviews</h3>
                 
                 {/* Review Form for Customers */}
                 <ReviewForm 
                   productId={product._id}
                   onReviewSubmitted={handleReviewSubmitted}
                   userReview={userReview}
                 />
                 
                 {/* Reviews List */}
                 <ReviewList 
                   key={reviewsKey}
                   productId={product._id}
                   onReviewSubmitted={handleReviewSubmitted}
                 />
               </div>
             )}
          </div>
        </div>

        {/* Shipping & Delivery Info */}
        <div className="mt-20 bg-gradient-to-br from-white via-blue-50/30 to-indigo-50/30 rounded-3xl p-8 border border-gray-200/50 shadow-xl hover:shadow-2xl transition-all duration-500">
          <h3 className="text-3xl font-bold bg-gradient-to-r from-gray-900 via-blue-900 to-purple-900 bg-clip-text text-transparent mb-8 text-center">
            🚚 Shipping & Delivery
          </h3>
          
          <div className="grid md:grid-cols-3 gap-8">
            <div className="group text-center transform hover:scale-105 transition-all duration-300">
              <div className="w-20 h-20 bg-gradient-to-r from-blue-500 to-indigo-600 rounded-full flex items-center justify-center mx-auto mb-4 shadow-lg group-hover:shadow-xl transition-all duration-300">
                <FiClock className="w-10 h-10 text-white" />
              </div>
              <h4 className="text-xl font-bold text-gray-900 mb-3">Processing Time</h4>
              <p className="text-gray-600 font-medium">1-2 business days</p>
            </div>
            
            <div className="group text-center transform hover:scale-105 transition-all duration-300">
              <div className="w-20 h-20 bg-gradient-to-r from-emerald-500 to-teal-600 rounded-full flex items-center justify-center mx-auto mb-4 shadow-lg group-hover:shadow-xl transition-all duration-300">
                <FiTruck className="w-10 h-10 text-white" />
              </div>
              <h4 className="text-xl font-bold text-gray-900 mb-3">Delivery Time</h4>
              <p className="text-gray-600 font-medium">3-7 business days</p>
            </div>
            
            <div className="group text-center transform hover:scale-105 transition-all duration-300">
              <div className="w-20 h-20 bg-gradient-to-r from-purple-500 to-pink-600 rounded-full flex items-center justify-center mx-auto mb-4 shadow-lg group-hover:shadow-xl transition-all duration-300">
                <FiPackage className="w-10 h-10 text-white" />
              </div>
              <h4 className="text-xl font-bold text-gray-900 mb-3">Shipping Cost</h4>
              <p className="text-gray-600 font-medium">Free shipping on orders over $50</p>
            </div>
          </div>
        </div>
        
        {/* Floating Action Button */}
        <div className="fixed bottom-8 right-8 z-50">
          <div className="flex flex-col space-y-3">
                         {/* Quick Favorite Button */}
             <button
               onClick={() => toggleFavorite(product._id)}
               className="group bg-white p-4 rounded-full shadow-2xl hover:shadow-3xl transition-all duration-300 transform hover:scale-110 border border-gray-200"
             >
               {isProductFavorited() ? (
                 <FaHeart className="w-6 h-6 text-red-500 group-hover:animate-pulse" />
               ) : (
                 <FaRegHeart className="w-6 h-6 text-gray-600 group-hover:text-red-400 transition-colors duration-300" />
               )}
              
              {/* Tooltip */}
              <div className="absolute right-full mr-3 top-1/2 transform -translate-y-1/2 bg-gray-900 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity duration-300 whitespace-nowrap">
                {isProductFavorited() ? 'Remove from favorites' : 'Add to favorites'}
                <div className="absolute left-full top-1/2 transform -translate-y-1/2 w-0 h-0 border-l-4 border-l-gray-900 border-t-2 border-t-transparent border-b-2 border-b-transparent"></div>
              </div>
            </button>
            
            {/* Quick Add to Cart Button */}
            <button
              onClick={addToCart}
              disabled={!product.inStock}
              className="group bg-gradient-to-r from-emerald-500 to-teal-500 p-4 rounded-full shadow-2xl hover:shadow-3xl transition-all duration-300 transform hover:scale-110 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <FiShoppingCart className="w-6 h-6 text-white group-hover:animate-bounce" />
              
              {/* Tooltip */}
              <div className="absolute right-full mr-3 top-1/2 transform -translate-y-1/2 bg-gray-900 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity duration-300 whitespace-nowrap">
                Add to cart
                <div className="absolute left-full top-1/2 transform -translate-y-1/2 w-0 h-0 border-l-4 border-l-gray-900 border-t-2 border-t-transparent border-b-2 border-b-transparent"></div>
              </div>
            </button>
            
            {/* Quick Contact Vendor Button */}
            <button
              onClick={contactVendor}
              disabled={contactLoading}
              className="group bg-gradient-to-r from-blue-500 to-indigo-500 p-4 rounded-full shadow-2xl hover:shadow-3xl transition-all duration-300 transform hover:scale-110 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <FiMessageCircle className="w-6 h-6 text-white group-hover:animate-pulse" />
              
              {/* Tooltip */}
              <div className="absolute right-full mr-3 top-1/2 transform -translate-y-1/2 bg-gray-900 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity duration-300 whitespace-nowrap">
                {contactLoading ? 'Sending...' : 'Contact vendor'}
                <div className="absolute left-full top-1/2 transform -translate-y-1/2 w-0 h-0 border-l-4 border-l-gray-900 border-t-2 border-t-transparent border-b-2 border-b-transparent"></div>
              </div>
            </button>
            
            {/* Scroll to Top Button */}
            <button
              onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}
              className="group bg-gradient-to-r from-blue-500 to-purple-500 p-4 rounded-full shadow-2xl hover:shadow-3xl transition-all duration-300 transform hover:scale-110"
            >
              <FiArrowLeft className="w-6 h-6 text-white transform rotate-90 group-hover:animate-pulse" />
              
              {/* Tooltip */}
              <div className="absolute right-full mr-3 top-1/2 transform -translate-y-1/2 bg-gray-900 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity duration-300 whitespace-nowrap">
                Scroll to top
                <div className="absolute left-full top-1/2 transform -translate-y-1/2 w-0 h-0 border-l-4 border-l-gray-900 border-t-2 border-t-transparent border-b-2 border-b-transparent"></div>
              </div>
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default ProductDetail
