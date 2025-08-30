const express = require('express');
const router = express.Router();
const Favorite = require('../models/Favorite');
const Product = require('../models/Product');
const { auth } = require('../middleware/auth');

// Add a product to favorites
router.post('/add', auth, async (req, res) => {
  try {
    const { productId } = req.body;
    const userId = req.user.id;

    if (!productId) {
      return res.status(400).json({
        success: false,
        message: 'Product ID is required'
      });
    }

    // Check if product exists
    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Check if already favorited
    const existingFavorite = await Favorite.findOne({ user: userId, product: productId });
    if (existingFavorite) {
      return res.status(400).json({
        success: false,
        message: 'Product is already in your favorites'
      });
    }

    // Add to favorites
    const favorite = new Favorite({
      user: userId,
      product: productId
    });

    await favorite.save();

    res.status(201).json({
      success: true,
      message: 'Product added to favorites successfully',
      favorite
    });

  } catch (error) {
    console.error('Error adding to favorites:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Remove a product from favorites
router.delete('/remove/:productId', auth, async (req, res) => {
  try {
    const { productId } = req.params;
    const userId = req.user.id;

    const favorite = await Favorite.findOneAndDelete({ user: userId, product: productId });
    
    if (!favorite) {
      return res.status(404).json({
        success: false,
        message: 'Product not found in favorites'
      });
    }

    res.json({
      success: true,
      message: 'Product removed from favorites successfully'
    });

  } catch (error) {
    console.error('Error removing from favorites:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Get user's favorites with product details
router.get('/my-favorites', auth, async (req, res) => {
  try {
    const userId = req.user.id;
    const { page = 1, limit = 12 } = req.query;

    const favorites = await Favorite.find({ user: userId })
      .populate({
        path: 'product',
        select: 'name price images category rating reviewCount stock vendorName inStock'
      })
      .sort({ addedAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Favorite.countDocuments({ user: userId });

    res.json({
      success: true,
      favorites,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / limit),
        totalFavorites: total,
        hasNext: page * limit < total,
        hasPrev: page > 1
      }
    });

  } catch (error) {
    console.error('Error fetching favorites:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Check if a product is favorited by user
router.get('/check/:productId', auth, async (req, res) => {
  try {
    const { productId } = req.params;
    const userId = req.user.id;

    const favorite = await Favorite.findOne({ user: userId, product: productId });
    
    res.json({
      success: true,
      isFavorited: !!favorite
    });

  } catch (error) {
    console.error('Error checking favorite status:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Get favorite count for a product
router.get('/count/:productId', async (req, res) => {
  try {
    const { productId } = req.params;

    const count = await Favorite.countDocuments({ product: productId });
    
    res.json({
      success: true,
      count
    });

  } catch (error) {
    console.error('Error getting favorite count:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

module.exports = router;
