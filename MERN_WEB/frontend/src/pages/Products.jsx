import React, { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { FiSearch, FiFilter, FiGrid, FiList, FiHeart, FiShoppingCart, FiStar, FiChevronDown, FiChevronUp, FiX } from 'react-icons/fi'
import { useFavorites } from '../contexts/FavoritesContext'

const Products = () => {
  const { favorites, toggleFavorite, checkFavoriteStatus } = useFavorites()
  const [products, setProducts] = useState([])
  const [filteredProducts, setFilteredProducts] = useState([])
  const [loading, setLoading] = useState(true)
  const [viewMode, setViewMode] = useState('grid') // 'grid' or 'list'
  const [showFilters, setShowFilters] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedCategory, setSelectedCategory] = useState('all')
  const [priceRange, setPriceRange] = useState([0, 500])
  const [sortBy, setSortBy] = useState('featured')
  const [currentPage, setCurrentPage] = useState(1)
  const [productsPerPage] = useState(12)

  

  const [categories, setCategories] = useState([
    { id: 'all', name: 'All Categories', count: 0 }
  ])

  // Fetch real products from API
  useEffect(() => {
    const fetchProducts = async () => {
      try {
        setLoading(true)
        const response = await fetch('/api/products?limit=100')
        if (response.ok) {
          const data = await response.json()
          const fetchedProducts = data.products || []
          
          // Debug: Log the raw product data to see stock values and ratings
          console.log('Raw products from API:', fetchedProducts.map(p => ({ 
            id: p._id, 
            name: p.name, 
            stock: p.stock, 
            stockType: typeof p.stock,
            inStockCalc: parseInt(p.stock) > 0,
            rating: p.rating,
            reviewCount: p.reviewCount
          })))
          
          // Transform products to match expected format
          const transformedProducts = fetchedProducts.map(product => ({
            _id: product._id,
            name: product.name,
            price: product.price,
            originalPrice: product.price * 1.2, // Add some markup for display
            rating: product.rating || 0,
            reviewCount: product.reviewCount || 0,
            vendorName: product.vendorName || 'Unknown Vendor',
            category: product.category || 'General',
            image: product.images?.[0] || 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=500&h=500&fit=crop',
            description: product.description || 'Beautiful handmade product',
            tags: product.tags || ['handmade', 'artisan'],
            inStock: parseInt(product.stock) > 0,
            featured: product.featured || false
          }))
          
          setProducts(transformedProducts)
          setFilteredProducts(transformedProducts)
          
          // Update categories dynamically
          updateCategories(transformedProducts)
        } else {
          console.error('Failed to fetch products')
          // If no products in database, show sample products
          const sampleProducts = [
            {
              _id: 'sample1',
              name: 'Handcrafted Silver Filigree Necklace',
              price: 89.99,
              originalPrice: 129.99,
              rating: 4.8,
              reviewCount: 127,
              vendorName: 'SilverCraft Studio',
              category: 'Jewelry',
              image: 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=500&h=500&fit=crop',
              description: 'Exquisite handcrafted silver necklace with intricate filigree work. Each piece is uniquely designed and crafted with attention to detail.',
              tags: ['handmade', 'silver', 'filigree', 'necklace', 'artisan'],
              inStock: true,
              featured: true
            },
            {
              _id: 'sample2',
              name: 'Ceramic Vase Collection - Earth Tones',
              price: 45.50,
              originalPrice: 65.00,
              rating: 4.6,
              reviewCount: 89,
              vendorName: 'Earth & Fire Pottery',
              category: 'Home Decor',
              image: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=500&h=500&fit=crop',
              description: 'Beautiful hand-thrown ceramic vases in warm earth tones. Perfect for adding natural elegance to any room.',
              tags: ['ceramic', 'handmade', 'vase', 'earth tones', 'pottery'],
              inStock: true,
              featured: false
            }
          ]
          setProducts(sampleProducts)
          setFilteredProducts(sampleProducts)
          updateCategories(sampleProducts)
        }
      } catch (error) {
        console.error('Error fetching products:', error)
        // If API call fails, show sample products
        const sampleProducts = [
          {
            _id: 'sample1',
            name: 'Handcrafted Silver Filigree Necklace',
            price: 89.99,
            originalPrice: 129.99,
            rating: 4.8,
            reviewCount: 127,
            vendorName: 'SilverCraft Studio',
            category: 'Jewelry',
            image: 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=500&h=500&fit=crop',
            description: 'Exquisite handcrafted silver necklace with intricate filigree work. Each piece is uniquely designed and crafted with attention to detail.',
            tags: ['handmade', 'silver', 'filigree', 'necklace', 'artisan'],
            inStock: true,
            featured: true
          },
          {
            _id: 'sample2',
            name: 'Ceramic Vase Collection - Earth Tones',
            price: 45.50,
            originalPrice: 65.00,
            rating: 4.6,
            reviewCount: 89,
            vendorName: 'Earth & Fire Pottery',
            category: 'Home Decor',
            image: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=500&h=500&fit=crop',
            description: 'Beautiful hand-thrown ceramic vases in warm earth tones. Perfect for adding natural elegance to any room.',
            tags: ['ceramic', 'handmade', 'vase', 'earth tones', 'pottery'],
            inStock: true,
            featured: false
          }
        ]
        setProducts(sampleProducts)
        setFilteredProducts(sampleProducts)
        updateCategories(sampleProducts)
      } finally {
        setLoading(false)
      }
    }

    fetchProducts()
  }, [])

  // Check if a product is in favorites
  const isProductFavorited = (productId) => {
    return favorites.some(fav => fav.product._id === productId)
  }

  // Update categories based on real product data
  const updateCategories = (productData) => {
    const categoryMap = new Map()
    productData.forEach(product => {
      if (product.category && product.category.trim()) {
        categoryMap.set(product.category, (categoryMap.get(product.category) || 0) + 1)
      }
    })
    
    const categoryOptions = [
      { id: 'all', name: 'All Categories', count: productData.length }
    ]
    
    categoryMap.forEach((count, category) => {
      categoryOptions.push({ 
        id: category.toLowerCase().replace(/\s+/g, '-'), 
        name: category, 
        count 
      })
    })
    
    setCategories(categoryOptions)
  }

  // Refresh products function
  const refreshProducts = () => {
    window.location.reload()
  }

  // Filter and search products
  useEffect(() => {
    let filtered = [...products]

    // Category filter
    if (selectedCategory !== 'all') {
      const selectedCategoryName = categories.find(cat => cat.id === selectedCategory)?.name
      if (selectedCategoryName) {
        filtered = filtered.filter(product => product.category === selectedCategoryName)
      }
    }

    // Price filter
    filtered = filtered.filter(product => product.price >= priceRange[0] && product.price <= priceRange[1])

    // Search filter
    if (searchQuery) {
      filtered = filtered.filter(product =>
        product.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        product.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
        product.tags.some(tag => tag.toLowerCase().includes(searchQuery.toLowerCase()))
      )
    }

    // Sort products
    switch (sortBy) {
      case 'price-low':
        filtered.sort((a, b) => a.price - b.price)
        break
      case 'price-high':
        filtered.sort((a, b) => b.price - a.price)
        break
      case 'rating':
        filtered.sort((a, b) => b.rating - a.rating)
        break
      case 'newest':
        filtered.sort((a, b) => new Date(b.createdAt || Date.now()) - new Date(a.createdAt || Date.now()))
        break
      default: // featured
        filtered.sort((a, b) => (b.featured ? 1 : 0) - (a.featured ? 1 : 0))
    }

    setFilteredProducts(filtered)
    setCurrentPage(1)
  }, [products, selectedCategory, priceRange, searchQuery, sortBy])

  // Pagination
  const indexOfLastProduct = currentPage * productsPerPage
  const indexOfFirstProduct = indexOfLastProduct - productsPerPage
  const currentProducts = filteredProducts.slice(indexOfFirstProduct, indexOfLastProduct)
  const totalPages = Math.ceil(filteredProducts.length / productsPerPage)

  const handlePageChange = (pageNumber) => {
    setCurrentPage(pageNumber)
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  const ProductCard = ({ product }) => (
    <Link 
      to={`/products/${product._id}`}
      className="group relative bg-white rounded-2xl shadow-lg border border-gray-200/50 overflow-hidden hover:shadow-2xl hover:shadow-blue-100/50 transition-all duration-700 transform hover:scale-105 hover:-translate-y-2 block cursor-pointer"
      onClick={() => console.log('Navigating to product ID:', product._id)}
    >
      {/* Product Image Container */}
      <div className="relative overflow-hidden">
        <img
          src={product.image}
          alt={product.name}
          className="w-full h-64 object-cover group-hover:scale-110 transition-transform duration-700"
          onError={(e) => {
            e.target.src = 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=500&h=500&fit=crop'
          }}
        />
        
        {/* Image overlay gradient */}
        <div className="absolute inset-0 bg-gradient-to-t from-black/20 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
        
        {/* Heart button - positioned to not interfere with card click */}
        <button 
          className="absolute top-4 right-4 p-3 bg-white/90 backdrop-blur-sm rounded-full shadow-lg hover:bg-white hover:shadow-xl transition-all duration-300 transform hover:scale-110 group-hover:bg-red-50 z-10"
          onClick={(e) => {
            e.preventDefault()
            e.stopPropagation()
            toggleFavorite(product._id)
          }}
        >
          {isProductFavorited(product._id) ? (
            <FiHeart className="w-5 h-5 text-red-500 fill-current" />
          ) : (
            <FiHeart className="w-5 h-5 text-gray-600 group-hover:text-red-500 transition-colors duration-300" />
          )}
        </button>
        
        {/* Category badge */}
        <div className="absolute bottom-4 left-4 px-3 py-1 bg-gradient-to-r from-blue-500/90 to-purple-500/90 backdrop-blur-sm text-white text-xs font-semibold rounded-full shadow-lg">
          {product.category}
        </div>

        {/* Featured badge */}
        {product.featured && (
          <div className="absolute top-4 left-4 px-3 py-1 bg-gradient-to-r from-amber-500/90 to-orange-500/90 backdrop-blur-sm text-white text-xs font-semibold rounded-full shadow-lg">
            ⭐ Featured
          </div>
        )}

        {/* Out of stock overlay */}
        {!product.inStock && (
          <div className="absolute inset-0 bg-black/50 flex items-center justify-center">
            <span className="text-white font-bold text-lg">Out of Stock</span>
          </div>
        )}
      </div>
      
      {/* Product Content */}
      <div className="p-6 bg-gradient-to-br from-white to-gray-50">
        {/* Rating Section */}
        <div className="flex items-center mb-3">
          {product.rating > 0 ? (
            <>
              <div className="flex text-amber-400">
                {[...Array(5)].map((_, i) => (
                  <FiStar
                    key={i}
                    className={`w-4 h-4 ${i < product.rating ? 'fill-current' : ''}`}
                  />
                ))}
              </div>
              <span className="text-sm text-gray-500 ml-2 font-medium">
                ({product.reviewCount})
              </span>
            </>
          ) : (
            <div className="flex items-center text-gray-400">
              {[...Array(5)].map((_, i) => (
                <FiStar key={i} className="w-4 h-4" />
              ))}
              <span className="text-sm text-gray-500 ml-2 font-medium">
                No reviews yet
              </span>
            </div>
          )}
        </div>
        
        {/* Product Title */}
        <h3 className="font-bold text-gray-900 mb-2 text-lg leading-tight group-hover:text-transparent group-hover:bg-clip-text group-hover:bg-gradient-to-r group-hover:from-blue-600 group-hover:to-purple-600 transition-all duration-500 line-clamp-2">
          {product.name}
        </h3>
        
        {/* Description */}
        <p className="text-gray-600 text-sm mb-3 line-clamp-2">
          {product.description}
        </p>
        
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
          <div className="text-right">
            <span className="text-xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-600 group-hover:from-blue-700 group-hover:to-purple-700 transition-all duration-300">
              ${product.price}
            </span>
            {product.originalPrice > product.price && (
              <span className="block text-sm text-gray-400 line-through">
                ${product.originalPrice}
              </span>
            )}
          </div>
        </div>
        
        {/* Quick Action Hints */}
        <div className="text-center">
          <div className="inline-flex items-center space-x-2 text-blue-600 text-sm font-medium group-hover:text-blue-700 transition-colors duration-300">
            <span>Click to view details</span>
            <FiChevronDown className="w-4 h-4 group-hover:translate-y-1 transition-transform duration-300" />
          </div>
          
          {/* Hover hint */}
          <div className="mt-2 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
            <div className="inline-flex items-center space-x-1 text-xs text-gray-500">
              <span>🖱️ Click anywhere on card</span>
            </div>
          </div>
        </div>
      </div>
      
      {/* Hover border effect */}
      <div className="absolute inset-0 rounded-2xl border-2 border-transparent group-hover:border-gradient-to-r group-hover:from-blue-500 group-hover:via-purple-500 group-hover:to-indigo-500 transition-all duration-700 opacity-0 group-hover:opacity-100"></div>
      
      {/* Click indicator */}
      <div className="absolute inset-0 rounded-2xl bg-gradient-to-r from-blue-500/5 via-purple-500/5 to-indigo-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-300 pointer-events-none"></div>
      
      {/* Floating particles on hover */}
      <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-700">
        <div className="absolute top-6 left-6 w-2 h-2 bg-blue-400 rounded-full animate-ping"></div>
        <div className="absolute top-8 right-6 w-1.5 h-1.5 bg-purple-400 rounded-full animate-ping" style={{ animationDelay: '0.3s' }}></div>
        <div className="absolute bottom-6 left-8 w-1 h-1 bg-indigo-400 rounded-full animate-ping" style={{ animationDelay: '0.6s' }}></div>
      </div>
      
      {/* Shine effect on hover */}
      <div className="absolute inset-0 rounded-2xl bg-gradient-to-r from-transparent via-white/30 to-transparent -translate-x-full group-hover:translate-x-full transition-transform duration-1000 ease-out"></div>
    </Link>
  )

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-50 via-gray-100 to-slate-100 py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <div className="animate-pulse">
              <div className="h-12 bg-gray-300 rounded-lg w-64 mx-auto mb-4"></div>
              <div className="h-6 bg-gray-300 rounded w-96 mx-auto"></div>
            </div>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {[...Array(8)].map((_, index) => (
              <div key={index} className="bg-white rounded-2xl p-6 animate-pulse shadow-lg">
                <div className="bg-gradient-to-br from-gray-200 to-gray-300 h-64 rounded-xl mb-4"></div>
                <div className="bg-gradient-to-r from-gray-200 to-gray-300 h-4 rounded mb-3"></div>
                <div className="bg-gradient-to-r from-gray-200 to-gray-300 h-4 rounded w-2/3 mb-4"></div>
                <div className="bg-gradient-to-r from-gray-200 to-gray-300 h-8 rounded-lg"></div>
              </div>
            ))}
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 via-gray-100 to-slate-100 py-20">
      {/* Background decorative elements */}
      <div className="absolute inset-0">
        <div className="absolute top-20 right-20 w-36 h-36 bg-gradient-to-r from-blue-200/20 to-indigo-200/20 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute bottom-20 left-20 w-44 h-44 bg-gradient-to-r from-emerald-200/20 to-teal-200/20 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute top-1/3 right-1/3 w-28 h-28 bg-gradient-to-r from-amber-200/20 to-orange-200/20 rounded-full blur-2xl animate-bounce"></div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        {/* Header Section */}
        <div className="text-center mb-16">
          <h1 className="text-4xl md:text-5xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-slate-800 via-slate-700 to-gray-800 mb-6">
            Discover Our Products
          </h1>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto leading-relaxed mb-6">
            Explore our curated collection of handmade treasures. Each product tells a unique story of 
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-600 font-semibold"> craftsmanship and creativity</span>.
          </p>
          {products.length > 0 && (
            <div className="flex items-center justify-center space-x-4 text-sm text-gray-500">
              <span>📦 {products.length} products available</span>
              <span>•</span>
              <span>🔄 Real-time data from vendors</span>
              <span>•</span>
              <button
                onClick={refreshProducts}
                className="text-blue-600 hover:text-blue-800 font-medium transition-colors duration-200"
              >
                Refresh Products
              </button>
            </div>
          )}
          
          {/* Debug Info */}
          {products.length > 0 && (
            <div className="text-center text-xs text-gray-400 mt-2">
              {products.some(p => p._id.startsWith('sample')) ? (
                <span>Showing sample products (no real products in database yet)</span>
              ) : (
                <span>Showing real products from database</span>
              )}
            </div>
          )}
          

        </div>

        {/* Search and Filter Section */}
        <div className="bg-white rounded-2xl shadow-lg border border-gray-200/50 p-6 mb-8">
          <div className="flex flex-col lg:flex-row gap-6 items-center">
            {/* Search Bar */}
            <div className="flex-1 w-full lg:w-auto">
              <div className="relative">
                <FiSearch className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
                <input
                  type="text"
                  placeholder="Search for products, artisans, or categories..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
                />
              </div>
            </div>

            {/* Category Filter */}
            <div className="flex items-center space-x-4">
              <select
                value={selectedCategory}
                onChange={(e) => setSelectedCategory(e.target.value)}
                className="px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
              >
                {categories.map(category => (
                  <option key={category.id} value={category.id}>
                    {category.name} ({category.count})
                  </option>
                ))}
              </select>

              {/* Sort Dropdown */}
              <select
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value)}
                className="px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
              >
                <option value="featured">Featured</option>
                <option value="price-low">Price: Low to High</option>
                <option value="price-high">Price: High to Low</option>
                <option value="rating">Highest Rated</option>
                <option value="newest">Newest</option>
              </select>

              {/* View Mode Toggle */}
              <div className="flex items-center space-x-2 bg-gray-100 rounded-xl p-1">
                <button
                  onClick={() => setViewMode('grid')}
                  className={`p-2 rounded-lg transition-all duration-200 ${viewMode === 'grid' ? 'bg-white shadow-md' : 'text-gray-500 hover:text-gray-700'}`}
                >
                  <FiGrid className="w-5 h-5" />
                </button>
                <button
                  onClick={() => setViewMode('list')}
                  className={`p-2 rounded-lg transition-all duration-200 ${viewMode === 'list' ? 'bg-white shadow-md' : 'text-gray-500 hover:text-gray-700'}`}
                >
                  <FiList className="w-5 h-5" />
                </button>
              </div>
            </div>
          </div>

          {/* Price Range Filter */}
          <div className="mt-6 pt-6 border-t border-gray-200">
            <div className="flex items-center space-x-4">
              <span className="text-gray-700 font-medium">Price Range:</span>
              <div className="flex items-center space-x-2">
                <span className="text-gray-600">${priceRange[0]}</span>
                <input
                  type="range"
                  min="0"
                  max="500"
                  value={priceRange[1]}
                  onChange={(e) => setPriceRange([priceRange[0], parseInt(e.target.value)])}
                  className="w-32 h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer slider"
                />
                <span className="text-gray-600">${priceRange[1]}</span>
              </div>
            </div>
          </div>
        </div>

        {/* Results Summary */}
        <div className="flex items-center justify-between mb-8">
          <div className="flex items-center space-x-4">
            <p className="text-gray-600">
              Showing {filteredProducts.length} of {products.length} products
            </p>
            {products.length === 0 && (
              <span className="text-amber-600 text-sm bg-amber-50 px-3 py-1 rounded-full">
                🚀 No products yet - be the first vendor!
              </span>
            )}
          </div>
          {totalPages > 1 && (
            <p className="text-gray-600">
              Page {currentPage} of {totalPages}
            </p>
          )}
        </div>

        {/* Products Grid */}
        <div className={`grid gap-8 ${viewMode === 'grid' ? 'grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4' : 'grid-cols-1'}`}>
          {currentProducts.map((product) => (
            <ProductCard key={product._id} product={product} />
          ))}
        </div>

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="flex justify-center items-center space-x-2 mt-16">
            <button
              onClick={() => handlePageChange(currentPage - 1)}
              disabled={currentPage === 1}
              className="px-4 py-2 bg-white border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
            >
              Previous
            </button>
            
            {[...Array(totalPages)].map((_, index) => {
              const pageNumber = index + 1
              return (
                <button
                  key={pageNumber}
                  onClick={() => handlePageChange(pageNumber)}
                  className={`px-4 py-2 rounded-lg transition-all duration-200 ${
                    currentPage === pageNumber
                      ? 'bg-gradient-to-r from-blue-600 to-purple-600 text-white shadow-lg'
                      : 'bg-white border border-gray-300 text-gray-700 hover:bg-gray-50'
                  }`}
                >
                  {pageNumber}
                </button>
              )
            })}
            
            <button
              onClick={() => handlePageChange(currentPage + 1)}
              disabled={currentPage === totalPages}
              className="px-4 py-2 bg-white border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
            >
              Next
            </button>
          </div>
        )}

        {/* No Results */}
        {filteredProducts.length === 0 && (
          <div className="text-center py-16">
            <div className="text-6xl mb-4">🔍</div>
            <h3 className="text-2xl font-bold text-gray-900 mb-2">
              {products.length === 0 ? 'No products available yet' : 'No products found'}
            </h3>
            <p className="text-gray-600 mb-6">
              {products.length === 0 
                ? 'Be the first to add products to our marketplace! Vendors can create products in their dashboard.'
                : 'Try adjusting your search criteria or browse all categories'
              }
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              {products.length === 0 ? (
                <>
                  <button
                    onClick={refreshProducts}
                    className="bg-gradient-to-r from-blue-600 to-purple-600 text-white px-6 py-3 rounded-xl font-semibold hover:from-blue-700 hover:to-purple-700 transition-all duration-200 transform hover:scale-105"
                  >
                    Refresh Page
                  </button>
                  <Link
                    to="/register"
                    className="bg-gradient-to-r from-green-600 to-emerald-600 text-white px-6 py-3 rounded-xl font-semibold hover:from-green-700 hover:to-emerald-700 transition-all duration-200 transform hover:scale-105"
                  >
                    Become a Vendor
                  </Link>
                </>
              ) : (
                <button
                  onClick={() => {
                    setSearchQuery('')
                    setSelectedCategory('all')
                    setPriceRange([0, 500])
                    setSortBy('featured')
                  }}
                  className="bg-gradient-to-r from-blue-600 to-purple-600 text-white px-6 py-3 rounded-xl font-semibold hover:from-blue-700 hover:to-purple-700 transition-all duration-200 transform hover:scale-105"
                >
                  Clear Filters
                </button>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

export default Products
