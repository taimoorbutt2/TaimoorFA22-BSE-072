const express = require('express')
const { auth, isAdmin } = require('../middleware/auth')

const router = express.Router()

// @route   GET /api/admin/dashboard
// @desc    Get admin dashboard stats
// @access  Private (Admin only)
router.get('/dashboard', [auth, isAdmin], async (req, res) => {
  try {
    res.json({ 
      stats: {
        totalUsers: 0,
        totalVendors: 0,
        totalProducts: 0,
        totalOrders: 0,
        totalRevenue: 0
      }
    })
  } catch (error) {
    res.status(500).json({ message: 'Server error' })
  }
})

module.exports = router
