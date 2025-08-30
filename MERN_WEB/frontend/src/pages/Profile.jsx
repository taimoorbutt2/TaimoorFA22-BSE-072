import React, { useState, useEffect } from 'react';
import { Link, useParams } from 'react-router-dom';
import { FiUser, FiMapPin, FiAward, FiClock, FiMail, FiPhone, FiGlobe, FiEdit2, FiStar, FiPackage, FiTrendingUp, FiHeart, FiShoppingBag } from 'react-icons/fi';
import { toast } from 'react-hot-toast';
import api from '../utils/api';

const Profile = () => {
  const [vendorProfile, setVendorProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [showEditModal, setShowEditModal] = useState(false);

  useEffect(() => {
    fetchVendorProfile();
  }, []);

  const fetchVendorProfile = async () => {
    try {
      setLoading(true);
      const response = await api.get('/vendors/profile/me');
      console.log('Profile data received:', response.data);
      
      // Ensure all profile data is properly formatted
      const profile = response.data.profile;
      if (profile) {
        // Clean up any potential object issues
        const cleanProfile = {
          ...profile,
          shopName: String(profile.shopName || ''),
          bio: String(profile.bio || ''),
          tagline: String(profile.tagline || ''),
          specialties: Array.isArray(profile.specialties) ? profile.specialties.map(s => String(s)) : [],
          location: profile.location && typeof profile.location === 'object' ? profile.location : {},
          experience: profile.experience && typeof profile.experience === 'object' ? profile.experience : {},
          education: Array.isArray(profile.education) ? profile.education : [],
          certifications: Array.isArray(profile.certifications) ? profile.certifications : [],
          contactInfo: profile.contactInfo && typeof profile.contactInfo === 'object' ? profile.contactInfo : {},
          businessHours: profile.businessHours && typeof profile.businessHours === 'object' ? profile.businessHours : {},
          policies: profile.policies && typeof profile.policies === 'object' ? profile.policies : {}
        };
        setVendorProfile(cleanProfile);
      } else {
        setVendorProfile(null);
      }
    } catch (error) {
      console.error('Error fetching vendor profile:', error);
      if (error.response?.status === 404) {
        setVendorProfile(null);
      }
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-primary-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading your amazing profile...</p>
        </div>
      </div>
    );
  }

  if (!vendorProfile) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50 flex items-center justify-center">
        <div className="text-center max-w-md mx-auto px-6">
          <div className="w-24 h-24 bg-gradient-to-r from-primary-500 to-purple-600 rounded-full flex items-center justify-center mx-auto mb-6">
            <FiUser className="w-12 h-12 text-white" />
          </div>
          <h2 className="text-3xl font-bold text-gray-900 mb-4">Profile Not Found</h2>
          <p className="text-gray-600 mb-8">It looks like you haven't created your vendor profile yet. Let's get you started!</p>
          <Link
            to="/dashboard"
            className="inline-flex items-center px-6 py-3 bg-gradient-to-r from-primary-600 to-purple-600 text-white font-semibold rounded-lg hover:from-primary-700 hover:to-purple-700 transform hover:scale-105 transition-all duration-200 shadow-lg"
          >
            <FiEdit2 className="w-5 h-5 mr-2" />
            Create Profile
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
      {/* Hero Section */}
      <div className="relative overflow-hidden">
        {/* Background Pattern */}
        <div className="absolute inset-0 bg-gradient-to-r from-primary-100/30 to-purple-100/30"></div>
        <div className="absolute inset-0 opacity-5">
          <div className="absolute inset-0 bg-gradient-to-br from-primary-200 to-purple-200"></div>
        </div>
        
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
          <div className="text-center mb-12">
            <h1 className="text-5xl font-bold text-gray-900 mb-4">
              Welcome to <span className="bg-gradient-to-r from-primary-600 to-purple-600 bg-clip-text text-transparent">
                {vendorProfile.shopName}
              </span>
            </h1>
            {vendorProfile.tagline && (
              <p className="text-xl text-gray-600 max-w-2xl mx-auto">
                {vendorProfile.tagline}
              </p>
            )}
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          
          {/* Left Column - Profile Info */}
          <div className="lg:col-span-1">
            {/* Profile Card */}
            <div className="bg-white rounded-2xl shadow-xl p-8 sticky top-8">
              <div className="text-center mb-6">
                <div className="relative inline-block">
                  {vendorProfile.profileImage ? (
                    <img
                      src={vendorProfile.profileImage}
                      alt={vendorProfile.shopName}
                      className="w-48 h-48 rounded-full object-cover border-4 border-white shadow-2xl mx-auto"
                      onError={(e) => {
                        console.error('Image failed to load:', vendorProfile.profileImage);
                        e.target.style.display = 'none';
                        e.target.nextSibling.style.display = 'block';
                      }}
                      onLoad={() => {
                        console.log('Image loaded successfully!');
                        console.log('Base64 image loaded from database');
                      }}
                    />
                  ) : null}
                  {/* Fallback icon */}
                  <div className="w-48 h-48 rounded-full bg-gradient-to-r from-primary-500 to-purple-600 flex items-center justify-center mx-auto border-4 border-white shadow-2xl" style={{ display: vendorProfile.profileImage ? 'none' : 'flex' }}>
                    <FiUser className="w-24 h-24 text-white" />
                  </div>
                </div>
                
                <h2 className="text-2xl font-bold text-gray-900 mt-4">{vendorProfile.shopName}</h2>
                {vendorProfile.tagline && (
                  <p className="text-gray-600 mt-2">{vendorProfile.tagline}</p>
                )}
                
                {/* Rating */}
                <div className="flex items-center justify-center mt-4">
                  <div className="flex items-center space-x-1">
                    {[1, 2, 3, 4, 5].map((star) => (
                      <FiStar key={star} className="w-5 h-5 text-yellow-400 fill-current" />
                    ))}
                  </div>
                  <span className="ml-2 text-sm text-gray-600">5.0 (24 reviews)</span>
                </div>
              </div>

              {/* Quick Stats */}
              <div className="grid grid-cols-3 gap-4 mb-6">
                <div className="text-center">
                  <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center mx-auto mb-2">
                    <FiPackage className="w-6 h-6 text-blue-600" />
                  </div>
                  <p className="text-2xl font-bold text-gray-900">24</p>
                  <p className="text-sm text-gray-600">Products</p>
                </div>
                <div className="text-center">
                  <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center mx-auto mb-2">
                    <FiTrendingUp className="w-6 h-6 text-green-600" />
                  </div>
                  <p className="text-2xl font-bold text-gray-900">156</p>
                  <p className="text-sm text-gray-600">Sales</p>
                </div>
                <div className="text-center">
                  <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center mx-auto mb-2">
                    <FiHeart className="w-6 h-6 text-purple-600" />
                  </div>
                  <p className="text-2xl font-bold text-gray-900">89</p>
                  <p className="text-sm text-gray-600">Favorites</p>
                </div>
              </div>

              {/* Contact Info */}
              {vendorProfile.contactInfo && (
                <div className="space-y-3">
                  <h3 className="font-semibold text-gray-900 mb-3">Contact Information</h3>
                  {vendorProfile.contactInfo.phone && (
                    <div className="flex items-center text-gray-600">
                      <FiPhone className="w-4 h-4 mr-3 text-primary-600" />
                      <span>{String(vendorProfile.contactInfo.phone)}</span>
                    </div>
                  )}
                  {vendorProfile.contactInfo.email && (
                    <div className="flex items-center text-gray-600">
                      <FiMail className="w-4 h-4 mr-3 text-primary-600" />
                      <span>{String(vendorProfile.contactInfo.email)}</span>
                    </div>
                  )}
                  {vendorProfile.contactInfo.address && (
                    <div className="flex items-center text-gray-600">
                      <FiMapPin className="w-4 h-4 mr-3 text-primary-600" />
                      <span>{String(vendorProfile.contactInfo.address)}</span>
                    </div>
                  )}
                </div>
              )}

              {/* Edit Profile Button */}
              <button
                onClick={() => setShowEditModal(true)}
                className="w-full mt-6 bg-gradient-to-r from-primary-600 to-purple-600 text-white font-semibold py-3 px-4 rounded-lg hover:from-primary-700 hover:to-purple-700 transform hover:scale-105 transition-all duration-200 shadow-lg flex items-center justify-center"
              >
                <FiEdit2 className="w-5 h-5 mr-2" />
                Edit Profile
              </button>
            </div>
          </div>

          {/* Right Column - Detailed Info */}
          <div className="lg:col-span-2 space-y-8">
            
            {/* About Section */}
            <div className="bg-white rounded-2xl shadow-xl p-8">
              <h3 className="text-2xl font-bold text-gray-900 mb-6 flex items-center">
                <FiUser className="w-6 h-6 mr-3 text-primary-600" />
                About
              </h3>
              <p className="text-gray-700 leading-relaxed text-lg">
                {vendorProfile.bio || "This talented artisan creates unique, handcrafted pieces that tell a story. Each creation is made with passion, attention to detail, and a commitment to quality that shines through in every item."}
              </p>
            </div>

            {/* Specialties Section */}
            {vendorProfile.specialties && vendorProfile.specialties.length > 0 && (
              <div className="bg-white rounded-2xl shadow-xl p-8">
                <h3 className="text-2xl font-bold text-gray-900 mb-6 flex items-center">
                  <FiAward className="w-6 h-6 mr-3 text-primary-600" />
                  Specialties
                </h3>
                <div className="flex flex-wrap gap-3">
                  {vendorProfile.specialties.map((specialty, index) => (
                    <span
                      key={index}
                      className="px-4 py-2 bg-gradient-to-r from-primary-100 to-purple-100 text-primary-800 rounded-full font-medium text-sm hover:from-primary-200 hover:to-purple-200 transition-all duration-200 cursor-pointer"
                    >
                      {specialty}
                    </span>
                  ))}
                </div>
              </div>
            )}

            {/* Location Section */}
            {vendorProfile.location && (
              <div className="bg-white rounded-2xl shadow-xl p-8">
                <h3 className="text-2xl font-bold text-gray-900 mb-6 flex items-center">
                  <FiMapPin className="w-6 h-6 mr-3 text-primary-600" />
                  Location
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  {vendorProfile.location.city && (
                    <div className="text-center p-4 bg-gray-50 rounded-lg">
                      <p className="text-sm text-gray-600">City</p>
                      <p className="font-semibold text-gray-900">{String(vendorProfile.location.city)}</p>
                    </div>
                  )}
                  {vendorProfile.location.state && (
                    <div className="text-center p-4 bg-gray-50 rounded-lg">
                      <p className="text-sm text-gray-600">State</p>
                      <p className="font-semibold text-gray-900">{String(vendorProfile.location.state)}</p>
                    </div>
                  )}
                  {vendorProfile.location.country && (
                    <div className="text-center p-4 bg-gray-50 rounded-lg">
                      <p className="text-sm text-gray-600">Country</p>
                      <p className="font-semibold text-gray-900">{String(vendorProfile.location.country)}</p>
                    </div>
                  )}
                </div>
              </div>
            )}

            {/* Experience Section */}
            {vendorProfile.experience && (
              <div className="bg-white rounded-2xl shadow-xl p-8">
                <h3 className="text-2xl font-bold text-gray-900 mb-6 flex items-center">
                  <FiClock className="w-6 h-6 mr-3 text-primary-600" />
                  Experience
                </h3>
                <div className="space-y-4">
                  {vendorProfile.experience.years && (
                    <div className="flex items-center">
                      <div className="w-3 h-3 bg-primary-600 rounded-full mr-4"></div>
                      <div>
                        <p className="font-semibold text-gray-900">{String(vendorProfile.experience.years)} years of experience</p>
                        {vendorProfile.experience.description && (
                          <p className="text-gray-600 mt-1">{String(vendorProfile.experience.description)}</p>
                        )}
                      </div>
                    </div>
                  )}
                </div>
              </div>
            )}

            {/* Education Section */}
            {vendorProfile.education && vendorProfile.education.length > 0 && (
              <div className="bg-white rounded-2xl shadow-xl p-8">
                <h3 className="text-2xl font-bold text-gray-900 mb-6 flex items-center">
                  <FiAward className="w-6 h-6 mr-3 text-primary-600" />
                  Education & Training
                </h3>
                <div className="space-y-4">
                  {vendorProfile.education.map((edu, index) => (
                    <div key={index} className="flex items-start">
                      <div className="w-3 h-3 bg-purple-600 rounded-full mr-4 mt-2"></div>
                      <div>
                        <p className="font-semibold text-gray-900">{String(edu.degree || edu.institution || 'Education')}</p>
                        {edu.institution && edu.degree && (
                          <p className="text-gray-600">{String(edu.institution)}</p>
                        )}
                        {edu.year && (
                          <p className="text-sm text-gray-500">{String(edu.year)}</p>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Certifications Section */}
            {vendorProfile.certifications && vendorProfile.certifications.length > 0 && (
              <div className="bg-white rounded-2xl shadow-xl p-8">
                <h3 className="text-2xl font-bold text-gray-900 mb-6 flex items-center">
                  <FiAward className="w-6 h-6 mr-3 text-primary-600" />
                  Certifications
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {vendorProfile.certifications.map((cert, index) => (
                    <div key={index} className="p-4 bg-gradient-to-r from-primary-50 to-purple-50 rounded-lg border border-primary-100">
                      <p className="font-semibold text-primary-800">{String(cert.name || cert || 'Certification')}</p>
                      {cert.issuer && (
                        <p className="text-sm text-primary-600">{String(cert.issuer)}</p>
                      )}
                      {cert.year && (
                        <p className="text-xs text-primary-500">{String(cert.year)}</p>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Business Hours Section */}
            {vendorProfile.businessHours && (
              <div className="bg-white rounded-2xl shadow-xl p-8">
                <h3 className="text-2xl font-bold text-gray-900 mb-6 flex items-center">
                  <FiClock className="w-6 h-6 mr-3 text-primary-600" />
                  Business Hours
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {Object.entries(vendorProfile.businessHours).map(([day, hours]) => {
                    // Handle different types of hours data
                    let displayHours = '';
                    if (typeof hours === 'string') {
                      displayHours = hours;
                    } else if (typeof hours === 'object' && hours !== null) {
                      if (hours.closed) {
                        displayHours = 'Closed';
                      } else if (hours.open && hours.close) {
                        displayHours = `${hours.open} - ${hours.close}`;
                      } else {
                        displayHours = 'Hours vary';
                      }
                    } else {
                      displayHours = 'Not specified';
                    }

                    return (
                      <div key={day} className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                        <span className="font-medium text-gray-900 capitalize">{day}</span>
                        <span className="text-gray-600">{displayHours}</span>
                      </div>
                    );
                  })}
                </div>
              </div>
            )}

            {/* Policies Section */}
            {vendorProfile.policies && (
              <div className="bg-white rounded-2xl shadow-xl p-8">
                <h3 className="text-2xl font-bold text-gray-900 mb-6 flex items-center">
                  <FiShoppingBag className="w-6 h-6 mr-3 text-primary-600" />
                  Shop Policies
                </h3>
                <div className="space-y-4">
                  {Object.entries(vendorProfile.policies).map(([policy, details]) => {
                    // Handle different types of policy data
                    let displayDetails = '';
                    if (typeof details === 'string') {
                      displayDetails = details;
                    } else if (typeof details === 'object' && details !== null) {
                      displayDetails = JSON.stringify(details, null, 2);
                    } else {
                      displayDetails = 'Not specified';
                    }

                    return (
                      <div key={policy} className="border-l-4 border-primary-500 pl-4">
                        <h4 className="font-semibold text-gray-900 capitalize mb-2">{policy.replace(/([A-Z])/g, ' $1').trim()}</h4>
                        <p className="text-gray-600">{displayDetails}</p>
                      </div>
                    );
                  })}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Edit Profile Modal */}
      {showEditModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-2xl font-bold text-gray-900">Edit Profile</h3>
                <button
                  onClick={() => setShowEditModal(false)}
                  className="text-gray-400 hover:text-gray-600 transition-colors"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
              
              <div className="text-center py-8">
                <p className="text-gray-600 mb-4">To edit your profile, please visit your dashboard.</p>
                <Link
                  to="/dashboard"
                  className="inline-flex items-center px-6 py-3 bg-gradient-to-r from-primary-600 to-purple-600 text-white font-semibold rounded-lg hover:from-primary-700 hover:to-purple-700 transform hover:scale-105 transition-all duration-200 shadow-lg"
                >
                  <FiEdit2 className="w-5 h-5 mr-2" />
                  Go to Dashboard
                </Link>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Profile;
