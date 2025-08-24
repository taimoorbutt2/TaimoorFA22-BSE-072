const express = require('express')
const { body, validationResult } = require('express-validator')
const Vendor = require('../models/Vendor')
const User = require('../models/User')
const { auth, isVendor } = require('../middleware/auth')

const router = express.Router()

// @route   GET /api/vendors
// @desc    Get all approved vendors
// @access  Public
router.get('/', async (req, res) => {
  try {
    const vendors = await Vendor.find({ 
      isApproved: true, 
      isActive: true 
    })
    .select('shopName description logo category location rating reviewCount totalSales')
    .sort({ rating: -1, totalSales: -1 })

    res.json({ vendors })
  } catch (error) {
    console.error('Get vendors error:', error)
    res.status(500).json({ message: 'Server error fetching vendors' })
  }
})

// @route   GET /api/vendors/:id
// @desc    Get vendor profile by ID
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const vendor = await Vendor.findById(req.params.id)
      .populate('userId', 'name email avatar createdAt')

    if (!vendor) {
      return res.status(404).json({ message: 'Vendor not found' })
    }

    if (!vendor.isApproved || !vendor.isActive) {
      return res.status(404).json({ message: 'Vendor profile not available' })
    }

    res.json({ vendor })
  } catch (error) {
    if (error.kind === 'ObjectId') {
      return res.status(404).json({ message: 'Vendor not found' })
    }
    console.error('Get vendor error:', error)
    res.status(500).json({ message: 'Server error fetching vendor' })
  }
})

// @route   POST /api/vendors
// @desc    Create vendor profile
// @access  Private
router.post('/', [
  auth,
  body('shopName').trim().isLength({ min: 2, max: 100 }).withMessage('Shop name must be between 2 and 100 characters'),
  body('description').trim().isLength({ min: 10, max: 1000 }).withMessage('Description must be between 10 and 1000 characters'),
  body('category').isIn(['Jewelry', 'Home Decor', 'Art & Prints', 'Clothing', 'Pottery', 'Textiles', 'Other']).withMessage('Invalid category')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ 
        message: 'Validation failed',
        errors: errors.array() 
      })
    }

    // Check if user already has a vendor profile
    const existingVendor = await Vendor.findOne({ userId: req.user._id })
    if (existingVendor) {
      return res.status(400).json({ message: 'Vendor profile already exists' })
    }

    // Check if user role is vendor
    if (req.user.role !== 'vendor') {
      return res.status(400).json({ message: 'User role must be vendor to create vendor profile' })
    }

    const {
      shopName,
      description,
      logo,
      banner,
      category,
      tags,
      location,
      contactInfo,
      businessHours,
      policies,
      commissionRate
    } = req.body

    // Create vendor profile
    const vendor = new Vendor({
      userId: req.user._id,
      shopName,
      description,
      logo,
      banner,
      category,
      tags,
      location,
      contactInfo,
      businessHours,
      policies,
      commissionRate: commissionRate || 0.10
    })

    await vendor.save()

    res.status(201).json({
      message: 'Vendor profile created successfully. Pending approval.',
      vendor
    })
  } catch (error) {
    console.error('Create vendor error:', error)
    res.status(500).json({ message: 'Server error creating vendor profile' })
  }
})

// @route   PUT /api/vendors/:id
// @desc    Update vendor profile
// @access  Private (Vendor only)
router.put('/:id', [
  auth,
  isVendor,
  body('shopName').optional().trim().isLength({ min: 2, max: 100 }).withMessage('Shop name must be between 2 and 100 characters'),
  body('description').optional().trim().isLength({ min: 10, max: 1000 }).withMessage('Description must be between 10 and 1000 characters')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ 
        message: 'Validation failed',
        errors: errors.array() 
      })
    }

    const vendor = await Vendor.findById(req.params.id)

    if (!vendor) {
      return res.status(404).json({ message: 'Vendor profile not found' })
    }

    // Check if vendor owns this profile
    if (vendor.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized to update this vendor profile' })
    }

    // Update vendor profile
    const updatedVendor = await Vendor.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true, runValidators: true }
    )

    res.json({
      message: 'Vendor profile updated successfully',
      vendor: updatedVendor
    })
  } catch (error) {
    if (error.kind === 'ObjectId') {
      return res.status(404).json({ message: 'Vendor profile not found' })
    }
    console.error('Update vendor error:', error)
    res.status(500).json({ message: 'Server error updating vendor profile' })
  }
})

// @route   GET /api/vendors/:id/products
// @desc    Get products by vendor
// @access  Public
router.get('/:id/products', async (req, res) => {
  try {
    const { page = 1, limit = 12 } = req.query
    const skip = (parseInt(page) - 1) * parseInt(limit)

    const Product = require('../models/Product')
    const products = await Product.find({ 
      vendorId: req.params.id,
      isActive: true 
    })
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(parseInt(limit))

    const total = await Product.countDocuments({ 
      vendorId: req.params.id,
      isActive: true 
    })

    res.json({
      products,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / parseInt(limit)),
        totalProducts: total,
        hasNext: skip + products.length < total,
        hasPrev: page > 1
      }
    })
  } catch (error) {
    if (error.kind === 'ObjectId') {
      return res.status(404).json({ message: 'Vendor not found' })
    }
    console.error('Get vendor products error:', error)
    res.status(500).json({ message: 'Server error fetching vendor products' })
  }
})

// @route   GET /api/vendors/:id/reviews
// @desc    Get reviews for vendor
// @access  Public
router.get('/:id/reviews', async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query
    const skip = (parseInt(page) - 1) * parseInt(limit)

    const Review = require('../models/Review')
    const Product = require('../models/Product')

    // Get vendor's product IDs
    const vendorProducts = await Product.find({ 
      vendorId: req.params.id,
      isActive: true 
    }).select('_id')

    const productIds = vendorProducts.map(p => p._id)

    // Get reviews for vendor's products
    const reviews = await Review.find({
      productId: { $in: productIds },
      isActive: true
    })
    .populate('productId', 'name images')
    .populate('customerId', 'name avatar')
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(parseInt(limit))

    const total = await Review.countDocuments({
      productId: { $in: productIds },
      isActive: true
    })

    res.json({
      reviews,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / parseInt(limit)),
        totalReviews: total,
        hasNext: skip + reviews.length < total,
        hasPrev: page > 1
      }
    })
  } catch (error) {
    if (error.kind === 'ObjectId') {
      return res.status(404).json({ message: 'Vendor not found' })
    }
    console.error('Get vendor reviews error:', error)
    res.status(500).json({ message: 'Server error fetching vendor reviews' })
  }
})

// @route   GET /api/vendors/search
// @desc    Search vendors
// @access  Public
router.get('/search', async (req, res) => {
  try {
    const { q, category, location } = req.query
    const filter = { isApproved: true, isActive: true }

    if (category) filter.category = category
    if (location) {
      filter.$or = [
        { 'location.city': { $regex: location, $options: 'i' } },
        { 'location.state': { $regex: location, $options: 'i' } },
        { 'location.country': { $regex: location, $options: 'i' } }
      ]
    }

    if (q) {
      filter.$or = [
        { shopName: { $regex: q, $options: 'i' } },
        { description: { $regex: q, $options: 'i' } },
        { tags: { $in: [new RegExp(q, 'i')] } }
      ]
    }

    const vendors = await Vendor.find(filter)
      .select('shopName description logo category location rating reviewCount totalSales')
      .sort({ rating: -1, totalSales: -1 })
      .limit(20)

    res.json({ vendors })
  } catch (error) {
    console.error('Search vendors error:', error)
    res.status(500).json({ message: 'Server error searching vendors' })
  }
})

// @route   GET /api/vendors/categories
// @desc    Get vendor categories with counts
// @access  Public
router.get('/categories', async (req, res) => {
  try {
    const categories = await Vendor.aggregate([
      { $match: { isApproved: true, isActive: true } },
      {
        $group: {
          _id: '$category',
          count: { $sum: 1 },
          avgRating: { $avg: '$rating' }
        }
      },
      { $sort: { count: -1 } }
    ])

    res.json({ categories })
  } catch (error) {
    console.error('Get vendor categories error:', error)
    res.status(500).json({ message: 'Server error fetching vendor categories' })
  }
})

module.exports = router
