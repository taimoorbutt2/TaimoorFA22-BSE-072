const jwt = require('jsonwebtoken')
const User = require('../models/User')

const auth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '')
    
    if (!token) {
      return res.status(401).json({ message: 'Access denied. No token provided.' })
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET)
    const user = await User.findById(decoded.userId).select('-password')
    
    if (!user) {
      return res.status(401).json({ message: 'Invalid token. User not found.' })
    }

    if (!user.isActive) {
      return res.status(401).json({ message: 'Account is deactivated.' })
    }

    req.user = user
    next()
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ message: 'Invalid token.' })
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Token expired.' })
    }
    res.status(500).json({ message: 'Server error.' })
  }
}

const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ message: 'Access denied. User not authenticated.' })
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ 
        message: 'Access denied. Insufficient permissions.' 
      })
    }

    next()
  }
}

const isVendor = async (req, res, next) => {
  try {
    if (req.user.role !== 'vendor' && req.user.role !== 'admin') {
      return res.status(403).json({ 
        message: 'Access denied. Vendor role required.' 
      })
    }

    if (req.user.role === 'vendor') {
      const Vendor = require('../models/Vendor')
      const vendor = await Vendor.findOne({ userId: req.user._id })
      
      if (!vendor) {
        return res.status(403).json({ 
          message: 'Vendor profile not found. Please complete your vendor profile.' 
        })
      }

      if (!vendor.isApproved) {
        return res.status(403).json({ 
          message: 'Vendor account is pending approval.' 
        })
      }

      req.vendor = vendor
    }

    next()
  } catch (error) {
    res.status(500).json({ message: 'Server error.' })
  }
}

const isAdmin = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ 
      message: 'Access denied. Admin role required.' 
    })
  }
  next()
}

const optionalAuth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '')
    
    if (token) {
      const decoded = jwt.verify(token, process.env.JWT_SECRET)
      const user = await User.findById(decoded.userId).select('-password')
      
      if (user && user.isActive) {
        req.user = user
      }
    }
    
    next()
  } catch (error) {
    // Continue without authentication for optional routes
    next()
  }
}

module.exports = {
  auth,
  authorize,
  isVendor,
  isAdmin,
  optionalAuth
}
