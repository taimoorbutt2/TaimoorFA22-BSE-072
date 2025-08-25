import React from 'react'
import { FaHeart, FaUsers, FaShieldAlt, FaGlobe, FaAward, FaHandshake } from 'react-icons/fa'

const About = () => {
  const stats = [
    { number: '500+', label: 'Artisans', icon: FaUsers },
    { number: '10K+', label: 'Products', icon: FaHeart },
    { number: '50K+', label: 'Happy Customers', icon: FaHandshake },
    { number: '99%', label: 'Satisfaction', icon: FaAward }
  ]

  const values = [
    {
      icon: FaHeart,
      title: 'Passion for Craftsmanship',
      description: 'We believe every handmade item tells a unique story and deserves to be celebrated.'
    },
    {
      icon: FaUsers,
      title: 'Community First',
      description: 'Building connections between artisans and customers, fostering a supportive creative ecosystem.'
    },
    {
      icon: FaShieldAlt,
      title: 'Quality Assurance',
      description: 'Every product is carefully curated to ensure the highest standards of craftsmanship.'
    },
    {
      icon: FaGlobe,
      title: 'Global Reach',
      description: 'Connecting artisans from around the world with customers who appreciate authentic craftsmanship.'
    }
  ]

  const team = [
    {
      name: 'Sarah Chen',
      role: 'Founder & CEO',
      image: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=400&fit=crop&crop=face',
      bio: 'Former art gallery curator with 15+ years in the creative industry.'
    },
    {
      name: 'Marcus Rodriguez',
      role: 'Head of Technology',
      image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
      bio: 'Tech enthusiast passionate about building platforms that empower creators.'
    },
    {
      name: 'Aisha Patel',
      role: 'Creative Director',
      image: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop&crop=face',
      bio: 'Designer and artisan advocate with deep roots in traditional crafts.'
    }
  ]

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-50">
      {/* Hero Section */}
      <section className="relative py-20 overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-r from-blue-600/10 via-purple-600/10 to-pink-600/10"></div>
        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h1 className="text-5xl md:text-6xl font-bold bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 bg-clip-text text-transparent mb-6">
            Our Story
          </h1>
          <p className="text-xl text-gray-700 max-w-3xl mx-auto leading-relaxed">
            ArtisanMart was born from a simple belief: that every handmade creation deserves a global stage. 
            We're on a mission to connect passionate artisans with customers who value authenticity, 
            craftsmanship, and the human touch behind every product.
          </p>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-16 bg-white/50 backdrop-blur-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            {stats.map((stat, index) => (
              <div key={index} className="text-center group">
                <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full mb-4 group-hover:scale-110 transition-transform duration-300">
                  <stat.icon className="w-8 h-8 text-white" />
                </div>
                <div className="text-3xl font-bold text-gray-900 mb-2">{stat.number}</div>
                <div className="text-gray-600">{stat.label}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Mission Section */}
      <section className="py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 mb-6">Our Mission</h2>
            <p className="text-xl text-gray-700 max-w-4xl mx-auto">
              To democratize access to authentic, handmade products while providing artisans with 
              the tools, platform, and audience they need to thrive in the digital economy.
            </p>
          </div>
          
          <div className="grid md:grid-cols-2 gap-12 items-center">
            <div>
              <h3 className="text-3xl font-bold text-gray-900 mb-6">Empowering Artisans</h3>
              <p className="text-lg text-gray-700 mb-6">
                We believe that traditional craftsmanship has a place in our modern world. 
                Our platform gives artisans the digital tools they need to reach customers globally 
                while preserving the authenticity and quality of their work.
              </p>
              <p className="text-lg text-gray-700">
                From jewelry makers in Bali to potters in Morocco, we're building bridges 
                between creators and customers who share our passion for meaningful, handcrafted goods.
              </p>
            </div>
            <div className="relative">
              <div className="w-full h-96 bg-gradient-to-br from-blue-400 via-purple-500 to-pink-500 rounded-2xl shadow-2xl transform rotate-3 hover:rotate-0 transition-transform duration-500"></div>
              <div className="absolute inset-0 bg-gradient-to-br from-blue-400 via-purple-500 to-pink-500 rounded-2xl shadow-2xl transform -rotate-3 hover:rotate-0 transition-transform duration-500 opacity-20"></div>
            </div>
          </div>
        </div>
      </section>

      {/* Values Section */}
      <section className="py-20 bg-white/50 backdrop-blur-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 mb-6">Our Values</h2>
            <p className="text-xl text-gray-700 max-w-3xl mx-auto">
              The principles that guide everything we do at ArtisanMart
            </p>
          </div>
          
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {values.map((value, index) => (
              <div key={index} className="group">
                <div className="bg-white rounded-2xl p-8 shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2">
                  <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full mb-6 group-hover:scale-110 transition-transform duration-300">
                    <value.icon className="w-8 h-8 text-white" />
                  </div>
                  <h3 className="text-xl font-bold text-gray-900 mb-4">{value.title}</h3>
                  <p className="text-gray-600 leading-relaxed">{value.description}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Team Section */}
      <section className="py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 mb-6">Meet Our Team</h2>
            <p className="text-xl text-gray-700 max-w-3xl mx-auto">
              The passionate individuals behind ArtisanMart who are committed to 
              revolutionizing how the world discovers and supports artisans.
            </p>
          </div>
          
          <div className="grid md:grid-cols-3 gap-8">
            {team.map((member, index) => (
              <div key={index} className="group">
                <div className="bg-white rounded-2xl p-8 shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2">
                  <div className="w-32 h-32 mx-auto mb-6 overflow-hidden rounded-full ring-4 ring-blue-100 group-hover:ring-blue-300 transition-all duration-300">
                    <img 
                      src={member.image} 
                      alt={member.name}
                      className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300"
                    />
                  </div>
                  <h3 className="text-xl font-bold text-gray-900 mb-2 text-center">{member.name}</h3>
                  <p className="text-blue-600 font-semibold text-center mb-4">{member.role}</p>
                  <p className="text-gray-600 text-center leading-relaxed">{member.bio}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-4xl font-bold text-white mb-6">Join Our Mission</h2>
          <p className="text-xl text-blue-100 mb-8 max-w-3xl mx-auto">
            Whether you're an artisan looking to reach new customers or a customer seeking 
            authentic, handmade products, we'd love to have you as part of our community.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <button className="px-8 py-4 bg-white text-blue-600 font-semibold rounded-full hover:bg-gray-100 transition-colors duration-300 transform hover:scale-105">
              Become an Artisan
            </button>
            <button className="px-8 py-4 border-2 border-white text-white font-semibold rounded-full hover:bg-white hover:text-blue-600 transition-all duration-300 transform hover:scale-105">
              Explore Products
            </button>
          </div>
        </div>
      </section>
    </div>
  )
}

export default About
