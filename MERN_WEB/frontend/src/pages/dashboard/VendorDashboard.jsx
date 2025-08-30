import React, { useState, useEffect } from 'react';
import { 
  FiPackage, FiPlus, FiEdit2, FiTrash2, FiEye, FiTrendingUp, 
  FiShoppingBag, FiDollarSign, FiStar, FiUsers, FiSettings, 
  FiImage, FiTag, FiMapPin, FiClock, FiAward, FiShare2, FiBarChart,
  FiMessageCircle
} from 'react-icons/fi';
import { toast } from 'react-hot-toast';
import api from '../../utils/api';
import ChatInbox from '../../components/dashboard/ChatInbox';

const VendorDashboard = () => {
  const [activeTab, setActiveTab] = useState('overview');
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [showAddProduct, setShowAddProduct] = useState(false);
  const [showEditProduct, setShowEditProduct] = useState(false);
  const [editingProduct, setEditingProduct] = useState(null);
  const [vendorProfile, setVendorProfile] = useState(null);
  const [showProfileModal, setShowProfileModal] = useState(false);
  const [unreadCount, setUnreadCount] = useState(0);

  // Form states
  const [productForm, setProductForm] = useState({
    name: '',
    description: '',
    price: '',
    category: '',
    stock: '',
    tags: '',
    materials: '',
    careInstructions: '',
    dimensions: { length: '', width: '', height: '', unit: 'cm' },
    weight: { value: '', unit: 'g' },
    shippingInfo: { weight: '', dimensions: '', shippingClass: '' }
  });

  const [profileForm, setProfileForm] = useState({
    shopName: '',
    bio: '',
    tagline: '',
    specialties: '',
    location: { address: '' },
    experience: { years: '', description: '' },
    contactInfo: { phone: '', address: '' }
  });

  // Product categories
  const categories = [
    'Jewelry', 'Home Decor', 'Art & Prints', 'Clothing', 'Pottery', 
    'Textiles', 'Bath & Body', 'Leather', 'Glass', 'Metalwork', 
    'Kitchen', 'Garden', 'Beauty', 'Accessories'
  ];

  // Helper function to render character counter
  const renderCharacterCounter = (text, maxLength, fieldName) => {
    const currentLength = text.length;
    const wordCount = Math.ceil(currentLength / 5);
    const isNearLimit = currentLength > (maxLength * 0.8);
    
    return (
      <div className="mt-1 flex justify-between items-center">
        <p className="text-xs text-gray-500">
          {currentLength}/{maxLength} characters
        </p>
        <p className="text-xs text-gray-500">
          ~{wordCount} words
        </p>
        {isNearLimit && (
          <p className="text-xs text-orange-600">
            ⚠️ {fieldName} is getting long
          </p>
        )}
      </div>
    );
  };

  useEffect(() => {
    fetchProducts();
    fetchVendorProfile();
    fetchUnreadCount();
  }, []);

  const fetchProducts = async () => {
    try {
      setLoading(true);
      const response = await api.get('/products/vendor/me');
      setProducts(response.data.products || []);
    } catch (error) {
      console.error('Error fetching products:', error);
      toast.error('Failed to fetch products');
    } finally {
      setLoading(false);
    }
  };

  const fetchVendorProfile = async () => {
    try {
      const response = await api.get('/vendors/profile/me');
      setVendorProfile(response.data.profile);
      // Pre-fill profile form
      if (response.data.profile) {
        const profile = response.data.profile;
        setProfileForm({
          shopName: profile.shopName || '',
          bio: profile.bio || '',
          tagline: profile.tagline || '',
          specialties: profile.specialties?.join(', ') || '',
          location: profile.location || { address: '' },
          experience: profile.experience || { years: '', description: '' },
          contactInfo: profile.contactInfo || { phone: '', address: '' }
        });
      }
    } catch (error) {
      console.error('Error fetching vendor profile:', error);
      // If profile doesn't exist, set default values
      if (error.response?.status === 404) {
        setVendorProfile(null);
        setProfileForm({
          shopName: '',
          bio: '',
          tagline: '',
          specialties: '',
          location: { address: '' },
          experience: { years: '', description: '' },
          contactInfo: { phone: '', address: '' }
        });
      }
    }
  };

  const fetchUnreadCount = async () => {
    try {
      const response = await fetch('/api/chat/unread-count', {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      
      if (response.ok) {
        const data = await response.json();
        setUnreadCount(data.unreadCount);
      }
    } catch (error) {
      console.error('Error fetching unread count:', error);
    }
  };

  const handleAddProduct = async (e) => {
    e.preventDefault();
    
    try {
      setLoading(true);
      
      const formData = new FormData();
      Object.keys(productForm).forEach(key => {
        if (productForm[key] !== '') {
          if (typeof productForm[key] === 'object') {
            // Handle nested objects like dimensions and weight
            const objValue = productForm[key];
            // Only send if the object has meaningful values
            if (objValue && Object.values(objValue).some(val => val !== '' && val !== null)) {
              formData.append(key, JSON.stringify(objValue));
            }
          } else {
            formData.append(key, productForm[key]);
          }
        }
      });

      // Debug: Log what's being sent
      console.log('Form data being sent:');
      for (let [key, value] of formData.entries()) {
        console.log(`${key}:`, value);
      }

      // Add image files if selected
      const imageInput = document.getElementById('product-images');
      console.log('Image input files:', imageInput.files);
      if (imageInput.files.length > 0) {
        Array.from(imageInput.files).forEach((file, index) => {
          console.log(`Adding image ${index}:`, file.name, file.type, file.size);
          formData.append('images', file);
        });
      } else {
        // Images are required
        toast.error('Please select at least one product image');
        setLoading(false);
        return;
      }

      // Validate required fields
      if (!productForm.name || !productForm.description || !productForm.price || !productForm.category) {
        toast.error('Please fill in all required fields (name, description, price, category)');
        setLoading(false);
        return;
      }

      // Validate description length
      if (productForm.description.length > 1000) {
        toast.error('Description is too long. Maximum 1000 characters allowed.');
        setLoading(false);
        return;
      }

      // Validate care instructions length
      if (productForm.careInstructions && productForm.careInstructions.length > 500) {
        toast.error('Care instructions are too long. Maximum 500 characters allowed.');
        setLoading(false);
        return;
      }

      // Show current character counts
      const descCount = productForm.description.length;
      const careCount = productForm.careInstructions?.length || 0;
      
      if (descCount > 800 || careCount > 400) {
        toast.info(`Current: Description ${descCount}/1000, Care ${careCount}/500 characters`);
      }

      // Show character count info before submission
      console.log('Submitting product with:');
      console.log('- Description:', productForm.description.length, 'characters');
      console.log('- Care Instructions:', productForm.careInstructions?.length || 0, 'characters');
      
      // Show user-friendly character count info
      if (productForm.description.length > 800) {
        toast.info(`Description: ${productForm.description.length}/1000 characters`);
      }
      if (productForm.careInstructions && productForm.careInstructions.length > 400) {
        toast.info(`Care Instructions: ${productForm.careInstructions.length}/500 characters`);
      }

      const response = await api.post('/products', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });

      toast.success('Product added successfully!');
      setShowAddProduct(false);
      resetProductForm();
      fetchProducts();
      
    } catch (error) {
      console.error('Error adding product:', error);
      toast.error(error.response?.data?.message || 'Failed to add product');
    } finally {
      setLoading(false);
    }
  };

  const handleEditProduct = async (e) => {
    e.preventDefault();
    
    try {
      setLoading(true);
      
      const formData = new FormData();
      Object.keys(productForm).forEach(key => {
        if (productForm[key] !== '') {
          if (typeof productForm[key] === 'object') {
            // Handle nested objects like dimensions and weight
            formData.append(key, JSON.stringify(productForm[key]));
          } else {
            formData.append(key, productForm[key]);
          }
        }
      });

      // Add image files if new ones selected
      const imageInput = document.getElementById('edit-product-images');
      if (imageInput.files.length > 0) {
        Array.from(imageInput.files).forEach(file => {
          formData.append('images', file);
        });
      }

      const response = await api.put(`/products/${editingProduct._id}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });

      toast.success('Product updated successfully!');
      setShowEditProduct(false);
      setEditingProduct(null);
      resetProductForm();
      fetchProducts();
      
    } catch (error) {
      console.error('Error updating product:', error);
      toast.error(error.response?.data?.message || 'Failed to update product');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteProduct = async (productId) => {
    if (!window.confirm('Are you sure you want to delete this product?')) return;
    
    try {
      await api.delete(`/products/${productId}`);
      toast.success('Product deleted successfully!');
      fetchProducts();
    } catch (error) {
      console.error('Error deleting product:', error);
      toast.error('Failed to delete product');
    }
  };

  const handleUpdateProfile = async (e) => {
    e.preventDefault();
    
    try {
      setLoading(true);
      
      const formData = new FormData();
      Object.keys(profileForm).forEach(key => {
        if (profileForm[key] !== '') {
          if (typeof profileForm[key] === 'object') {
            formData.append(key, JSON.stringify(profileForm[key]));
          } else {
            formData.append(key, profileForm[key]);
          }
        }
      });

      // Add profile image if selected
      const imageInput = document.getElementById('profile-image');
      if (imageInput.files.length > 0) {
        formData.append('profileImage', imageInput.files[0]);
      }

      // Add banner image if selected
      const bannerInput = document.getElementById('banner-image');
      if (bannerInput.files.length > 0) {
        formData.append('bannerImage', bannerInput.files[0]);
      }

      // Debug logging
      console.log('Profile form data:', profileForm);
      console.log('FormData entries:');
      for (let [key, value] of formData.entries()) {
        console.log(key, value);
      }

      let response;
      if (vendorProfile) {
        // Update existing profile
        console.log('Updating existing profile...');
        response = await api.put('/vendors/profile/me', formData, {
          headers: { 'Content-Type': 'multipart/form-data' }
        });
        toast.success('Profile updated successfully!');
      } else {
        // Create new profile
        console.log('Creating new profile...');
        response = await api.post('/vendors/profile', formData, {
          headers: { 'Content-Type': 'multipart/form-data' }
        });
        toast.success('Profile created successfully!');
      }

      console.log('Response:', response);
      setShowProfileModal(false);
      fetchVendorProfile();
      
    } catch (error) {
      console.error('Error updating profile:', error);
      console.error('Error response:', error.response);
      console.error('Error message:', error.message);
      toast.error(error.response?.data?.message || 'Failed to update profile');
    } finally {
      setLoading(false);
    }
  };

  const resetProductForm = () => {
    setProductForm({
      name: '',
      description: '',
      price: '',
      category: '',
      stock: '',
      tags: '',
      materials: '',
      careInstructions: '',
      dimensions: { length: '', width: '', height: '', unit: 'cm' },
      weight: { value: '', unit: 'g' },
      shippingInfo: { weight: '', dimensions: '', shippingClass: '' }
    });
  };

  const openEditProduct = (product) => {
    setEditingProduct(product);
    setProductForm({
      name: product.name,
      description: product.description,
      price: product.price.toString(),
      category: product.category,
      stock: product.stock.toString(),
      tags: product.tags?.join(', ') || '',
      materials: product.materials?.join(', ') || '',
      careInstructions: product.careInstructions || '',
      dimensions: product.dimensions || { length: '', width: '', height: '', unit: 'cm' },
      weight: product.weight || { value: '', unit: 'g' },
      shippingInfo: product.shippingInfo || { weight: '', dimensions: '', shippingClass: '' }
    });
    setShowEditProduct(true);
  };

  const stats = [
    { title: 'Total Products', value: products.length, icon: FiPackage, color: 'blue' },
    { title: 'Total Sales', value: '$0', icon: FiDollarSign, color: 'green' },
    { title: 'Total Orders', value: '0', icon: FiShoppingBag, color: 'purple' },
    { title: 'Average Rating', value: '0.0', icon: FiStar, color: 'yellow' }
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
      {/* Header */}
      <div className="bg-white shadow-lg border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Vendor Dashboard</h1>
              <p className="text-gray-600 mt-1">Manage your products and profile</p>
              {vendorProfile ? (
                <div className="mt-2 flex items-center space-x-2">
                  <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                  <span className="text-sm text-green-600 font-medium">Profile Complete</span>
                </div>
              ) : (
                <div className="mt-2 flex items-center space-x-2">
                  <div className="w-2 h-2 bg-yellow-500 rounded-full"></div>
                  <span className="text-sm text-yellow-600 font-medium">Profile Incomplete</span>
                </div>
              )}
            </div>
                         <div className="flex items-center space-x-3">
                               {/* Profile Photo Preview */}
                {vendorProfile?.profileImage && (
                  <div className="flex items-center space-x-3 bg-gradient-to-r from-primary-50 to-purple-50 rounded-lg px-4 py-2 border border-primary-100 shadow-sm">
                    <img
                      src={vendorProfile.profileImage}
                      alt="Profile"
                      className="w-12 h-12 rounded-full object-cover border-2 border-white shadow-sm"
                      onError={(e) => {
                        console.error('Dashboard profile image failed to load:', vendorProfile.profileImage);
                        e.target.style.display = 'none';
                      }}
                    />
                    <div className="text-left">
                      <p className="text-sm font-medium text-gray-900">{vendorProfile.shopName}</p>
                      <p className="text-xs text-gray-600">{vendorProfile.tagline || 'Vendor'}</p>
                    </div>
                  </div>
                )}
                
                {/* Banner Image Preview */}
                {vendorProfile?.bannerImage && (
                  <div className="flex items-center space-x-3 bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg px-4 py-2 border border-blue-100 shadow-sm">
                    <img
                      src={vendorProfile.bannerImage}
                      alt="Banner"
                      className="w-16 h-8 rounded object-cover border border-blue-200 shadow-sm"
                      onError={(e) => {
                        console.error('Dashboard banner image failed to load:', vendorProfile.bannerImage);
                        e.target.style.display = 'none';
                      }}
                    />
                    <div className="text-left">
                      <p className="text-xs font-medium text-gray-900">Banner Set</p>
                      <p className="text-xs text-gray-600">Profile enhanced</p>
                    </div>
                  </div>
                )}
               
                               <button
                  onClick={() => setShowAddProduct(true)}
                  className="bg-gradient-to-r from-primary-600 to-purple-600 text-white px-6 py-3 rounded-xl hover:from-primary-700 hover:to-purple-700 transform hover:scale-105 transition-all duration-200 shadow-lg flex items-center space-x-2 font-semibold"
                >
                  <FiPlus className="w-5 h-5" />
                  <span>Add Product</span>
                </button>
                <button
                  onClick={() => setShowProfileModal(true)}
                  className="bg-gradient-to-r from-gray-600 to-gray-700 text-white px-6 py-3 rounded-xl hover:from-gray-700 hover:to-gray-800 transform hover:scale-105 transition-all duration-200 shadow-lg flex items-center space-x-2 font-semibold"
                >
                  <FiSettings className="w-5 h-5" />
                  <span>{vendorProfile ? 'Edit Profile' : 'Create Profile'}</span>
                </button>
             </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {stats.map((stat, index) => (
            <div key={index} className="bg-white rounded-2xl shadow-xl p-6 hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-1">
              <div className="flex items-center">
                <div className={`p-3 rounded-xl bg-gradient-to-r from-${stat.color}-100 to-${stat.color}-200`}>
                  <stat.icon className={`w-6 h-6 text-${stat.color}-600`} />
                </div>
                <div className="ml-4">
                  <p className="text-sm font-medium text-gray-600">{stat.title}</p>
                  <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Tabs */}
        <div className="bg-white rounded-2xl shadow-xl overflow-hidden">
          <div className="border-b border-gray-200">
            <nav className="-mb-px flex space-x-8 px-6">
              {[
                { id: 'overview', label: 'Overview', icon: FiTrendingUp },
                { id: 'products', label: 'Products', icon: FiPackage },
                { id: 'orders', label: 'Orders', icon: FiShoppingBag },
                { 
                  id: 'messages', 
                  label: 'Messages', 
                  icon: FiMessageCircle,
                  badge: unreadCount > 0 ? unreadCount : null
                },
                { id: 'analytics', label: 'Analytics', icon: FiBarChart }
              ].map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`py-4 px-1 border-b-2 font-medium text-sm flex items-center space-x-2 ${
                    activeTab === tab.id
                      ? 'border-primary-500 text-primary-600'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                >
                  <tab.icon className="w-4 h-4" />
                  <span>{tab.label}</span>
                  {tab.badge && (
                    <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                      {tab.badge}
                    </span>
                  )}
                </button>
              ))}
            </nav>
          </div>

          {/* Tab Content */}
          <div className="p-6">
            {activeTab === 'overview' && (
              <div className="space-y-6">
                <h3 className="text-lg font-medium text-gray-900">Recent Activity</h3>
                <div className="bg-gray-50 rounded-lg p-4">
                  <p className="text-gray-600">No recent activity to display.</p>
                </div>
              </div>
            )}

            {activeTab === 'products' && (
              <div className="space-y-6">
                <div className="flex items-center justify-between">
                  <h3 className="text-lg font-medium text-gray-900">Your Products</h3>
                  <span className="text-sm text-gray-500">{products.length} products</span>
                </div>
                
                {loading ? (
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {[1, 2, 3].map((i) => (
                      <div key={i} className="bg-gray-200 rounded-lg h-64 animate-pulse"></div>
                    ))}
                  </div>
                ) : products.length === 0 ? (
                  <div className="text-center py-12">
                    <FiPackage className="mx-auto h-12 w-12 text-gray-400" />
                    <h3 className="mt-2 text-sm font-medium text-gray-900">No products</h3>
                    <p className="mt-1 text-sm text-gray-500">Get started by adding your first product.</p>
                    <div className="mt-6">
                      <button
                        onClick={() => setShowAddProduct(true)}
                        className="bg-primary-600 text-white px-4 py-2 rounded-lg hover:bg-primary-700"
                      >
                        Add Product
                      </button>
                    </div>
                  </div>
                ) : (
                                     <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                     {products.map((product) => (
                       <div key={product._id} className="bg-white border border-gray-200 rounded-2xl overflow-hidden hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1">
                                                 <div className="aspect-w-16 aspect-h-9 bg-gray-200">
                           {product.images && product.images[0] ? (
                             <img
                               src={product.images[0]}
                               alt={product.name}
                               className="w-full h-48 object-cover"
                               onError={(e) => {
                                 console.error('Product image failed to load:', product.images[0]);
                                 e.target.style.display = 'none';
                                 e.target.nextSibling.style.display = 'flex';
                               }}
                             />
                           ) : (
                             <div className="w-full h-48 bg-gray-200 flex items-center justify-center">
                               <FiImage className="w-12 h-12 text-gray-400" />
                             </div>
                           )}
                           {/* Fallback for failed images */}
                           <div className="w-full h-48 bg-gray-200 flex items-center justify-center" style={{ display: 'none' }}>
                             <FiImage className="w-12 h-12 text-gray-400" />
                           </div>
                         </div>
                        <div className="p-4">
                          <h4 className="font-medium text-gray-900 truncate">{product.name}</h4>
                          <p className="text-sm text-gray-500 mt-1">{product.category}</p>
                          <p className="text-lg font-semibold text-primary-600 mt-2">${product.price}</p>
                          <p className="text-sm text-gray-500 mt-1">Stock: {product.stock}</p>
                          <div className="mt-4 flex space-x-2">
                            <button
                              onClick={() => openEditProduct(product)}
                              className="flex-1 bg-gray-100 text-gray-700 px-3 py-2 rounded text-sm hover:bg-gray-200 flex items-center justify-center space-x-1"
                            >
                              <FiEdit2 className="w-4 h-4" />
                              <span>Edit</span>
                            </button>
                            <button
                              onClick={() => handleDeleteProduct(product._id)}
                              className="flex-1 bg-red-100 text-red-700 px-3 py-2 rounded text-sm hover:bg-red-200 flex items-center justify-center space-x-1"
                            >
                              <FiTrash2 className="w-4 h-4" />
                              <span>Delete</span>
                            </button>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}

            {activeTab === 'orders' && (
              <div className="space-y-6">
                <h3 className="text-lg font-medium text-gray-900">Recent Orders</h3>
                <div className="bg-gray-50 rounded-lg p-4">
                  <p className="text-gray-600">No orders to display.</p>
                </div>
              </div>
            )}

            {activeTab === 'messages' && (
              <div className="space-y-6">
                <h3 className="text-lg font-medium text-gray-900">Customer Messages</h3>
                <ChatInbox />
              </div>
            )}

            {activeTab === 'analytics' && (
              <div className="space-y-6">
                <h3 className="text-lg font-medium text-gray-900">Analytics</h3>
                <div className="bg-gray-50 rounded-lg p-4">
                  <p className="text-gray-600">Analytics dashboard coming soon.</p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Add Product Modal */}
      {showAddProduct && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">Add New Product</h3>
              <form onSubmit={handleAddProduct} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">Product Name</label>
                  <input
                    type="text"
                    value={productForm.name}
                    onChange={(e) => setProductForm({...productForm, name: e.target.value})}
                    className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">Description</label>
                  <textarea
                    value={productForm.description}
                    onChange={(e) => setProductForm({...productForm, description: e.target.value})}
                    rows={3}
                    maxLength={1000}
                    placeholder="Describe your product in detail (max 1000 characters)"
                    className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                    required
                  />
                  <div className="mt-1 text-xs text-gray-500">
                    {productForm.description.length}/1000 characters
                    {productForm.description.length > 800 && (
                      <span className="text-orange-600 ml-2">⚠️ Getting long</span>
                    )}
                  </div>
                </div>
                
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Price</label>
                    <input
                      type="number"
                      step="0.01"
                      value={productForm.price}
                      onChange={(e) => setProductForm({...productForm, price: e.target.value})}
                      className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Stock</label>
                    <input
                      type="number"
                      value={productForm.stock}
                      onChange={(e) => setProductForm({...productForm, stock: e.target.value})}
                      className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                      required
                    />
                  </div>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">Category</label>
                  <select
                    value={productForm.category}
                    onChange={(e) => setProductForm({...productForm, category: e.target.value})}
                    className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                    required
                  >
                    <option value="">Select category</option>
                    {categories.map((category) => (
                      <option key={category} value={category}>{category}</option>
                    ))}
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">Images</label>
                  <input
                    type="file"
                    id="product-images"
                    multiple
                    accept="image/*"
                    className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                  />
                </div>

                {/* Additional Product Details */}
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Tags</label>
                    <input
                      type="text"
                      value={productForm.tags}
                      onChange={(e) => setProductForm({...productForm, tags: e.target.value})}
                      placeholder="handmade, artisan, unique"
                      className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                    />
                    <p className="mt-1 text-xs text-gray-500">Separate tags with commas</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Materials</label>
                    <input
                      type="text"
                      value={productForm.materials}
                      onChange={(e) => setProductForm({...productForm, materials: e.target.value})}
                      placeholder="cotton, wood, metal"
                      className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                    />
                    <p className="mt-1 text-xs text-gray-500">Separate materials with commas</p>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700">Care Instructions</label>
                  <textarea
                    value={productForm.careInstructions}
                    onChange={(e) => setProductForm({...productForm, careInstructions: e.target.value})}
                    rows={2}
                    placeholder="How to care for this product..."
                    className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                  />
                </div>

                {/* Dimensions */}
                <div>
                  <label className="block text-sm font-medium text-gray-700">Dimensions</label>
                  <div className="grid grid-cols-4 gap-2">
                    <div>
                      <label className="block text-xs text-gray-600">Length</label>
                      <input
                        type="number"
                        step="0.1"
                        value={productForm.dimensions.length}
                        onChange={(e) => setProductForm({
                          ...productForm, 
                          dimensions: { ...productForm.dimensions, length: e.target.value }
                        })}
                        placeholder="10"
                        className="mt-1 block w-full border border-gray-300 rounded-md px-2 py-2 text-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                      />
                    </div>
                    <div>
                      <label className="block text-xs text-gray-600">Width</label>
                      <input
                        type="number"
                        step="0.1"
                        value={productForm.dimensions.width}
                        onChange={(e) => setProductForm({
                          ...productForm, 
                          dimensions: { ...productForm.dimensions, width: e.target.value }
                        })}
                        placeholder="5"
                        className="mt-1 block w-full border border-gray-300 rounded-md px-2 py-2 text-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                      />
                    </div>
                    <div>
                      <label className="block text-xs text-gray-600">Height</label>
                      <input
                        type="number"
                        step="0.1"
                        value={productForm.dimensions.height}
                        onChange={(e) => setProductForm({
                          ...productForm, 
                          dimensions: { ...productForm.dimensions, height: e.target.value }
                        })}
                        placeholder="3"
                        className="mt-1 block w-full border border-gray-300 rounded-md px-2 py-2 text-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                      />
                    </div>
                    <div>
                      <label className="block text-xs text-gray-600">Unit</label>
                      <select
                        value={productForm.dimensions.unit}
                        onChange={(e) => setProductForm({
                          ...productForm, 
                          dimensions: { ...productForm.dimensions, unit: e.target.value }
                        })}
                        className="mt-1 block w-full border border-gray-300 rounded-md px-2 py-2 text-sm focus:outline-none focus:ring-primary-500 focus:ring-primary-500 focus:border-primary-500"
                      >
                        <option value="cm">cm</option>
                        <option value="inch">inch</option>
                        <option value="mm">mm</option>
                      </select>
                    </div>
                  </div>
                </div>

                {/* Weight */}
                <div>
                  <label className="block text-sm font-medium text-gray-700">Weight</label>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-xs text-gray-600">Value</label>
                      <input
                        type="number"
                        step="0.1"
                        value={productForm.weight.value}
                        onChange={(e) => setProductForm({
                          ...productForm, 
                          weight: { ...productForm.weight, value: e.target.value }
                        })}
                        placeholder="500"
                        className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                      />
                    </div>
                    <div>
                      <label className="block text-xs text-gray-600">Unit</label>
                      <select
                        value={productForm.weight.unit}
                        onChange={(e) => setProductForm({
                          ...productForm, 
                          weight: { ...productForm.weight, unit: e.target.value }
                        })}
                        className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                      >
                        <option value="g">grams (g)</option>
                        <option value="kg">kilograms (kg)</option>
                        <option value="lb">pounds (lb)</option>
                        <option value="oz">ounces (oz)</option>
                      </select>
                    </div>
                  </div>
                </div>
                
                <div className="flex space-x-3 pt-4">
                  <button
                    type="submit"
                    disabled={loading}
                    className="flex-1 bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 disabled:opacity-50"
                  >
                    {loading ? 'Adding...' : 'Add Product'}
                  </button>
                  <button
                    type="button"
                    onClick={() => setShowAddProduct(false)}
                    className="flex-1 bg-gray-300 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-400"
                  >
                    Cancel
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* Edit Product Modal */}
      {showEditProduct && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-full max-w-2xl shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-xl font-medium text-gray-900 mb-6">Edit Product</h3>
              <form onSubmit={handleEditProduct} className="space-y-4 max-h-[80vh] overflow-y-auto">
                <div>
                  <label className="block text-sm font-medium text-gray-700">Product Name</label>
                  <input
                    type="text"
                    value={productForm.name}
                    onChange={(e) => setProductForm({...productForm, name: e.target.value})}
                    className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">Description</label>
                  <textarea
                    value={productForm.description}
                    onChange={(e) => setProductForm({...productForm, description: e.target.value})}
                    rows={3}
                    className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                    required
                  />
                </div>
                
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Price</label>
                    <input
                      type="number"
                      step="0.01"
                      value={productForm.price}
                      onChange={(e) => setProductForm({...productForm, price: e.target.value})}
                      className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Stock</label>
                    <input
                      type="number"
                      value={productForm.stock}
                      onChange={(e) => setProductForm({...productForm, stock: e.target.value})}
                      className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                      required
                    />
                  </div>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">Category</label>
                  <select
                    value={productForm.category}
                    onChange={(e) => setProductForm({...productForm, category: e.target.value})}
                    className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                    required
                  >
                    <option value="">Select category</option>
                    {categories.map((category) => (
                      <option key={category} value={category}>{category}</option>
                    ))}
                  </select>
                </div>

                {/* Additional Product Details */}
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Tags</label>
                    <input
                      type="text"
                      value={productForm.tags}
                      onChange={(e) => setProductForm({...productForm, tags: e.target.value})}
                      placeholder="handmade, artisan, unique"
                      className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                    />
                    <p className="mt-1 text-xs text-gray-500">Separate tags with commas</p>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Materials</label>
                    <input
                      type="text"
                      value={productForm.materials}
                      onChange={(e) => setProductForm({...productForm, materials: e.target.value})}
                      placeholder="cotton, wood, metal"
                      className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                    />
                    <p className="mt-1 text-xs text-gray-500">Separate materials with commas</p>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700">Care Instructions</label>
                  <textarea
                    value={productForm.careInstructions}
                    onChange={(e) => setProductForm({...productForm, careInstructions: e.target.value})}
                    rows={2}
                    placeholder="How to care for this product..."
                    className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                  />
                </div>

                {/* Dimensions */}
                <div>
                  <label className="block text-sm font-medium text-gray-700">Dimensions</label>
                  <div className="grid grid-cols-4 gap-2">
                    <div>
                      <label className="block text-xs text-gray-600">Length</label>
                      <input
                        type="number"
                        step="0.1"
                        value={productForm.dimensions.length}
                        onChange={(e) => setProductForm({
                          ...productForm, 
                          dimensions: { ...productForm.dimensions, length: e.target.value }
                        })}
                        placeholder="10"
                        className="mt-1 block w-full border border-gray-300 rounded-md px-2 py-2 text-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                      />
                    </div>
                    <div>
                      <label className="block text-xs text-gray-600">Width</label>
                      <input
                        type="number"
                        step="0.1"
                        value={productForm.dimensions.width}
                        onChange={(e) => setProductForm({
                          ...productForm, 
                          dimensions: { ...productForm.dimensions, width: e.target.value }
                        })}
                        placeholder="5"
                        className="mt-1 block w-full border border-gray-300 rounded-md px-2 py-2 text-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                      />
                    </div>
                    <div>
                      <label className="block text-xs text-gray-600">Height</label>
                      <input
                        type="number"
                        step="0.1"
                        value={productForm.dimensions.height}
                        onChange={(e) => setProductForm({
                          ...productForm, 
                          dimensions: { ...productForm.dimensions, height: e.target.value }
                        })}
                        placeholder="3"
                        className="mt-1 block w-full border border-gray-300 rounded-md px-2 py-2 text-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                      />
                    </div>
                    <div>
                      <label className="block text-xs text-gray-600">Unit</label>
                      <select
                        value={productForm.dimensions.unit}
                        onChange={(e) => setProductForm({
                          ...productForm, 
                          dimensions: { ...productForm.dimensions, unit: e.target.value }
                        })}
                        className="mt-1 block w-full border border-gray-300 rounded-md px-2 py-2 text-sm focus:outline-none focus:ring-primary-500 focus:ring-primary-500 focus:border-primary-500"
                      >
                        <option value="cm">cm</option>
                        <option value="inch">inch</option>
                        <option value="mm">mm</option>
                      </select>
                    </div>
                  </div>
                </div>

                {/* Weight */}
                <div>
                  <label className="block text-sm font-medium text-gray-700">Weight</label>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-xs text-gray-600">Value</label>
                      <input
                        type="number"
                        step="0.1"
                        value={productForm.weight.value}
                        onChange={(e) => setProductForm({
                          ...productForm, 
                          weight: { ...productForm.weight, value: e.target.value }
                        })}
                        placeholder="500"
                        className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                      />
                    </div>
                    <div>
                      <label className="block text-xs text-gray-600">Unit</label>
                      <select
                        value={productForm.weight.unit}
                        onChange={(e) => setProductForm({
                          ...productForm, 
                          weight: { ...productForm.weight, unit: e.target.value }
                        })}
                        className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                      >
                        <option value="g">grams (g)</option>
                        <option value="kg">kilograms (kg)</option>
                        <option value="lb">pounds (lb)</option>
                        <option value="oz">ounces (oz)</option>
                      </select>
                    </div>
                  </div>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">Add New Images</label>
                  <input
                    type="file"
                    id="edit-product-images"
                    multiple
                    accept="image/*"
                    className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                  />
                </div>
                
                <div className="flex space-x-3 pt-4">
                  <button
                    type="submit"
                    disabled={loading}
                    className="flex-1 bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 disabled:opacity-50"
                  >
                    {loading ? 'Updating...' : 'Update Product'}
                  </button>
                  <button
                    type="button"
                    onClick={() => setShowEditProduct(false)}
                    className="flex-1 bg-gray-300 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-400"
                  >
                    Cancel
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* Profile Modal */}
      {showProfileModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                {vendorProfile ? 'Edit Profile' : 'Create Profile'}
              </h3>
              <form onSubmit={handleUpdateProfile} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">Shop Name</label>
                  <input
                    type="text"
                    value={profileForm.shopName}
                    onChange={(e) => setProfileForm({...profileForm, shopName: e.target.value})}
                    className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">Bio</label>
                  <textarea
                    value={profileForm.bio}
                    onChange={(e) => setProfileForm({...profileForm, bio: e.target.value})}
                    rows={3}
                    className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                    required
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">Tagline</label>
                  <input
                    type="text"
                    value={profileForm.tagline}
                    onChange={(e) => setProfileForm({...profileForm, tagline: e.target.value})}
                    className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                  />
                </div>
                
                                 <div>
                   <label className="block text-sm font-medium text-gray-700">Specialties (comma-separated)</label>
                   <input
                     type="text"
                     value={profileForm.specialties}
                     onChange={(e) => setProfileForm({...profileForm, specialties: e.target.value})}
                     className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                     placeholder="e.g., Jewelry, Handmade Crafts, Custom Designs"
                   />
                   <p className="mt-1 text-sm text-gray-500">Enter your specialties separated by commas</p>
                 </div>

                 {/* Location Section */}
                 <div className="space-y-3">
                   <label className="block text-sm font-medium text-gray-700">Location & Address</label>
                   
                   <div>
                     <label className="block text-xs text-gray-600">Address</label>
                     <input
                       type="text"
                       value={profileForm.location.address}
                       onChange={(e) => setProfileForm({
                         ...profileForm, 
                         location: { ...profileForm.location, address: e.target.value }
                       })}
                       className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                       placeholder="123 Main Street, New York, NY 10001, United States"
                     />
                     <p className="mt-1 text-sm text-gray-500">Enter your full address (street, city, state, country, postal code)</p>
                   </div>
                 </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Profile Image {!vendorProfile && <span className="text-red-500">*</span>}
                  </label>
                  <input
                    type="file"
                    id="profile-image"
                    accept="image/*"
                    required={!vendorProfile}
                    className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                  />
                  {!vendorProfile && (
                    <p className="mt-1 text-sm text-gray-500">Profile image is required for new profiles</p>
                  )}
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Banner Image
                  </label>
                  <input
                    type="file"
                    id="banner-image"
                    accept="image/*"
                    className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                  />
                  <p className="mt-1 text-sm text-gray-500">Add a banner image to make your profile stand out (optional)</p>
                </div>
                
                <div className="flex space-x-3 pt-4">
                  <button
                    type="submit"
                    disabled={loading}
                    className="flex-1 bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 disabled:opacity-50"
                  >
                    {loading 
                      ? (vendorProfile ? 'Updating...' : 'Creating...') 
                      : (vendorProfile ? 'Update Profile' : 'Create Profile')
                    }
                  </button>
                  <button
                    type="button"
                    onClick={() => setShowProfileModal(false)}
                    className="flex-1 bg-gray-300 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-400"
                  >
                    Cancel
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default VendorDashboard;
