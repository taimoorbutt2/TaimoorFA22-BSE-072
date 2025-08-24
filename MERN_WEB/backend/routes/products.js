const express = require('express')
const { body, validationResult, query } = require('express-validator')
const Product = require('../models/Product')
const { auth, optionalAuth, isVendor } = require('../middleware/auth')

const router = express.Router()

// @route   GET /api/products
// @desc    Get all products with filtering and pagination
// @access  Public
router.get('/', [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('category').optional().isString().withMessage('Category must be a string'),
  query('minPrice').optional().isFloat({ min: 0 }).withMessage('Min price must be a positive number'),
  query('maxPrice').optional().isFloat({ min: 0 }).withMessage('Max price must be a positive number'),
  query('sort').optional().isIn(['price', '-price', 'rating', '-rating', 'createdAt', '-createdAt']).withMessage('Invalid sort parameter'),
  query('search').optional().isString().withMessage('Search query must be a string')
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

    const {
      page = 1,
      limit = 12,
      category,
      minPrice,
      maxPrice,
      sort = '-createdAt',
      search,
      vendorId
    } = req.query

    // Build filter object
    const filter = { isActive: true }
    
    if (category) filter.category = category
    if (vendorId) filter.vendorId = vendorId
    if (minPrice || maxPrice) {
      filter.price = {}
      if (minPrice) filter.price.$gte = parseFloat(minPrice)
      if (maxPrice) filter.price.$lte = parseFloat(maxPrice)
    }

    // Build search query
    if (search) {
      filter.$text = { $search: search }
    }

    // Calculate pagination
    const skip = (parseInt(page) - 1) * parseInt(limit)
    
    // Build sort object
    const sortObj = {}
    if (sort.startsWith('-')) {
      sortObj[sort.slice(1)] = -1
    } else {
      sortObj[sort] = 1
    }

    // Execute query
    const products = await Product.find(filter)
      .sort(sortObj)
      .skip(skip)
      .limit(parseInt(limit))
      .populate('vendorId', 'shopName logo')

    // Get total count for pagination
    const total = await Product.countDocuments(filter)

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
    console.error('Get products error:', error)
    res.status(500).json({ message: 'Server error fetching products' })
  }
})

// @route   GET /api/products/featured
// @desc    Get featured products
// @access  Public
router.get('/featured', async (req, res) => {
  try {
    const products = await Product.find({ 
      isActive: true, 
      isFeatured: true 
    })
    .sort({ rating: -1, createdAt: -1 })
    .limit(8)
    .populate('vendorId', 'shopName logo')

    res.json({ products })
  } catch (error) {
    console.error('Get featured products error:', error)
    res.status(500).json({ message: 'Server error fetching featured products' })
  }
})

// @route   GET /api/products/:id
// @desc    Get single product by ID
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const product = await Product.findById(req.params.id)
      .populate('vendorId', 'shopName logo description rating reviewCount')
      .populate({
        path: 'reviews',
        options: { limit: 5, sort: { createdAt: -1 } }
      })

    if (!product) {
      return res.status(404).json({ message: 'Product not found' })
    }

    if (!product.isActive) {
      return res.status(404).json({ message: 'Product not available' })
    }

    // Increment view count
    product.viewCount += 1
    await product.save()

    res.json({ product })
  } catch (error) {
    if (error.kind === 'ObjectId') {
      return res.status(404).json({ message: 'Product not found' })
    }
    console.error('Get product error:', error)
    res.status(500).json({ message: 'Server error fetching product' })
  }
})

// @route   POST /api/products
// @desc    Create a new product
// @access  Private (Vendor only)
router.post('/', [
  auth,
  isVendor,
  body('name').trim().isLength({ min: 2, max: 100 }).withMessage('Product name must be between 2 and 100 characters'),
  body('description').trim().isLength({ min: 10, max: 2000 }).withMessage('Description must be between 10 and 2000 characters'),
  body('price').isFloat({ min: 0 }).withMessage('Price must be a positive number'),
  body('category').isIn(['Jewelry', 'Home Decor', 'Art & Prints', 'Clothing', 'Pottery', 'Textiles', 'Other']).withMessage('Invalid category'),
  body('stock').isInt({ min: 0 }).withMessage('Stock must be a non-negative integer'),
  body('images').isArray({ min: 1 }).withMessage('At least one image is required')
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

    const {
      name,
      description,
      price,
      comparePrice,
      category,
      subcategory,
      tags,
      stock,
      images,
      dimensions,
      materials,
      colors,
      sizes,
      customOptions,
      shipping,
      productionTime,
      returnPolicy
    } = req.body

    // Create product
    const product = new Product({
      name,
      description,
      price,
      comparePrice,
      category,
      subcategory,
      tags,
      stock,
      images,
      dimensions,
      materials,
      colors,
      sizes,
      customOptions,
      shipping,
      productionTime,
      returnPolicy,
      vendorId: req.vendor._id,
      vendorName: req.vendor.shopName
    })

    await product.save()

    res.status(201).json({
      message: 'Product created successfully',
      product
    })
  } catch (error) {
    console.error('Create product error:', error)
    res.status(500).json({ message: 'Server error creating product' })
  }
})

// @route   PUT /api/products/:id
// @desc    Update a product
// @access  Private (Vendor only)
router.put('/:id', [
  auth,
  isVendor,
  body('name').optional().trim().isLength({ min: 2, max: 100 }).withMessage('Product name must be between 2 and 100 characters'),
  body('description').optional().trim().isLength({ min: 10, max: 2000 }).withMessage('Description must be between 10 and 2000 characters'),
  body('price').optional().isFloat({ min: 0 }).withMessage('Price must be a positive number'),
  body('stock').optional().isInt({ min: 0 }).withMessage('Stock must be a non-negative integer')
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

    const product = await Product.findById(req.params.id)

    if (!product) {
      return res.status(404).json({ message: 'Product not found' })
    }

    // Check if vendor owns this product
    if (product.vendorId.toString() !== req.vendor._id.toString()) {
      return res.status(403).json({ message: 'Not authorized to update this product' })
    }

    // Update product
    const updatedProduct = await Product.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true, runValidators: true }
    )

    res.json({
      message: 'Product updated successfully',
      product: updatedProduct
    })
  } catch (error) {
    if (error.kind === 'ObjectId') {
      return res.status(404).json({ message: 'Product not found' })
    }
    console.error('Update product error:', error)
    res.status(500).json({ message: 'Server error updating product' })
  }
})

// @route   DELETE /api/products/:id
// @desc    Delete a product
// @access  Private (Vendor only)
router.delete('/:id', [auth, isVendor], async (req, res) => {
  try {
    const product = await Product.findById(req.params.id)

    if (!product) {
      return res.status(404).json({ message: 'Product not found' })
    }

    // Check if vendor owns this product
    if (product.vendorId.toString() !== req.vendor._id.toString()) {
      return res.status(403).json({ message: 'Not authorized to delete this product' })
    }

    // Soft delete - mark as inactive
    product.isActive = false
    await product.save()

    res.json({ message: 'Product deleted successfully' })
  } catch (error) {
    if (error.kind === 'ObjectId') {
      return res.status(404).json({ message: 'Product not found' })
    }
    console.error('Delete product error:', error)
    res.status(500).json({ message: 'Server error deleting product' })
  }
})

// @route   GET /api/products/categories
// @desc    Get all product categories with counts
// @access  Public
router.get('/categories', async (req, res) => {
  try {
    const categories = await Product.aggregate([
      { $match: { isActive: true } },
      {
        $group: {
          _id: '$category',
          count: { $sum: 1 },
          avgPrice: { $avg: '$price' },
          avgRating: { $avg: '$rating' }
        }
      },
      { $sort: { count: -1 } }
    ])

    res.json({ categories })
  } catch (error) {
    console.error('Get categories error:', error)
    res.status(500).json({ message: 'Server error fetching categories' })
  }
})

// @route   GET /api/products/search/suggestions
// @desc    Get search suggestions
// @access  Public
router.get('/search/suggestions', [
  query('q').isString().isLength({ min: 2 }).withMessage('Search query must be at least 2 characters')
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ 
        message: 'Validation failed',
        errors: errors.array() 
      })
    }

    const { q } = req.query

    const suggestions = await Product.aggregate([
      { $match: { isActive: true } },
      {
        $search: {
          autocomplete: {
            query: q,
            path: 'name',
            fuzzy: { maxEdits: 1 }
          }
        }
      },
      { $limit: 5 },
      { $project: { name: 1, category: 1, _id: 1 } }
    ])

    res.json({ suggestions })
  } catch (error) {
    console.error('Search suggestions error:', error)
    res.status(500).json({ message: 'Server error fetching search suggestions' })
  }
})

module.exports = router
