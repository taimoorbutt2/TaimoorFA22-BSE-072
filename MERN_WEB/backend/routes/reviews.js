const express = require('express')
const { auth } = require('../middleware/auth')

const router = express.Router()

// @route   GET /api/reviews
// @desc    Get reviews for a product
// @access  Public
router.get('/', async (req, res) => {
  try {
    res.json({ reviews: [] })
  } catch (error) {
    res.status(500).json({ message: 'Server error' })
  }
})

module.exports = router
