const express = require('express')
const { auth } = require('../middleware/auth')

const router = express.Router()

// @route   GET /api/orders
// @desc    Get user's orders
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    res.json({ orders: [] })
  } catch (error) {
    res.status(500).json({ message: 'Server error' })
  }
})

module.exports = router
