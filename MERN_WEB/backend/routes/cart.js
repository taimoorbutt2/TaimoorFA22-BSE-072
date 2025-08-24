const express = require('express')
const { body, validationResult } = require('express-validator')
const { auth } = require('../middleware/auth')

const router = express.Router()

// @route   GET /api/cart
// @desc    Get user's cart
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    // In a real app, you'd store cart in database
    // For now, we'll return an empty cart
    res.json({ 
      items: [],
      total: 0,
      itemCount: 0
    })
  } catch (error) {
    console.error('Get cart error:', error)
    res.status(500).json({ message: 'Server error fetching cart' })
  }
})

// @route   POST /api/cart/add
// @desc    Add item to cart
// @access  Private
router.post('/add', [
  auth,
  body('productId').notEmpty().withMessage('Product ID is required'),
  body('quantity').isInt({ min: 1 }).withMessage('Quantity must be at least 1')
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ 
        message: 'Validation failed',
        errors: errors.array() 
      })
    }

    // In a real app, you'd add to database cart
    res.json({ message: 'Item added to cart successfully' })
  } catch (error) {
    console.error('Add to cart error:', error)
    res.status(500).json({ message: 'Server error adding to cart' })
  }
})

module.exports = router
