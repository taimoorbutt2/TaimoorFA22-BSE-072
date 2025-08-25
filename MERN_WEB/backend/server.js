const express = require('express')
const mongoose = require('mongoose')
const cors = require('cors')
const helmet = require('helmet')
const rateLimit = require('express-rate-limit')
require('dotenv').config({ path: './config.env' })

const authRoutes = require('./routes/auth')
const productRoutes = require('./routes/products')
const vendorRoutes = require('./routes/vendors')
const cartRoutes = require('./routes/cart')
const orderRoutes = require('./routes/orders')
const reviewRoutes = require('./routes/reviews')
const adminRoutes = require('./routes/admin')

const app = express()
const PORT = process.env.PORT || 5000

// Security middleware
app.use(helmet())

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.'
})
app.use('/api/', limiter)

// CORS configuration
app.use(cors({
  origin: process.env.CLIENT_URL || 'http://localhost:3000',
  credentials: true
}))

// Body parsing middleware
app.use(express.json({ limit: '10mb' }))
app.use(express.urlencoded({ extended: true, limit: '10mb' }))

// Database connection
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => {
  console.log('✅ Connected to MongoDB Atlas')
})
.catch((err) => {
  console.error('❌ MongoDB connection error:', err)
  process.exit(1)
})

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'OK', 
    message: 'ArtisanMart API is running',
    timestamp: new Date().toISOString()
  })
})

// Test endpoint
app.get('/test', (req, res) => {
  res.status(200).json({ 
    message: 'Server is working!',
    timestamp: new Date().toISOString()
  })
})

// API routes
app.use('/api/auth', authRoutes)
app.use('/api/products', productRoutes)
app.use('/api/vendors', vendorRoutes)
app.use('/api/cart', cartRoutes)
app.use('/api/orders', orderRoutes)
app.use('/api/reviews', reviewRoutes)
app.use('/api/admin', adminRoutes)

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ message: 'Route not found' })
})

// Global error handler
app.use((err, req, res, next) => {
  console.error('Error:', err)
  
  if (err.name === 'ValidationError') {
    return res.status(400).json({ 
      message: 'Validation Error', 
      errors: Object.values(err.errors).map(e => e.message) 
    })
  }
  
  if (err.name === 'CastError') {
    return res.status(400).json({ message: 'Invalid ID format' })
  }
  
  if (err.code === 11000) {
    return res.status(400).json({ message: 'Duplicate field value' })
  }
  
  res.status(err.status || 500).json({ 
    message: err.message || 'Internal server error' 
  })
})

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 ArtisanMart server running on port ${PORT}`)
  console.log(`📱 Frontend: ${process.env.CLIENT_URL || 'http://localhost:3000'}`)
  console.log(`🔗 Health check: http://localhost:${PORT}/health`)
  console.log(`🌐 Server accessible on: http://0.0.0.0:${PORT}`)
})

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully')
  mongoose.connection.close(() => {
    console.log('MongoDB connection closed')
    process.exit(0)
  })
})

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully')
  mongoose.connection.close(() => {
    console.log('MongoDB connection closed')
    process.exit(0)
  })
})
