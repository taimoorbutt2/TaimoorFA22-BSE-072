const express = require('express');
const router = express.Router();
const Follow = require('../models/Follow');
const User = require('../models/User');
const { auth } = require('../middleware/auth');

// @route   POST /api/follows/follow
// @desc    Follow a vendor
// @access  Private
router.post('/follow', auth, async (req, res) => {
  try {
    const { vendorId } = req.body;
    
    if (!vendorId) {
      return res.status(400).json({
        success: false,
        message: 'Vendor ID is required'
      });
    }

    // Check if user is trying to follow themselves
    if (req.user._id.toString() === vendorId) {
      return res.status(400).json({
        success: false,
        message: 'You cannot follow yourself'
      });
    }

    // Check if vendor exists and is actually a vendor
    const vendor = await User.findById(vendorId);
    if (!vendor) {
      return res.status(404).json({
        success: false,
        message: 'Vendor not found'
      });
    }

    if (vendor.role !== 'vendor') {
      return res.status(400).json({
        success: false,
        message: 'You can only follow vendors'
      });
    }

    // Check if already following
    const existingFollow = await Follow.findOne({
      follower: req.user._id,
      following: vendorId
    });

    if (existingFollow) {
      return res.status(400).json({
        success: false,
        message: 'You are already following this vendor'
      });
    }

    // Create new follow
    const newFollow = new Follow({
      follower: req.user._id,
      following: vendorId
    });

    await newFollow.save();

    res.status(201).json({
      success: true,
      message: 'Successfully followed vendor',
      data: {
        follower: req.user._id,
        following: vendorId,
        followedAt: newFollow.followedAt
      }
    });

  } catch (error) {
    console.error('Error following vendor:', error);
    res.status(500).json({
      success: false,
      message: 'Error following vendor',
      error: error.message
    });
  }
});

// @route   DELETE /api/follows/unfollow
// @desc    Unfollow a vendor
// @access  Private
router.delete('/unfollow', auth, async (req, res) => {
  try {
    const { vendorId } = req.body;
    
    if (!vendorId) {
      return res.status(400).json({
        success: false,
        message: 'Vendor ID is required'
      });
    }

    // Find and delete the follow
    const deletedFollow = await Follow.findOneAndDelete({
      follower: req.user._id,
      following: vendorId
    });

    if (!deletedFollow) {
      return res.status(404).json({
        success: false,
        message: 'You are not following this vendor'
      });
    }

    res.json({
      success: true,
      message: 'Successfully unfollowed vendor'
    });

  } catch (error) {
    console.error('Error unfollowing vendor:', error);
    res.status(500).json({
      success: false,
      message: 'Error unfollowing vendor',
      error: error.message
    });
  }
});

// @route   GET /api/follows/following
// @desc    Get user's followed vendors
// @access  Private
router.get('/following', auth, async (req, res) => {
  try {
    const follows = await Follow.find({ follower: req.user._id })
      .populate('following', 'name email role hasVendorProfile')
      .sort({ followedAt: -1 });

    res.json({
      success: true,
      data: follows
    });

  } catch (error) {
    console.error('Error fetching followed vendors:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching followed vendors',
      error: error.message
    });
  }
});

// @route   GET /api/follows/followers/:vendorId
// @desc    Get vendor's followers count
// @access  Public
router.get('/followers/:vendorId', async (req, res) => {
  try {
    const { vendorId } = req.params;
    
    const followersCount = await Follow.countDocuments({ following: vendorId });
    
    res.json({
      success: true,
      data: {
        vendorId,
        followersCount
      }
    });

  } catch (error) {
    console.error('Error fetching followers count:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching followers count',
      error: error.message
    });
  }
});

// @route   GET /api/follows/is-following/:vendorId
// @desc    Check if current user is following a vendor
// @access  Private
router.get('/is-following/:vendorId', auth, async (req, res) => {
  try {
    const { vendorId } = req.params;
    
    const follow = await Follow.findOne({
      follower: req.user._id,
      following: vendorId
    });
    
    res.json({
      success: true,
      data: {
        isFollowing: !!follow,
        followedAt: follow ? follow.followedAt : null
      }
    });

  } catch (error) {
    console.error('Error checking follow status:', error);
    res.status(500).json({
      success: false,
      message: 'Error checking follow status',
      error: error.message
    });
  }
});

module.exports = router;
