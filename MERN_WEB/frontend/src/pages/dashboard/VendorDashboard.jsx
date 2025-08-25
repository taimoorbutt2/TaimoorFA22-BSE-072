import React, { useState, useEffect } from 'react'
import { useAuth } from '../../contexts/AuthContext'
import { 
  FiPlus, 
  FiPackage, 
  FiDollarSign, 
  FiTrendingUp, 
  FiEdit2, 
  FiTrash2, 
  FiEye,
  FiUpload,
  FiShoppingBag,
  FiStar,
  FiUsers
} from 'react-icons/fi'
import toast from 'react-hot-toast'

const VendorDashboard = () => {
  const { user } = useAuth()
  const [activeTab, setActiveTab] = useState('overview')
  const [products, setProducts] = useState([])
  const [loading, setLoading] = useState(false)
  const [showAddProduct, setShowAddProduct] = useState(false)
  const [editingProduct, setEditingProduct] = useState(null)

  // Mock data for now - will be replaced with real API calls
  const mockProducts = [
    {
      id: 1,
      name: 'Handmade Ceramic Vase',
      description: 'Beautiful handcrafted ceramic vase with unique patterns',
      price: 89.99,
      category: 'Home Decor',
      image: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=400&fit=crop',
      stock: 15,
      status: 'active',
      sales: 8,
      rating: 4.8
    },
    {
      id: 2,
      name: 'Artisan Leather Wallet',
      description: 'Premium leather wallet hand-stitched with care',
      price: 45.00,
      category: 'Accessories',
      image: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop',
      stock: 22,
      status: 'active',
      sales: 12,
      rating: 4.9
    }
  ]

  const [newProduct, setNewProduct] = useState({
    name: '',
    description: '',
    price: '',
    category: '',
    stock: '',
    image: ''
  })

  useEffect(() => {
    // Load products (mock data for now)
    setProducts(mockProducts)
  }, [])

  const handleAddProduct = async (e) => {
    e.preventDefault()
    setLoading(true)

    try {
      // Validate form
      if (!newProduct.name || !newProduct.description || !newProduct.price || !newProduct.category) {
        toast.error('Please fill in all required fields')
        return
      }

      if (newProduct.price <= 0) {
        toast.error('Price must be greater than 0')
        return
      }

      if (newProduct.stock < 0) {
        toast.error('Stock cannot be negative')
        return
      }

      // Create new product object
      const product = {
        id: Date.now(), // Temporary ID
        ...newProduct,
        price: parseFloat(newProduct.price),
        stock: parseInt(newProduct.stock),
        status: 'active',
        sales: 0,
        rating: 0,
        createdAt: new Date().toISOString()
      }

      // Add to products list
      setProducts([...products, product])
      
      // Reset form
      setNewProduct({
        name: '',
        description: '',
        price: '',
        category: '',
        stock: '',
        image: ''
      })
      
      setShowAddProduct(false)
      toast.success('Product added successfully!')
      
      // TODO: Make API call to backend
      // await addProduct(product)
      
    } catch (error) {
      toast.error('Failed to add product')
      console.error('Add product error:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleEditProduct = (product) => {
    setEditingProduct(product)
    setNewProduct({
      name: product.name,
      description: product.description,
      price: product.price.toString(),
      category: product.category,
      stock: product.stock.toString(),
      image: product.image
    })
    setShowAddProduct(true)
  }

  const handleUpdateProduct = async (e) => {
    e.preventDefault()
    setLoading(true)

    try {
      // Update product in list
      const updatedProducts = products.map(p => 
        p.id === editingProduct.id 
          ? { 
              ...p, 
              ...newProduct, 
              price: parseFloat(newProduct.price), 
              stock: parseInt(newProduct.stock) 
            }
          : p
      )
      
      setProducts(updatedProducts)
      
      // Reset form
      setNewProduct({
        name: '',
        description: '',
        price: '',
        category: '',
        stock: '',
        image: ''
      })
      
      setEditingProduct(null)
      setShowAddProduct(false)
      toast.success('Product updated successfully!')
      
      // TODO: Make API call to backend
      // await updateProduct(editingProduct.id, newProduct)
      
    } catch (error) {
      toast.error('Failed to update product')
      console.error('Update product error:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleDeleteProduct = async (productId) => {
    if (window.confirm('Are you sure you want to delete this product?')) {
      try {
        // Remove from products list
        setProducts(products.filter(p => p.id !== productId))
        toast.success('Product deleted successfully!')
        
        // TODO: Make API call to backend
        // await deleteProduct(productId)
        
      } catch (error) {
        toast.error('Failed to delete product')
        console.error('Delete product error:', error)
      }
    }
  }

  const stats = [
    {
      title: 'Total Products',
      value: products.length,
      icon: FiPackage,
      color: 'bg-blue-500',
      change: '+2 this month'
    },
    {
      title: 'Total Sales',
      value: `$${products.reduce((sum, p) => sum + (p.sales * p.price), 0).toFixed(2)}`,
      icon: FiDollarSign,
      color: 'bg-green-500',
      change: '+15% this month'
    },
    {
      title: 'Total Orders',
      value: products.reduce((sum, p) => sum + p.sales, 0),
      icon: FiShoppingBag,
      color: 'bg-purple-500',
      change: '+8 this month'
    },
    {
      title: 'Average Rating',
      value: products.length > 0 ? (products.reduce((sum, p) => sum + p.rating, 0) / products.length).toFixed(1) : '0.0',
      icon: FiStar,
      color: 'bg-yellow-500',
      change: '+0.2 this month'
    }
  ]

  const categories = [
    'Jewelry', 'Home Decor', 'Accessories', 'Art', 'Clothing', 'Beauty', 'Kitchen', 'Garden'
  ]

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">
                Welcome back, {user?.name}! 🏪
              </h1>
              <p className="text-gray-600 mt-1">Manage your products and track your sales</p>
            </div>
            <button
              onClick={() => {
                setEditingProduct(null)
                setNewProduct({
                  name: '',
                  description: '',
                  price: '',
                  category: '',
                  stock: '',
                  image: ''
                })
                setShowAddProduct(true)
              }}
              className="bg-gradient-to-r from-primary-600 to-artisan-600 text-white px-6 py-3 rounded-lg hover:from-primary-700 hover:to-artisan-700 transition-all duration-200 flex items-center space-x-2 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
            >
              <FiPlus className="w-5 h-5" />
              <span>Add Product</span>
            </button>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {stats.map((stat, index) => (
            <div key={index} className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow duration-200">
              <div className="flex items-center">
                <div className={`p-3 rounded-lg ${stat.color} text-white`}>
                  <stat.icon className="w-6 h-6" />
                </div>
                <div className="ml-4">
                  <p className="text-sm font-medium text-gray-600">{stat.title}</p>
                  <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
                  <p className="text-xs text-green-600 font-medium">{stat.change}</p>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Tabs */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 mb-8">
          <div className="border-b border-gray-200">
            <nav className="flex space-x-8 px-6">
              {[
                { id: 'overview', name: 'Overview', icon: FiTrendingUp },
                { id: 'products', name: 'Products', icon: FiPackage },
                { id: 'orders', name: 'Orders', icon: FiShoppingBag },
                { id: 'analytics', name: 'Analytics', icon: FiUsers }
              ].map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`py-4 px-1 border-b-2 font-medium text-sm flex items-center space-x-2 transition-colors duration-200 ${
                    activeTab === tab.id
                      ? 'border-primary-500 text-primary-600'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                >
                  <tab.icon className="w-4 h-4" />
                  <span>{tab.name}</span>
                </button>
              ))}
            </nav>
          </div>

          {/* Tab Content */}
          <div className="p-6">
            {activeTab === 'overview' && (
              <div className="space-y-6">
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                  {/* Recent Products */}
                  <div className="bg-gray-50 rounded-lg p-6">
                    <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Products</h3>
                    <div className="space-y-3">
                      {products.slice(0, 3).map((product) => (
                        <div key={product.id} className="flex items-center space-x-3 p-3 bg-white rounded-lg">
                          <img src={product.image} alt={product.name} className="w-12 h-12 rounded-lg object-cover" />
                          <div className="flex-1">
                            <p className="font-medium text-gray-900">{product.name}</p>
                            <p className="text-sm text-gray-600">${product.price}</p>
                          </div>
                          <span className={`px-2 py-1 text-xs rounded-full ${
                            product.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                          }`}>
                            {product.status}
                          </span>
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Quick Actions */}
                  <div className="bg-gray-50 rounded-lg p-6">
                    <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h3>
                    <div className="space-y-3">
                      <button className="w-full text-left p-3 bg-white rounded-lg hover:bg-gray-50 transition-colors duration-200">
                        <div className="flex items-center space-x-3">
                          <FiPlus className="w-5 h-5 text-primary-600" />
                          <span className="font-medium text-gray-900">Add New Product</span>
                        </div>
                      </button>
                      <button className="w-full text-left p-3 bg-white rounded-lg hover:bg-gray-50 transition-colors duration-200">
                        <div className="flex items-center space-x-3">
                          <FiTrendingUp className="w-5 h-5 text-green-600" />
                          <span className="font-medium text-gray-900">View Analytics</span>
                        </div>
                      </button>
                      <button className="w-full text-left p-3 bg-white rounded-lg hover:bg-gray-50 transition-colors duration-200">
                        <div className="flex items-center space-x-3">
                          <FiShoppingBag className="w-5 h-5 text-purple-600" />
                          <span className="font-medium text-gray-900">Check Orders</span>
                        </div>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'products' && (
              <div className="space-y-6">
                {/* Products Table */}
                <div className="overflow-x-auto">
                  <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                      <tr>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Product</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Category</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Price</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Stock</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                      </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                      {products.map((product) => (
                        <tr key={product.id} className="hover:bg-gray-50">
                          <td className="px-6 py-4 whitespace-nowrap">
                            <div className="flex items-center">
                              <img src={product.image} alt={product.name} className="w-12 h-12 rounded-lg object-cover" />
                              <div className="ml-4">
                                <div className="text-sm font-medium text-gray-900">{product.name}</div>
                                <div className="text-sm text-gray-500">{product.description.substring(0, 50)}...</div>
                              </div>
                            </div>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{product.category}</td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${product.price}</td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{product.stock}</td>
                          <td className="px-6 py-4 whitespace-nowrap">
                            <span className={`px-2 py-1 text-xs rounded-full ${
                              product.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                            }`}>
                              {product.status}
                            </span>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                            <div className="flex space-x-2">
                              <button
                                onClick={() => handleEditProduct(product)}
                                className="text-primary-600 hover:text-primary-900 p-1 rounded hover:bg-primary-50"
                              >
                                <FiEdit2 className="w-4 h-4" />
                              </button>
                              <button
                                onClick={() => handleDeleteProduct(product.id)}
                                className="text-red-600 hover:text-red-900 p-1 rounded hover:bg-red-50"
                              >
                                <FiTrash2 className="w-4 h-4" />
                              </button>
                            </div>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}

            {activeTab === 'orders' && (
              <div className="text-center py-12">
                <FiShoppingBag className="w-16 h-16 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">No Orders Yet</h3>
                <p className="text-gray-500">Orders will appear here once customers start buying your products.</p>
              </div>
            )}

            {activeTab === 'analytics' && (
              <div className="text-center py-12">
                <FiTrendingUp className="w-16 h-16 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">Analytics Coming Soon</h3>
                <p className="text-gray-500">Detailed analytics and insights will be available here.</p>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Add/Edit Product Modal */}
      {showAddProduct && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6 border-b border-gray-200">
              <div className="flex items-center justify-between">
                <h2 className="text-2xl font-bold text-gray-900">
                  {editingProduct ? 'Edit Product' : 'Add New Product'}
                </h2>
                <button
                  onClick={() => {
                    setShowAddProduct(false)
                    setEditingProduct(null)
                    setNewProduct({
                      name: '',
                      description: '',
                      price: '',
                      category: '',
                      stock: '',
                      image: ''
                    })
                  }}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            </div>

            <form onSubmit={editingProduct ? handleUpdateProduct : handleAddProduct} className="p-6 space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Product Name *</label>
                  <input
                    type="text"
                    value={newProduct.name}
                    onChange={(e) => setNewProduct({...newProduct, name: e.target.value})}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    placeholder="Enter product name"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Category *</label>
                  <select
                    value={newProduct.category}
                    onChange={(e) => setNewProduct({...newProduct, category: e.target.value})}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    required
                  >
                    <option value="">Select category</option>
                    {categories.map((category) => (
                      <option key={category} value={category}>{category}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Price ($) *</label>
                  <input
                    type="number"
                    step="0.01"
                    min="0"
                    value={newProduct.price}
                    onChange={(e) => setNewProduct({...newProduct, price: e.target.value})}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    placeholder="0.00"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Stock Quantity *</label>
                  <input
                    type="number"
                    min="0"
                    value={newProduct.stock}
                    onChange={(e) => setNewProduct({...newProduct, stock: e.target.value})}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                    placeholder="0"
                    required
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Product Image URL *</label>
                <input
                  type="url"
                  value={newProduct.image}
                  onChange={(e) => setNewProduct({...newProduct, image: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                  placeholder="https://example.com/image.jpg"
                  required
                />
                {newProduct.image && (
                  <div className="mt-2">
                    <img src={newProduct.image} alt="Preview" className="w-24 h-24 object-cover rounded-lg border" />
                  </div>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Description *</label>
                <textarea
                  value={newProduct.description}
                  onChange={(e) => setNewProduct({...newProduct, description: e.target.value})}
                  rows={4}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                  placeholder="Describe your product in detail..."
                  required
                />
              </div>

              <div className="flex justify-end space-x-3 pt-4">
                <button
                  type="button"
                  onClick={() => {
                    setShowAddProduct(false)
                    setEditingProduct(null)
                    setNewProduct({
                      name: '',
                      description: '',
                      price: '',
                      category: '',
                      stock: '',
                      image: ''
                    })
                  }}
                  className="px-6 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors duration-200"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={loading}
                  className="px-6 py-2 bg-gradient-to-r from-primary-600 to-artisan-600 text-white rounded-lg hover:from-primary-700 hover:to-artisan-700 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center space-x-2"
                >
                  {loading ? (
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                  ) : (
                    <>
                      <FiUpload className="w-4 h-4" />
                      <span>{editingProduct ? 'Update Product' : 'Add Product'}</span>
                    </>
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}

export default VendorDashboard
