import React, { useState, useEffect } from 'react'
import { FaStar, FaMapMarkerAlt, FaHeart, FaEye, FaFilter, FaSearch, FaGlobe, FaInstagram, FaFacebook } from 'react-icons/fa'

const Artisans = () => {
  const [artisans, setArtisans] = useState([])
  const [filteredArtisans, setFilteredArtisans] = useState([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedCategory, setSelectedCategory] = useState('all')
  const [selectedLocation, setSelectedLocation] = useState('all')
  const [sortBy, setSortBy] = useState('rating')

  // Enhanced dummy artisans data
  const dummyArtisans = [
    {
      id: 1,
      name: 'Sarah Chen',
      shopName: 'Chen Creations',
      category: 'Jewelry',
      location: 'San Francisco, CA',
      rating: 4.9,
      reviewCount: 127,
      productsCount: 45,
      followers: 1200,
      image: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=400&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=400&fit=crop',
      bio: 'Master jewelry artisan with 15+ years of experience creating unique pieces that tell stories. Specializing in sustainable materials and traditional techniques.',
      specialties: ['Handmade Necklaces', 'Custom Rings', 'Sustainable Materials'],
      featured: true,
      verified: true,
      social: {
        instagram: '@chencreations',
        facebook: 'ChenCreationsSF'
      }
    },
    {
      id: 2,
      name: 'Marcus Rodriguez',
      shopName: 'Rodriguez Pottery',
      category: 'Ceramics',
      location: 'Austin, TX',
      rating: 4.8,
      reviewCount: 89,
      productsCount: 32,
      followers: 850,
      image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=400&fit=crop',
      bio: 'Passionate potter creating functional art pieces that bring beauty to everyday life. Each piece is handcrafted with love and attention to detail.',
      specialties: ['Functional Pottery', 'Decorative Vases', 'Custom Commissions'],
      featured: true,
      verified: true,
      social: {
        instagram: '@rodriguezpottery',
        facebook: 'RodriguezPotteryATX'
      }
    },
    {
      id: 3,
      name: 'Aisha Patel',
      shopName: 'Patel Textiles',
      category: 'Textiles',
      location: 'New York, NY',
      rating: 4.7,
      reviewCount: 156,
      productsCount: 67,
      followers: 2100,
      image: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=400&fit=crop',
      bio: 'Textile artist preserving traditional Indian weaving techniques while creating modern, sustainable home decor. Every piece tells a cultural story.',
      specialties: ['Handwoven Rugs', 'Textile Wall Art', 'Sustainable Home Decor'],
      featured: true,
      verified: true,
      social: {
        instagram: '@pateltextiles',
        facebook: 'PatelTextilesNYC'
      }
    },
    {
      id: 4,
      name: 'David Kim',
      shopName: 'Kim Woodworks',
      category: 'Woodworking',
      location: 'Portland, OR',
      rating: 4.9,
      reviewCount: 203,
      productsCount: 28,
      followers: 1800,
      image: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=400&fit=crop',
      bio: 'Master woodworker crafting heirloom-quality furniture using sustainable hardwoods and traditional joinery techniques.',
      specialties: ['Custom Furniture', 'Kitchen Utensils', 'Decorative Boxes'],
      featured: false,
      verified: true,
      social: {
        instagram: '@kimwoodworks',
        facebook: 'KimWoodworksPDX'
      }
    },
    {
      id: 5,
      name: 'Elena Vasquez',
      shopName: 'Vasquez Glass',
      category: 'Glass',
      location: 'Seattle, WA',
      rating: 4.6,
      reviewCount: 78,
      productsCount: 41,
      followers: 950,
      image: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=400&fit=crop',
      bio: 'Glass artist creating stunning pieces that capture light and color. Specializing in blown glass and fused glass techniques.',
      specialties: ['Blown Glass Vases', 'Fused Glass Art', 'Custom Lighting'],
      featured: false,
      verified: true,
      social: {
        instagram: '@vasquezglass',
        facebook: 'VasquezGlassSeattle'
      }
    },
    {
      id: 6,
      name: 'James Wilson',
      shopName: 'Wilson Metals',
      category: 'Metalwork',
      location: 'Denver, CO',
      rating: 4.8,
      reviewCount: 134,
      productsCount: 23,
      followers: 1100,
      image: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=400&fit=crop',
      bio: 'Metal artist creating unique sculptures and functional art pieces. Combining traditional blacksmithing with modern design principles.',
      specialties: ['Metal Sculptures', 'Custom Gates', 'Functional Art'],
      featured: false,
      verified: true,
      social: {
        instagram: '@wilsonmetals',
        facebook: 'WilsonMetalsDenver'
      }
    }
  ]

  const categories = [
    { value: 'all', label: 'All Categories', count: 6 },
    { value: 'Jewelry', label: 'Jewelry', count: 1 },
    { value: 'Ceramics', label: 'Ceramics', count: 1 },
    { value: 'Textiles', label: 'Textiles', count: 1 },
    { value: 'Woodworking', label: 'Woodworking', count: 1 },
    { value: 'Glass', label: 'Glass', count: 1 },
    { value: 'Metalwork', label: 'Metalwork', count: 1 }
  ]

  const locations = [
    { value: 'all', label: 'All Locations', count: 6 },
    { value: 'San Francisco, CA', label: 'San Francisco, CA', count: 1 },
    { value: 'Austin, TX', label: 'Austin, TX', count: 1 },
    { value: 'New York, NY', label: 'New York, NY', count: 1 },
    { value: 'Portland, OR', label: 'Portland, OR', count: 1 },
    { value: 'Seattle, WA', label: 'Seattle, WA', count: 1 },
    { value: 'Denver, CO', label: 'Denver, CO', count: 1 }
  ]

  useEffect(() => {
    // Simulate loading
    setTimeout(() => {
      setArtisans(dummyArtisans)
      setFilteredArtisans(dummyArtisans)
      setLoading(false)
    }, 1000)
  }, [])

  useEffect(() => {
    let filtered = [...artisans]

    // Search filter
    if (searchQuery) {
      filtered = filtered.filter(artisan =>
        artisan.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        artisan.shopName.toLowerCase().includes(searchQuery.toLowerCase()) ||
        artisan.category.toLowerCase().includes(searchQuery.toLowerCase()) ||
        artisan.bio.toLowerCase().includes(searchQuery.toLowerCase())
      )
    }

    // Category filter
    if (selectedCategory !== 'all') {
      filtered = filtered.filter(artisan => artisan.category === selectedCategory)
    }

    // Location filter
    if (selectedLocation !== 'all') {
      filtered = filtered.filter(artisan => artisan.location === selectedLocation)
    }

    // Sorting
    filtered.sort((a, b) => {
      switch (sortBy) {
        case 'rating':
          return b.rating - a.rating
        case 'products':
          return b.productsCount - a.productsCount
        case 'followers':
          return b.followers - a.followers
        case 'name':
          return a.name.localeCompare(b.name)
        default:
          return 0
      }
    })

    setFilteredArtisans(filtered)
  }, [artisans, searchQuery, selectedCategory, selectedLocation, sortBy])

  const clearFilters = () => {
    setSearchQuery('')
    setSelectedCategory('all')
    setSelectedLocation('all')
    setSortBy('rating')
  }

  const renderStars = (rating) => {
    return Array.from({ length: 5 }, (_, i) => (
      <FaStar
        key={i}
        className={`w-4 h-4 ${
          i < Math.floor(rating)
            ? 'text-yellow-400'
            : i < rating
            ? 'text-yellow-400 opacity-60'
            : 'text-gray-300'
        }`}
      />
    ))
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-50 py-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <div className="animate-pulse">
              <div className="h-12 bg-gray-300 rounded-lg mb-4 max-w-md mx-auto"></div>
              <div className="h-6 bg-gray-300 rounded-lg max-w-2xl mx-auto"></div>
            </div>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[1, 2, 3, 4, 5, 6].map((i) => (
              <div key={i} className="bg-white rounded-2xl p-6 shadow-lg animate-pulse">
                <div className="h-48 bg-gray-300 rounded-xl mb-4"></div>
                <div className="h-6 bg-gray-300 rounded-lg mb-2"></div>
                <div className="h-4 bg-gray-300 rounded-lg mb-4"></div>
                <div className="h-4 bg-gray-300 rounded-lg w-3/4"></div>
              </div>
            ))}
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-50">
      {/* Header Section */}
      <section className="relative py-20 overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-r from-blue-600/10 via-purple-600/10 to-pink-600/10"></div>
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h1 className="text-5xl md:text-6xl font-bold bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 bg-clip-text text-transparent mb-6">
            Meet Our Artisans
          </h1>
          <p className="text-xl text-gray-700 max-w-3xl mx-auto leading-relaxed">
            Discover the incredible creators behind every handmade masterpiece. 
            Each artisan brings their unique story, passion, and expertise to create 
            products that are truly one-of-a-kind.
          </p>
        </div>
      </section>

      {/* Search and Filters */}
      <section className="py-8 bg-white/50 backdrop-blur-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="bg-white rounded-2xl p-6 shadow-lg">
            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-4">
              {/* Search */}
              <div className="relative">
                <FaSearch className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
                <input
                  type="text"
                  placeholder="Search artisans..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
                />
              </div>

              {/* Category Filter */}
              <select
                value={selectedCategory}
                onChange={(e) => setSelectedCategory(e.target.value)}
                className="px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
              >
                {categories.map((category) => (
                  <option key={category.value} value={category.value}>
                    {category.label} ({category.count})
                  </option>
                ))}
              </select>

              {/* Location Filter */}
              <select
                value={selectedLocation}
                onChange={(e) => setSelectedLocation(e.target.value)}
                className="px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
              >
                {locations.map((location) => (
                  <option key={location.value} value={location.value}>
                    {location.label} ({location.count})
                  </option>
                ))}
              </select>

              {/* Sort */}
              <select
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value)}
                className="px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
              >
                <option value="rating">Sort by Rating</option>
                <option value="products">Sort by Products</option>
                <option value="followers">Sort by Followers</option>
                <option value="name">Sort by Name</option>
              </select>
            </div>

            {/* Clear Filters */}
            {(searchQuery || selectedCategory !== 'all' || selectedLocation !== 'all') && (
              <div className="mt-4 text-center">
                <button
                  onClick={clearFilters}
                  className="text-blue-600 hover:text-blue-800 font-medium transition-colors duration-200"
                >
                  Clear All Filters
                </button>
              </div>
            )}
          </div>
        </div>
      </section>

      {/* Results Summary */}
      <section className="py-4">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <p className="text-gray-600">
              Showing {filteredArtisans.length} of {artisans.length} artisans
            </p>
          </div>
        </div>
      </section>

      {/* Artisans Grid */}
      <section className="py-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          {filteredArtisans.length > 0 ? (
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
              {filteredArtisans.map((artisan) => (
                <div key={artisan.id} className="group">
                  <div className="bg-white rounded-2xl shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2 overflow-hidden">
                    {/* Cover Image */}
                    <div className="relative h-48 overflow-hidden">
                      <img
                        src={artisan.coverImage}
                        alt={artisan.shopName}
                        className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent"></div>
                      
                      {/* Featured Badge */}
                      {artisan.featured && (
                        <div className="absolute top-4 left-4">
                          <span className="bg-gradient-to-r from-yellow-400 to-orange-500 text-white px-3 py-1 rounded-full text-sm font-semibold shadow-lg">
                            Featured
                          </span>
                        </div>
                      )}

                      {/* Verified Badge */}
                      {artisan.verified && (
                        <div className="absolute top-4 right-4">
                          <div className="bg-blue-500 text-white p-2 rounded-full shadow-lg">
                            <FaGlobe className="w-4 h-4" />
                          </div>
                        </div>
                      )}

                      {/* Profile Image */}
                      <div className="absolute bottom-4 left-4">
                        <div className="w-20 h-20 rounded-full border-4 border-white shadow-lg overflow-hidden">
                          <img
                            src={artisan.image}
                            alt={artisan.name}
                            className="w-full h-full object-cover"
                          />
                        </div>
                      </div>
                    </div>

                    {/* Content */}
                    <div className="p-6">
                      {/* Name and Shop */}
                      <div className="mb-4">
                        <h3 className="text-xl font-bold text-gray-900 mb-1">{artisan.name}</h3>
                        <p className="text-blue-600 font-semibold">{artisan.shopName}</p>
                      </div>

                      {/* Category and Location */}
                      <div className="flex items-center justify-between mb-4">
                        <span className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm font-medium">
                          {artisan.category}
                        </span>
                        <div className="flex items-center text-gray-600 text-sm">
                          <FaMapMarkerAlt className="w-4 h-4 mr-1" />
                          {artisan.location}
                        </div>
                      </div>

                      {/* Rating */}
                      <div className="flex items-center mb-4">
                        <div className="flex mr-2">
                          {renderStars(artisan.rating)}
                        </div>
                        <span className="text-gray-600 text-sm">
                          {artisan.rating} ({artisan.reviewCount} reviews)
                        </span>
                      </div>

                      {/* Bio */}
                      <p className="text-gray-600 text-sm leading-relaxed mb-4 line-clamp-3">
                        {artisan.bio}
                      </p>

                      {/* Stats */}
                      <div className="grid grid-cols-3 gap-4 mb-6 text-center">
                        <div>
                          <div className="text-lg font-bold text-gray-900">{artisan.productsCount}</div>
                          <div className="text-xs text-gray-600">Products</div>
                        </div>
                        <div>
                          <div className="text-lg font-bold text-gray-900">{artisan.followers}</div>
                          <div className="text-xs text-gray-600">Followers</div>
                        </div>
                        <div>
                          <div className="text-lg font-bold text-gray-900">{artisan.reviewCount}</div>
                          <div className="text-xs text-gray-600">Reviews</div>
                        </div>
                      </div>

                      {/* Specialties */}
                      <div className="mb-6">
                        <h4 className="text-sm font-semibold text-gray-900 mb-2">Specialties:</h4>
                        <div className="flex flex-wrap gap-2">
                          {artisan.specialties.map((specialty, index) => (
                            <span
                              key={index}
                              className="bg-gray-100 text-gray-700 px-2 py-1 rounded-full text-xs"
                            >
                              {specialty}
                            </span>
                          ))}
                        </div>
                      </div>

                      {/* Social Links */}
                      <div className="flex items-center justify-between mb-4">
                        <div className="flex space-x-3">
                          {artisan.social.instagram && (
                            <a
                              href={`https://instagram.com/${artisan.social.instagram}`}
                              target="_blank"
                              rel="noopener noreferrer"
                              className="text-pink-600 hover:text-pink-700 transition-colors duration-200"
                            >
                              <FaInstagram className="w-5 h-5" />
                            </a>
                          )}
                          {artisan.social.facebook && (
                            <a
                              href={`https://facebook.com/${artisan.social.facebook}`}
                              target="_blank"
                              rel="noopener noreferrer"
                              className="text-blue-600 hover:text-blue-700 transition-colors duration-200"
                            >
                              <FaFacebook className="w-5 h-5" />
                            </a>
                          )}
                        </div>
                        <button className="text-blue-600 hover:text-blue-800 font-medium text-sm transition-colors duration-200">
                          View Profile
                        </button>
                      </div>

                      {/* Action Buttons */}
                      <div className="flex space-x-3">
                        <button className="flex-1 bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white py-3 px-4 rounded-lg font-semibold transition-all duration-200 transform hover:scale-105 shadow-lg hover:shadow-xl">
                          Follow
                        </button>
                        <button className="flex-1 border-2 border-gray-300 text-gray-700 hover:border-blue-500 hover:text-blue-600 py-3 px-4 rounded-lg font-semibold transition-all duration-200 transform hover:scale-105">
                          Message
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-16">
              <div className="text-6xl mb-4">🔍</div>
              <h3 className="text-2xl font-bold text-gray-900 mb-4">No Artisans Found</h3>
              <p className="text-gray-600 mb-6">
                Try adjusting your search criteria or filters to find more artisans.
              </p>
              <button
                onClick={clearFilters}
                className="bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white px-6 py-3 rounded-lg font-semibold transition-all duration-200 transform hover:scale-105 shadow-lg hover:shadow-xl"
              >
                Clear All Filters
              </button>
            </div>
          )}
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-4xl font-bold text-white mb-6">Become an Artisan</h2>
          <p className="text-xl text-blue-100 mb-8 max-w-3xl mx-auto">
            Are you a talented creator looking to share your work with the world? 
            Join our community of artisans and start selling your handmade creations today.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <button className="px-8 py-4 bg-white text-blue-600 font-semibold rounded-full hover:bg-gray-100 transition-colors duration-300 transform hover:scale-105">
              Apply Now
            </button>
            <button className="px-8 py-4 border-2 border-white text-white font-semibold rounded-full hover:bg-white hover:text-blue-600 transition-all duration-300 transform hover:scale-105">
              Learn More
            </button>
          </div>
        </div>
      </section>
    </div>
  )
}

export default Artisans
