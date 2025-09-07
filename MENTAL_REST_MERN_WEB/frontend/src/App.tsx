import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';

// Hero Section Component
const HeroSection = () => {
  const [isVisible, setIsVisible] = useState(false);
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 });

  useEffect(() => {
    setIsVisible(true);
    
    const handleMouseMove = (e: MouseEvent) => {
      setMousePosition({ x: e.clientX, y: e.clientY });
    };

    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, []);

  return (
    <div className="relative min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50 overflow-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 bg-[url('https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80')] bg-cover bg-center opacity-20"></div>
      <div className="absolute inset-0 bg-gradient-to-br from-blue-600/10 via-indigo-600/10 to-purple-600/10"></div>
      
      {/* Floating Elements with enhanced animations */}
      <div 
        className="absolute top-20 left-10 w-20 h-20 bg-blue-200/30 rounded-full blur-xl animate-pulse"
        style={{
          transform: `translate(${mousePosition.x * 0.01}px, ${mousePosition.y * 0.01}px)`,
          transition: 'transform 0.3s ease-out'
        }}
      ></div>
      <div 
        className="absolute top-40 right-20 w-32 h-32 bg-purple-200/30 rounded-full blur-xl animate-pulse delay-1000"
        style={{
          transform: `translate(${mousePosition.x * -0.008}px, ${mousePosition.y * -0.008}px)`,
          transition: 'transform 0.3s ease-out'
        }}
      ></div>
      <div 
        className="absolute bottom-20 left-1/4 w-24 h-24 bg-indigo-200/30 rounded-full blur-xl animate-pulse delay-2000"
        style={{
          transform: `translate(${mousePosition.x * 0.005}px, ${mousePosition.y * 0.005}px)`,
          transition: 'transform 0.3s ease-out'
        }}
      ></div>
      
      {/* Additional floating particles */}
      <div className="absolute top-1/3 right-1/3 w-4 h-4 bg-blue-300/40 rounded-full animate-bounce delay-300"></div>
      <div className="absolute top-2/3 left-1/3 w-3 h-3 bg-purple-300/40 rounded-full animate-bounce delay-700"></div>
      <div className="absolute top-1/2 right-1/4 w-2 h-2 bg-indigo-300/40 rounded-full animate-bounce delay-1000"></div>
      
      <div className="relative z-10 container mx-auto px-4 py-20">
      <div className="max-w-4xl mx-auto text-center">
        {/* Logo/Brand */}
        <div className={`mb-8 transition-all duration-1000 ${isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'}`}>
          <div className="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl shadow-lg mb-6 hover:scale-110 hover:rotate-3 transition-all duration-300 cursor-pointer group">
            <svg className="w-10 h-10 text-white group-hover:scale-110 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
            </svg>
          </div>
          <h1 className={`text-6xl md:text-7xl font-bold bg-gradient-to-r from-blue-600 via-purple-600 to-indigo-600 bg-clip-text text-transparent mb-4 transition-all duration-1000 delay-200 ${isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'}`}>
            MindSpace
          </h1>
          <p className={`text-xl md:text-2xl text-gray-600 font-light transition-all duration-1000 delay-400 ${isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'}`}>
            Your Personal Mental Wellness Journey
          </p>
        </div>

        {/* Main CTA */}
        <div className={`mb-12 transition-all duration-1000 delay-600 ${isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'}`}>
          <p className="text-lg text-gray-500 mb-8 max-w-2xl mx-auto leading-relaxed">
            Track your mood, journal your thoughts, and discover personalized insights 
            to nurture your mental well-being with AI-powered guidance.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <button className="px-8 py-4 bg-gradient-to-r from-blue-500 to-purple-600 text-white font-semibold rounded-xl shadow-lg hover:shadow-xl transform hover:-translate-y-1 hover:scale-105 transition-all duration-300 relative overflow-hidden group">
              <span className="relative z-10">Start Your Journey</span>
              <div className="absolute inset-0 bg-gradient-to-r from-purple-600 to-blue-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            </button>
            <button className="px-8 py-4 border-2 border-gray-300 text-gray-700 font-semibold rounded-xl hover:border-blue-500 hover:text-blue-600 hover:bg-blue-50 transform hover:-translate-y-1 hover:scale-105 transition-all duration-300">
              Learn More
            </button>
          </div>
        </div>

        {/* Stats */}
        <div className={`grid grid-cols-1 md:grid-cols-3 gap-8 max-w-3xl mx-auto transition-all duration-1000 delay-800 ${isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'}`}>
          <div className="text-center group cursor-pointer">
            <div className="text-3xl font-bold text-blue-600 mb-2 group-hover:scale-110 transition-transform duration-300">10K+</div>
            <div className="text-gray-600 group-hover:text-blue-600 transition-colors duration-300">Happy Users</div>
          </div>
          <div className="text-center group cursor-pointer">
            <div className="text-3xl font-bold text-purple-600 mb-2 group-hover:scale-110 transition-transform duration-300">50K+</div>
            <div className="text-gray-600 group-hover:text-purple-600 transition-colors duration-300">Journal Entries</div>
          </div>
          <div className="text-center group cursor-pointer">
            <div className="text-3xl font-bold text-indigo-600 mb-2 group-hover:scale-110 transition-transform duration-300">95%</div>
            <div className="text-gray-600 group-hover:text-indigo-600 transition-colors duration-300">Satisfaction Rate</div>
          </div>
        </div>
      </div>
    </div>
  </div>
  );
};

// Features Section
const FeaturesSection = () => {
  const [visibleFeatures, setVisibleFeatures] = useState<number[]>([]);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const index = parseInt(entry.target.getAttribute('data-index') || '0');
            setTimeout(() => {
              setVisibleFeatures(prev => [...prev, index]);
            }, index * 100);
          }
        });
      },
      { threshold: 0.1 }
    );

    const featureCards = document.querySelectorAll('[data-feature-index]');
    featureCards.forEach(card => observer.observe(card));

    return () => observer.disconnect();
  }, []);

  return (
    <div className="py-20 bg-white">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <h2 className="text-4xl font-bold text-gray-900 mb-4 animate-fade-in-up">
            Everything You Need for Mental Wellness
          </h2>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto animate-fade-in-up delay-200">
            Comprehensive tools and insights to support your mental health journey
          </p>
        </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {/* Feature 1 */}
        <div 
          data-feature-index="0"
          className={`group p-8 rounded-2xl bg-gradient-to-br from-blue-50 to-indigo-50 hover:shadow-xl transition-all duration-500 transform hover:-translate-y-2 hover:scale-105 ${
            visibleFeatures.includes(0) ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'
          }`}
        >
          <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 group-hover:rotate-6 transition-all duration-300 shadow-lg">
            <svg className="w-8 h-8 text-white group-hover:scale-110 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
          </div>
          <h3 className="text-xl font-semibold text-gray-900 mb-3 group-hover:text-blue-600 transition-colors duration-300">Smart Journaling</h3>
          <p className="text-gray-600 leading-relaxed group-hover:text-gray-700 transition-colors duration-300">
            Express your thoughts with guided prompts and AI-powered insights to understand your mental patterns.
          </p>
        </div>

        {/* Feature 2 */}
        <div 
          data-feature-index="1"
          className={`group p-8 rounded-2xl bg-gradient-to-br from-purple-50 to-pink-50 hover:shadow-xl transition-all duration-500 transform hover:-translate-y-2 hover:scale-105 ${
            visibleFeatures.includes(1) ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'
          }`}
        >
          <div className="w-16 h-16 bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 group-hover:rotate-6 transition-all duration-300 shadow-lg">
            <svg className="w-8 h-8 text-white group-hover:scale-110 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
          </div>
          <h3 className="text-xl font-semibold text-gray-900 mb-3 group-hover:text-purple-600 transition-colors duration-300">Mood Tracking</h3>
          <p className="text-gray-600 leading-relaxed group-hover:text-gray-700 transition-colors duration-300">
            Visualize your emotional journey with beautiful charts and discover patterns in your well-being.
          </p>
        </div>

        {/* Feature 3 */}
        <div 
          data-feature-index="2"
          className={`group p-8 rounded-2xl bg-gradient-to-br from-green-50 to-emerald-50 hover:shadow-xl transition-all duration-500 transform hover:-translate-y-2 hover:scale-105 ${
            visibleFeatures.includes(2) ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'
          }`}
        >
          <div className="w-16 h-16 bg-gradient-to-br from-green-500 to-green-600 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 group-hover:rotate-6 transition-all duration-300 shadow-lg">
            <svg className="w-8 h-8 text-white group-hover:scale-110 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
            </svg>
          </div>
          <h3 className="text-xl font-semibold text-gray-900 mb-3 group-hover:text-green-600 transition-colors duration-300">AI Insights</h3>
          <p className="text-gray-600 leading-relaxed group-hover:text-gray-700 transition-colors duration-300">
            Get personalized recommendations and insights powered by advanced AI to support your mental health.
          </p>
        </div>

        {/* Feature 4 */}
        <div 
          data-feature-index="3"
          className={`group p-8 rounded-2xl bg-gradient-to-br from-orange-50 to-red-50 hover:shadow-xl transition-all duration-500 transform hover:-translate-y-2 hover:scale-105 ${
            visibleFeatures.includes(3) ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'
          }`}
        >
          <div className="w-16 h-16 bg-gradient-to-br from-orange-500 to-orange-600 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 group-hover:rotate-6 transition-all duration-300 shadow-lg">
            <svg className="w-8 h-8 text-white group-hover:scale-110 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
            </svg>
          </div>
          <h3 className="text-xl font-semibold text-gray-900 mb-3 group-hover:text-orange-600 transition-colors duration-300">Community Support</h3>
          <p className="text-gray-600 leading-relaxed group-hover:text-gray-700 transition-colors duration-300">
            Connect with others on similar journeys in a safe, anonymous community space.
          </p>
        </div>

        {/* Feature 5 */}
        <div 
          data-feature-index="4"
          className={`group p-8 rounded-2xl bg-gradient-to-br from-teal-50 to-cyan-50 hover:shadow-xl transition-all duration-500 transform hover:-translate-y-2 hover:scale-105 ${
            visibleFeatures.includes(4) ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'
          }`}
        >
          <div className="w-16 h-16 bg-gradient-to-br from-teal-500 to-teal-600 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 group-hover:rotate-6 transition-all duration-300 shadow-lg">
            <svg className="w-8 h-8 text-white group-hover:scale-110 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
            </svg>
          </div>
          <h3 className="text-xl font-semibold text-gray-900 mb-3 group-hover:text-teal-600 transition-colors duration-300">Wellness Resources</h3>
          <p className="text-gray-600 leading-relaxed group-hover:text-gray-700 transition-colors duration-300">
            Access curated mindfulness exercises, breathing techniques, and mental health resources.
          </p>
        </div>

        {/* Feature 6 */}
        <div 
          data-feature-index="5"
          className={`group p-8 rounded-2xl bg-gradient-to-br from-indigo-50 to-blue-50 hover:shadow-xl transition-all duration-500 transform hover:-translate-y-2 hover:scale-105 ${
            visibleFeatures.includes(5) ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'
          }`}
        >
          <div className="w-16 h-16 bg-gradient-to-br from-indigo-500 to-indigo-600 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 group-hover:rotate-6 transition-all duration-300 shadow-lg">
            <svg className="w-8 h-8 text-white group-hover:scale-110 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <h3 className="text-xl font-semibold text-gray-900 mb-3 group-hover:text-indigo-600 transition-colors duration-300">Progress Tracking</h3>
          <p className="text-gray-600 leading-relaxed group-hover:text-gray-700 transition-colors duration-300">
            Monitor your mental health progress with detailed analytics and milestone celebrations.
          </p>
        </div>
      </div>
    </div>
  </div>
);

// Testimonials Section
const TestimonialsSection = () => {
  const [visibleTestimonials, setVisibleTestimonials] = useState<number[]>([]);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const index = parseInt(entry.target.getAttribute('data-testimonial-index') || '0');
            setTimeout(() => {
              setVisibleTestimonials(prev => [...prev, index]);
            }, index * 200);
          }
        });
      },
      { threshold: 0.1 }
    );

    const testimonialCards = document.querySelectorAll('[data-testimonial-index]');
    testimonialCards.forEach(card => observer.observe(card));

    return () => observer.disconnect();
  }, []);

  return (
    <div className="py-20 bg-gradient-to-br from-gray-50 to-blue-50">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <h2 className="text-4xl font-bold text-gray-900 mb-4 animate-fade-in-up">
            What Our Users Say
          </h2>
          <p className="text-xl text-gray-600 animate-fade-in-up delay-200">
            Real stories from people who've transformed their mental wellness
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div 
            data-testimonial-index="0"
            className={`bg-white p-8 rounded-2xl shadow-lg hover:shadow-xl transition-all duration-500 transform hover:-translate-y-2 hover:scale-105 group ${
              visibleTestimonials.includes(0) ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'
            }`}
          >
            <div className="flex items-center mb-4">
              <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center text-white font-bold group-hover:scale-110 transition-transform duration-300">
                S
              </div>
              <div className="ml-4">
                <h4 className="font-semibold text-gray-900 group-hover:text-blue-600 transition-colors duration-300">Sarah M.</h4>
                <p className="text-gray-600 text-sm">Student</p>
              </div>
            </div>
            <p className="text-gray-700 italic group-hover:text-gray-800 transition-colors duration-300">
              "MindSpace helped me understand my anxiety patterns. The AI insights are incredibly accurate and the journaling prompts are so helpful."
            </p>
          </div>

          <div 
            data-testimonial-index="1"
            className={`bg-white p-8 rounded-2xl shadow-lg hover:shadow-xl transition-all duration-500 transform hover:-translate-y-2 hover:scale-105 group ${
              visibleTestimonials.includes(1) ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'
            }`}
          >
            <div className="flex items-center mb-4">
              <div className="w-12 h-12 bg-gradient-to-br from-green-500 to-teal-600 rounded-full flex items-center justify-center text-white font-bold group-hover:scale-110 transition-transform duration-300">
                M
              </div>
              <div className="ml-4">
                <h4 className="font-semibold text-gray-900 group-hover:text-green-600 transition-colors duration-300">Michael R.</h4>
                <p className="text-gray-600 text-sm">Professional</p>
              </div>
            </div>
            <p className="text-gray-700 italic group-hover:text-gray-800 transition-colors duration-300">
              "The mood tracking feature is amazing. I can see my progress over time and it motivates me to keep working on my mental health."
            </p>
          </div>

          <div 
            data-testimonial-index="2"
            className={`bg-white p-8 rounded-2xl shadow-lg hover:shadow-xl transition-all duration-500 transform hover:-translate-y-2 hover:scale-105 group ${
              visibleTestimonials.includes(2) ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'
            }`}
          >
            <div className="flex items-center mb-4">
              <div className="w-12 h-12 bg-gradient-to-br from-purple-500 to-pink-600 rounded-full flex items-center justify-center text-white font-bold group-hover:scale-110 transition-transform duration-300">
                A
              </div>
              <div className="ml-4">
                <h4 className="font-semibold text-gray-900 group-hover:text-purple-600 transition-colors duration-300">Alex K.</h4>
                <p className="text-gray-600 text-sm">Parent</p>
              </div>
            </div>
            <p className="text-gray-700 italic group-hover:text-gray-800 transition-colors duration-300">
              "As a busy parent, MindSpace gives me the tools I need to prioritize my mental wellness. The community support is incredible."
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

// CTA Section
const CTASection = () => {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setIsVisible(true);
          }
        });
      },
      { threshold: 0.1 }
    );

    const ctaSection = document.querySelector('[data-cta-section]');
    if (ctaSection) observer.observe(ctaSection);

    return () => observer.disconnect();
  }, []);

  return (
    <div 
      data-cta-section
      className="py-20 bg-gradient-to-r from-blue-600 via-purple-600 to-indigo-600 relative overflow-hidden"
    >
      {/* Animated background elements */}
      <div className="absolute inset-0">
        <div className="absolute top-10 left-10 w-20 h-20 bg-white/10 rounded-full animate-pulse"></div>
        <div className="absolute bottom-10 right-10 w-32 h-32 bg-white/5 rounded-full animate-pulse delay-1000"></div>
        <div className="absolute top-1/2 left-1/4 w-16 h-16 bg-white/8 rounded-full animate-pulse delay-2000"></div>
      </div>
      
      <div className="container mx-auto px-4 text-center relative z-10">
        <h2 className={`text-4xl font-bold text-white mb-4 transition-all duration-1000 ${isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'}`}>
          Ready to Start Your Mental Wellness Journey?
        </h2>
        <p className={`text-xl text-blue-100 mb-8 max-w-2xl mx-auto transition-all duration-1000 delay-200 ${isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'}`}>
          Join thousands of users who are already improving their mental health with MindSpace.
        </p>
        <div className={`flex flex-col sm:flex-row gap-4 justify-center transition-all duration-1000 delay-400 ${isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'}`}>
          <button className="px-8 py-4 bg-white text-blue-600 font-semibold rounded-xl shadow-lg hover:shadow-xl transform hover:-translate-y-1 hover:scale-105 transition-all duration-300 relative overflow-hidden group">
            <span className="relative z-10">Get Started Free</span>
            <div className="absolute inset-0 bg-gradient-to-r from-blue-50 to-purple-50 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
          </button>
          <button className="px-8 py-4 border-2 border-white text-white font-semibold rounded-xl hover:bg-white hover:text-blue-600 transform hover:-translate-y-1 hover:scale-105 transition-all duration-300">
            View Demo
          </button>
        </div>
      </div>
    </div>
  );
};

// Footer
const Footer = () => (
  <footer className="bg-gray-900 text-white py-12">
    <div className="container mx-auto px-4">
      <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
        <div>
          <div className="flex items-center mb-4">
            <div className="w-8 h-8 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg flex items-center justify-center mr-3">
              <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
              </svg>
            </div>
            <span className="text-xl font-bold">MindSpace</span>
          </div>
          <p className="text-gray-400">
            Your personal mental wellness companion for a healthier, happier life.
          </p>
        </div>
        
        <div>
          <h3 className="font-semibold mb-4">Product</h3>
          <ul className="space-y-2 text-gray-400">
            <li><a href="#" className="hover:text-white transition-colors">Features</a></li>
            <li><a href="#" className="hover:text-white transition-colors">Pricing</a></li>
            <li><a href="#" className="hover:text-white transition-colors">Security</a></li>
          </ul>
        </div>
        
        <div>
          <h3 className="font-semibold mb-4">Support</h3>
          <ul className="space-y-2 text-gray-400">
            <li><a href="#" className="hover:text-white transition-colors">Help Center</a></li>
            <li><a href="#" className="hover:text-white transition-colors">Contact Us</a></li>
            <li><a href="#" className="hover:text-white transition-colors">Privacy Policy</a></li>
          </ul>
        </div>
        
        <div>
          <h3 className="font-semibold mb-4">Connect</h3>
          <ul className="space-y-2 text-gray-400">
            <li><a href="#" className="hover:text-white transition-colors">Twitter</a></li>
            <li><a href="#" className="hover:text-white transition-colors">LinkedIn</a></li>
            <li><a href="#" className="hover:text-white transition-colors">Blog</a></li>
          </ul>
        </div>
      </div>
      
      <div className="border-t border-gray-800 mt-8 pt-8 text-center text-gray-400">
        <p>&copy; 2024 MindSpace. All rights reserved.</p>
      </div>
    </div>
  </footer>
);

// Main Home Page Component
const Home = () => (
  <div className="min-h-screen">
    <HeroSection />
    <FeaturesSection />
    <TestimonialsSection />
    <CTASection />
    <Footer />
  </div>
);

// Enhanced Login component
const Login = () => {
  const [isVisible, setIsVisible] = useState(false);
  const [formData, setFormData] = useState({ email: '', password: '' });

  useEffect(() => {
    setIsVisible(true);
  }, []);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData(prev => ({
      ...prev,
      [e.target.name]: e.target.value
    }));
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50 flex items-center justify-center p-4 relative overflow-hidden">
      {/* Animated background elements */}
      <div className="absolute inset-0">
        <div className="absolute top-20 left-20 w-32 h-32 bg-blue-200/20 rounded-full blur-xl animate-pulse"></div>
        <div className="absolute bottom-20 right-20 w-40 h-40 bg-purple-200/20 rounded-full blur-xl animate-pulse delay-1000"></div>
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-24 h-24 bg-indigo-200/20 rounded-full blur-xl animate-pulse delay-2000"></div>
      </div>
      
      <div className={`max-w-md w-full bg-white rounded-2xl shadow-xl p-8 relative z-10 transition-all duration-1000 ${isVisible ? 'opacity-100 translate-y-0 scale-100' : 'opacity-0 translate-y-10 scale-95'}`}>
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl shadow-lg mb-4 hover:scale-110 hover:rotate-3 transition-all duration-300 cursor-pointer group">
            <svg className="w-8 h-8 text-white group-hover:scale-110 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
            </svg>
          </div>
          <h2 className="text-2xl font-bold text-gray-900">Welcome Back</h2>
          <p className="text-gray-600">Sign in to continue your wellness journey</p>
        </div>
        
        <form className="space-y-6">
          <div className="group">
            <label className="block text-sm font-medium text-gray-700 mb-2 group-focus-within:text-blue-600 transition-colors duration-300">Email</label>
            <input 
              type="email" 
              name="email"
              value={formData.email}
              onChange={handleInputChange}
              className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-300 hover:border-blue-300"
              placeholder="Enter your email"
            />
          </div>
          <div className="group">
            <label className="block text-sm font-medium text-gray-700 mb-2 group-focus-within:text-blue-600 transition-colors duration-300">Password</label>
            <input 
              type="password" 
              name="password"
              value={formData.password}
              onChange={handleInputChange}
              className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-300 hover:border-blue-300"
              placeholder="Enter your password"
            />
          </div>
          <button 
            type="submit"
            className="w-full py-3 bg-gradient-to-r from-blue-500 to-purple-600 text-white font-semibold rounded-xl shadow-lg hover:shadow-xl transform hover:-translate-y-1 hover:scale-105 transition-all duration-300 relative overflow-hidden group"
          >
            <span className="relative z-10">Sign In</span>
            <div className="absolute inset-0 bg-gradient-to-r from-purple-600 to-blue-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
          </button>
        </form>
        
        <div className="mt-6 text-center">
          <p className="text-gray-600">
            Don't have an account? 
            <a href="/register" className="text-blue-600 hover:text-blue-500 font-semibold ml-1 transition-colors duration-300 hover:underline">Sign up</a>
          </p>
        </div>
      </div>
    </div>
  );
};

// Enhanced Register component
const Register = () => {
  const [isVisible, setIsVisible] = useState(false);
  const [formData, setFormData] = useState({ name: '', email: '', password: '' });

  useEffect(() => {
    setIsVisible(true);
  }, []);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData(prev => ({
      ...prev,
      [e.target.name]: e.target.value
    }));
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-teal-50 to-blue-50 flex items-center justify-center p-4 relative overflow-hidden">
      {/* Animated background elements */}
      <div className="absolute inset-0">
        <div className="absolute top-20 left-20 w-32 h-32 bg-green-200/20 rounded-full blur-xl animate-pulse"></div>
        <div className="absolute bottom-20 right-20 w-40 h-40 bg-teal-200/20 rounded-full blur-xl animate-pulse delay-1000"></div>
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-24 h-24 bg-blue-200/20 rounded-full blur-xl animate-pulse delay-2000"></div>
      </div>
      
      <div className={`max-w-md w-full bg-white rounded-2xl shadow-xl p-8 relative z-10 transition-all duration-1000 ${isVisible ? 'opacity-100 translate-y-0 scale-100' : 'opacity-0 translate-y-10 scale-95'}`}>
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-green-500 to-teal-600 rounded-2xl shadow-lg mb-4 hover:scale-110 hover:rotate-3 transition-all duration-300 cursor-pointer group">
            <svg className="w-8 h-8 text-white group-hover:scale-110 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
            </svg>
          </div>
          <h2 className="text-2xl font-bold text-gray-900">Join MindSpace</h2>
          <p className="text-gray-600">Start your mental wellness journey today</p>
        </div>
        
        <form className="space-y-6">
          <div className="group">
            <label className="block text-sm font-medium text-gray-700 mb-2 group-focus-within:text-green-600 transition-colors duration-300">Full Name</label>
            <input 
              type="text" 
              name="name"
              value={formData.name}
              onChange={handleInputChange}
              className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all duration-300 hover:border-green-300"
              placeholder="Enter your full name"
            />
          </div>
          <div className="group">
            <label className="block text-sm font-medium text-gray-700 mb-2 group-focus-within:text-green-600 transition-colors duration-300">Email</label>
            <input 
              type="email" 
              name="email"
              value={formData.email}
              onChange={handleInputChange}
              className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all duration-300 hover:border-green-300"
              placeholder="Enter your email"
            />
          </div>
          <div className="group">
            <label className="block text-sm font-medium text-gray-700 mb-2 group-focus-within:text-green-600 transition-colors duration-300">Password</label>
            <input 
              type="password" 
              name="password"
              value={formData.password}
              onChange={handleInputChange}
              className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all duration-300 hover:border-green-300"
              placeholder="Create a password"
            />
          </div>
          <button 
            type="submit"
            className="w-full py-3 bg-gradient-to-r from-green-500 to-teal-600 text-white font-semibold rounded-xl shadow-lg hover:shadow-xl transform hover:-translate-y-1 hover:scale-105 transition-all duration-300 relative overflow-hidden group"
          >
            <span className="relative z-10">Create Account</span>
            <div className="absolute inset-0 bg-gradient-to-r from-teal-600 to-green-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
          </button>
        </form>
        
        <div className="mt-6 text-center">
          <p className="text-gray-600">
            Already have an account? 
            <a href="/login" className="text-green-600 hover:text-green-500 font-semibold ml-1 transition-colors duration-300 hover:underline">Sign in</a>
          </p>
        </div>
      </div>
    </div>
  );
};

function App() {
  return (
    <Router>
      <div className="App">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route path="*" element={<Home />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
