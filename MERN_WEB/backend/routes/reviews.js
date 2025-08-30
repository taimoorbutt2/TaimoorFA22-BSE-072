const express = require('express');
const router = express.Router();
const Review = require('../models/Review');
const Product = require('../models/Product');
const { auth } = require('../middleware/auth');
const mongoose = require('mongoose');

// Create a new review
router.post('/', auth, async (req, res) => {
  try {
    const { productId, rating, comment } = req.body;
    const userId = req.user.id;
    
    console.log('Creating review with data:', { productId, rating, comment, userId })

    if (req.user.role !== 'customer') {
      return res.status(403).json({ 
        success: false, 
        message: 'Only customers can leave reviews' 
      });
    }

    if (!productId || !rating || !comment) {
      return res.status(400).json({
        success: false,
        message: 'Product ID, rating, and comment are required'
      });
    }

    if (rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be between 1 and 5'
      });
    }

    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    const existingReview = await Review.findOne({ user: userId, product: productId });
    if (existingReview) {
      return res.status(400).json({
        success: false,
        message: 'You have already reviewed this product'
      });
    }

    const review = new Review({
      product: productId,
      user: userId,
      userName: req.user.name,
      rating,
      comment
    });

    console.log('Saving review:', review)
    console.log('Review product field type:', typeof review.product, 'value:', review.product)
    console.log('Review user field type:', typeof review.user, 'value:', review.user)
    
    await review.save();
    console.log('Review saved successfully with ID:', review._id, 'now updating product rating')
    console.log('Saved review product field:', review.product)
    
    await updateProductRating(productId);
    
    // Verify the review was saved by fetching it back
    const savedReview = await Review.findById(review._id);
    console.log('Verification - saved review:', savedReview)
    
    // Also verify the product was updated
    const updatedProduct = await Product.findById(productId);
    console.log('Verification - updated product rating:', updatedProduct?.rating, 'reviewCount:', updatedProduct?.reviewCount)

    res.status(201).json({
      success: true,
      message: 'Review created successfully',
      review
    });

  } catch (error) {
    console.error('Error creating review:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Get all reviews for a product
router.get('/product/:productId', async (req, res) => {
  try {
    const { productId } = req.params;
    const { page = 1, limit = 10, sort = 'newest' } = req.query;
    
    console.log('Fetching reviews for productId:', productId)
    console.log('ProductId type:', typeof productId)

    if (!productId) {
      return res.status(400).json({
        success: false,
        message: 'Product ID is required'
      });
    }

    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    let sortObj = {};
    switch (sort) {
      case 'newest':
        sortObj = { createdAt: -1 };
        break;
      case 'oldest':
        sortObj = { createdAt: 1 };
        break;
      case 'highest':
        sortObj = { rating: -1 };
        break;
      case 'lowest':
        sortObj = { rating: 1 };
        break;
      default:
        sortObj = { createdAt: -1 };
    }

    const reviews = await Review.find({ product: productId })
      .sort(sortObj)
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .populate('user', 'name');

    const total = await Review.countDocuments({ product: productId });
    
    console.log('Found reviews:', reviews.length)
    console.log('Total reviews count:', total)
    console.log('Sample review data:', reviews[0] ? {
      id: reviews[0]._id,
      product: reviews[0].product,
      user: reviews[0].user,
      rating: reviews[0].rating
    } : 'No reviews')

    const ratingStats = await Review.aggregate([
      { $match: { product: productId } },
      {
        $group: {
          _id: null,
          avgRating: { $avg: '$rating' },
          totalReviews: { $sum: 1 },
          ratingDistribution: { $push: '$rating' }
        }
      }
    ]);

    let ratingDistribution = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
    if (ratingStats.length > 0) {
      ratingStats[0].ratingDistribution.forEach(rating => {
        ratingDistribution[rating]++;
      });
    }

    res.json({
      success: true,
      reviews,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / limit),
        totalReviews: total,
        hasNext: page * limit < total,
        hasPrev: page > 1
      },
      stats: {
        averageRating: ratingStats.length > 0 ? Math.round(ratingStats[0].avgRating * 10) / 10 : 0,
        totalReviews: ratingStats.length > 0 ? ratingStats[0].totalReviews : 0,
        ratingDistribution
      }
    });

  } catch (error) {
    console.error('Error fetching reviews:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Update a review
router.put('/:reviewId', auth, async (req, res) => {
  try {
    const { reviewId } = req.params;
    const { rating, comment } = req.body;
    const userId = req.user.id;

    const review = await Review.findById(reviewId);
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found'
      });
    }

    if (review.user.toString() !== userId) {
      return res.status(403).json({
        success: false,
        message: 'You can only edit your own reviews'
      });
    }

    if (rating !== undefined) review.rating = rating;
    if (comment !== undefined) review.comment = comment;

    await review.save();
    await updateProductRating(review.product);

    res.json({
      success: true,
      message: 'Review updated successfully',
      review
    });

  } catch (error) {
    console.error('Error updating review:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Delete a review
router.delete('/:reviewId', auth, async (req, res) => {
  try {
    const { reviewId } = req.params;
    const userId = req.user.id;

    const review = await Review.findById(reviewId);
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found'
      });
    }

    if (review.user.toString() !== userId) {
      return res.status(403).json({
        success: false,
        message: 'You can only delete your own reviews'
      });
    }

    const productId = review.product;
    await Review.findByIdAndDelete(reviewId);
    await updateProductRating(productId);

    res.json({
      success: true,
      message: 'Review deleted successfully'
    });

  } catch (error) {
    console.error('Error deleting review:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Helper function to update product rating
async function updateProductRating(productId) {
  try {
    console.log('Updating product rating for productId:', productId)
    console.log('ProductId type:', typeof productId)
    
    // Convert to ObjectId if it's a string
    const objectId = typeof productId === 'string' ? new mongoose.Types.ObjectId(productId) : productId
    console.log('Converted ObjectId:', objectId)
    
    // First, let's check if there are any reviews for this product
    const reviewCount = await Review.countDocuments({ product: objectId })
    console.log('Total reviews found for product:', reviewCount)
    
    const stats = await Review.aggregate([
      { $match: { product: objectId } },
      {
        $group: {
          _id: null,
          avgRating: { $avg: '$rating' },
          totalReviews: { $sum: 1 }
        }
      }
    ]);

    console.log('Review stats calculated:', stats)

    if (stats.length > 0) {
      const newRating = Math.round(stats[0].avgRating * 10) / 10
      const newReviewCount = stats[0].totalReviews
      
      console.log('Updating product with rating:', newRating, 'and reviewCount:', newReviewCount)
      
      const updateResult = await Product.findByIdAndUpdate(productId, {
        rating: newRating,
        reviewCount: newReviewCount
      }, { new: true });
      
      console.log('Product rating updated successfully:', updateResult)
    } else {
      console.log('No reviews found, setting rating to 0')
      const updateResult = await Product.findByIdAndUpdate(productId, {
        rating: 0,
        reviewCount: 0
      }, { new: true });
      
      console.log('Product rating reset to 0:', updateResult)
    }
  } catch (error) {
    console.error('Error updating product rating:', error);
    console.error('Error details:', error.message);
  }
}

module.exports = router;
