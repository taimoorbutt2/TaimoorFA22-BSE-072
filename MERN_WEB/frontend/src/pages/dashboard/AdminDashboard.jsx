import React, { useState, useEffect } from 'react'
import { useAuth } from '../../contexts/AuthContext'
import { FiUsers, FiShoppingBag, FiDollarSign, FiTrendingUp, FiSettings, FiShield, FiRefreshCw, FiEye, FiEdit, FiTrash2 } from 'react-icons/fi'

const AdminDashboard = () => {
  const { user } = useAuth()
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalProducts: 0,
    totalSales: 0,
    pendingApprovals: 0
  })
  const [users, setUsers] = useState([])
  const [products, setProducts] = useState([])
  const [orders, setOrders] = useState([])
  const [activeTab, setActiveTab] = useState('overview')
  const [userSearch, setUserSearch] = useState('')
  const [productSearch, setProductSearch] = useState('')

  // Basic functionality functions
  const fetchStats = async () => {
    try {
      // For now, we'll use placeholder data
      setStats({
        totalUsers: 25,
        totalProducts: 150,
        totalSales: 12500.50,
        pendingApprovals: 8
      })
    } catch (error) {
      console.error('Error fetching stats:', error)
    }
  }

  const fetchUsers = async () => {
    try {
      // For now, we'll use placeholder data
      setUsers([
        { _id: '1', name: 'John Doe', email: 'john@example.com', role: 'customer', createdAt: new Date() },
        { _id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'vendor', createdAt: new Date() },
        { _id: '3', name: 'Admin User', email: 'admin@example.com', role: 'admin', createdAt: new Date() }
      ])
    } catch (error) {
      console.error('Error fetching users:', error)
    }
  }

  const fetchProducts = async () => {
    try {
      // For now, we'll use placeholder data
      setProducts([
        { _id: '1', name: 'Handcrafted Necklace', category: 'Jewelry', price: 89.99, vendorName: 'Jane Smith', isActive: true, isFeatured: false, images: ['https://via.placeholder.com/150'] },
        { _id: '2', name: 'Ceramic Vase', category: 'Home Decor', price: 45.50, vendorName: 'Jane Smith', isActive: true, isFeatured: true, images: ['https://via.placeholder.com/150'] }
      ])
    } catch (error) {
      console.error('Error fetching products:', error)
    }
  }

  const fetchOrders = async () => {
    try {
      // For now, we'll use placeholder data
      setOrders([
        { _id: '1', customerName: 'John Doe', totalAmount: 89.99, status: 'completed', createdAt: new Date() },
        { _id: '2', customerName: 'Alice Johnson', totalAmount: 45.50, status: 'pending', createdAt: new Date() }
      ])
    } catch (error) {
      console.error('Error fetching orders:', error)
    }
  }

  // Initialize dashboard
  useEffect(() => {
    const initializeDashboard = async () => {
      setLoading(true)
      await Promise.all([fetchStats(), fetchUsers(), fetchProducts(), fetchOrders()])
      setLoading(false)
    }
    
    initializeDashboard()
  }, [])

  // Filtered data
  const filteredUsers = users.filter(user => 
    user.name?.toLowerCase().includes(userSearch.toLowerCase()) ||
    user.email?.toLowerCase().includes(userSearch.toLowerCase()) ||
    user.role?.toLowerCase().includes(userSearch.toLowerCase())
  )

  const filteredProducts = products.filter(product =>
    product.name?.toLowerCase().includes(productSearch.toLowerCase()) ||
    product.category?.toLowerCase().includes(productSearch.toLowerCase()) ||
    product.vendorName?.toLowerCase().includes(productSearch.toLowerCase())
  )

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading admin dashboard...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Welcome back, {user?.name}! 👑</h1>
          <p className="text-gray-600">Admin dashboard for ArtisanMart platform management</p>
        </div>

        {/* Navigation Tabs */}
        <div className="mb-6">
          <nav className="flex space-x-8">
            {[
              { id: 'overview', label: 'Overview', icon: FiTrendingUp },
              { id: 'users', label: 'Users', icon: FiUsers },
              { id: 'products', label: 'Products', icon: FiShoppingBag },
              { id: 'orders', label: 'Orders', icon: FiDollarSign },
              { id: 'settings', label: 'Settings', icon: FiSettings }
            ].map(({ id, label, icon: Icon }) => (
              <button
                key={id}
                onClick={() => setActiveTab(id)}
                className={`flex items-center space-x-2 px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                  activeTab === id
                    ? 'bg-blue-100 text-blue-700 border-b-2 border-blue-700'
                    : 'text-gray-500 hover:text-gray-700 hover:bg-gray-100'
                }`}
              >
                <Icon className="w-4 h-4" />
                <span>{label}</span>
              </button>
            ))}
          </nav>
        </div>

        {/* Overview Tab */}
        {activeTab === 'overview' && (
          <>
            {/* Stats Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
              <div className="bg-white rounded-lg shadow p-6 border-l-4 border-blue-500">
                <div className="flex items-center">
                  <div className="p-3 rounded-full bg-blue-100 text-blue-600">
                    <FiUsers className="w-6 h-6" />
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Total Users</p>
                    <p className="text-2xl font-semibold text-gray-900">{stats.totalUsers}</p>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-lg shadow p-6 border-l-4 border-green-500">
                <div className="flex items-center">
                  <div className="p-3 rounded-full bg-green-100 text-green-600">
                    <FiShoppingBag className="w-6 h-6" />
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Total Products</p>
                    <p className="text-2xl font-semibold text-gray-900">{stats.totalProducts}</p>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-lg shadow p-6 border-l-4 border-purple-500">
                <div className="flex items-center">
                  <div className="p-3 rounded-full bg-purple-100 text-purple-600">
                    <FiDollarSign className="w-6 h-6" />
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Total Sales</p>
                    <p className="text-2xl font-semibold text-gray-900">${stats.totalSales.toFixed(2)}</p>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-lg shadow p-6 border-l-4 border-orange-500">
                <div className="flex items-center">
                  <div className="p-3 rounded-full bg-orange-100 text-orange-600">
                    <FiTrendingUp className="w-6 h-6" />
                  </div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Pending Approvals</p>
                    <p className="text-2xl font-semibold text-gray-900">{stats.pendingApprovals}</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Main Content Grid */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
              {/* Admin Info */}
              <div className="bg-white rounded-lg shadow">
                <div className="px-6 py-4 border-b border-gray-200">
                  <h3 className="text-lg font-medium text-gray-900 flex items-center">
                    <FiShield className="w-5 h-5 mr-2 text-blue-600" />
                    Admin Information
                  </h3>
                </div>
                <div className="p-6 space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Name</label>
                    <p className="mt-1 text-sm text-gray-900">{user?.name}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Email</label>
                    <p className="mt-1 text-sm text-gray-900">{user?.email}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Role</label>
                    <p className="mt-1 text-sm text-gray-900 capitalize">{user?.role}</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Status</label>
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                      Active
                    </span>
                  </div>
                </div>
              </div>

              
            </div>
          </>
        )}

        {/* Users Tab */}
        {activeTab === 'users' && (
          <div className="bg-white rounded-lg shadow">
            <div className="px-6 py-4 border-b border-gray-200">
              <h3 className="text-lg font-medium text-gray-900">User Management</h3>
              <div className="mt-4 flex space-x-4">
                <input
                  type="text"
                  placeholder="Search users by name, email, or role..."
                  value={userSearch}
                  onChange={(e) => setUserSearch(e.target.value)}
                  className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
                <button
                  onClick={fetchUsers}
                  className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors flex items-center space-x-2"
                >
                  <FiRefreshCw className="w-4 h-4" />
                  <span>Refresh</span>
                </button>
              </div>
              {/* Debug info */}
              <div className="mt-2 text-sm text-gray-500">
                Debug: Users count: {users.length}, Filtered: {filteredUsers.length}, Search: "{userSearch}"
              </div>
            </div>
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Joined</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {filteredUsers.length === 0 ? (
                    <tr>
                      <td colSpan="5" className="px-6 py-4 text-center text-gray-500">
                        {userSearch ? 'No users found matching your search.' : 'No users available.'}
                      </td>
                    </tr>
                  ) : (
                    filteredUsers.map((user) => (
                      <tr key={user._id} className="hover:bg-gray-50">
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="flex items-center">
                            <div className="flex-shrink-0 h-10 w-10">
                              <div className="h-10 w-10 rounded-full bg-blue-100 flex items-center justify-center">
                                <span className="text-blue-600 font-medium text-sm">
                                  {user.name?.charAt(0)?.toUpperCase() || 'U'}
                                </span>
                              </div>
                            </div>
                            <div className="ml-4">
                              <div className="text-sm font-medium text-gray-900">{user.name || 'Unknown User'}</div>
                              <div className="text-sm text-gray-500">{user.email || 'No email'}</div>
                            </div>
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                            user.role === 'admin' ? 'bg-red-100 text-red-800' :
                            user.role === 'vendor' ? 'bg-blue-100 text-blue-800' :
                            'bg-green-100 text-green-800'
                          }`}>
                            {user.role || 'customer'}
                          </span>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                            Active
                          </span>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {user.createdAt ? new Date(user.createdAt).toLocaleDateString() : 'Unknown'}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                          <div className="flex space-x-2">
                            <button 
                              className="text-blue-600 hover:text-blue-900 p-1 rounded hover:bg-blue-50 transition-colors"
                              title="View User Details"
                            >
                              <FiEye className="w-4 h-4" />
                            </button>
                            <button 
                              className="text-green-600 hover:text-green-900 p-1 rounded hover:bg-green-50 transition-colors"
                              title="Edit User"
                            >
                              <FiEdit className="w-4 h-4" />
                            </button>
                            {user.role !== 'admin' && (
                              <button 
                                className="text-red-600 hover:text-red-900 p-1 rounded hover:bg-red-50 transition-colors"
                                title="Delete User"
                                onClick={() => {
                                  if (window.confirm(`Are you sure you want to delete ${user.name || 'this user'}? This action cannot be undone.`)) {
                                    // Handle user deletion
                                    console.log('Delete user:', user._id)
                                  }
                                }}
                              >
                                <FiTrash2 className="w-4 h-4" />
                              </button>
                            )}
                          </div>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
            <div className="px-6 py-4 border-t border-gray-200">
              <div className="flex items-center justify-between">
                <div className="text-sm text-gray-700">
                  Showing <span className="font-medium">{filteredUsers.length}</span> of{' '}
                  <span className="font-medium">{users.length}</span> users
                </div>
                <div className="text-sm text-gray-500">
                  {userSearch && `Filtered by: "${userSearch}"`}
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

export default AdminDashboard
