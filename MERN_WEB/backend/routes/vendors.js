const express = require('express');
const router = express.Router();
const VendorProfile = require('../models/VendorProfile');
const User = require('../models/User');
const { uploadSingle, uploadProfileFields, convertUploadedFiles } = require('../middleware/base64Upload');
const { auth } = require('../middleware/auth');
const vendorAuth = require('../middleware/vendorAuth');

// @route   POST /api/vendors/profile
// @desc    Create vendor profile
// @access  Private (Vendor only)
router.post('/profile', auth, vendorAuth, uploadProfileFields(), convertUploadedFiles, async (req, res) => {
  try {
    // Check if profile already exists
    const existingProfile = await VendorProfile.findOne({ userId: req.user.id });
    if (existingProfile) {
      return res.status(400).json({
        success: false,
        message: 'Vendor profile already exists'
      });
    }

    const {
      shopName,
      bio,
      tagline,
      specialties,
      location,
      experience,
      education,
      certifications,
      socialLinks,
      contactInfo,
      businessHours,
      policies
    } = req.body;

    // Get profile image as Base64
    const profileImage = req.files?.profileImage?.[0]?.base64 || null;

    if (!profileImage) {
      return res.status(400).json({
        success: false,
        message: 'Profile image is required'
      });
    }

    // Get banner image as Base64 (optional)
    const bannerImage = req.files?.bannerImage?.[0]?.base64 || null;

    // Helper function to safely parse JSON or return default
    const safeJsonParse = (str, defaultValue = {}) => {
      if (!str || str === '') return defaultValue;
      try {
        return JSON.parse(str);
      } catch (error) {
        console.log('JSON parse error for:', str, 'using default:', defaultValue);
        return defaultValue;
      }
    };

    // Create vendor profile
    const vendorProfile = new VendorProfile({
      userId: req.user.id,
      shopName: shopName || '',
      bio: bio || '',
      tagline: tagline || '',
      specialties: specialties ? specialties.split(',').map(s => s.trim()).filter(s => s && s.length > 0) : [],
      profileImage,
      bannerImage,
      location: safeJsonParse(location, {}),
      experience: safeJsonParse(experience, {}),
      education: safeJsonParse(education, {}),
      certifications: safeJsonParse(certifications, []),
      socialLinks: safeJsonParse(socialLinks, {}),
      contactInfo: safeJsonParse(contactInfo, {}),
      businessHours: safeJsonParse(businessHours, {}),
      policies: safeJsonParse(policies, {})
    });

    const savedProfile = await vendorProfile.save();

    // Update user with vendor status
    await User.findByIdAndUpdate(req.user.id, {
      hasVendorProfile: true,
      vendorProfileId: savedProfile._id
    });

    res.status(201).json({
      success: true,
      message: 'Vendor profile created successfully',
      profile: savedProfile
    });

  } catch (error) {
    console.error('Error creating vendor profile:', error);
    console.error('Request body:', req.body);
    console.error('Request file:', req.file);
    res.status(500).json({
      success: false,
      message: 'Error creating vendor profile',
      error: error.message
    });
  }
});

// @route   GET /api/vendors/profile/me
// @desc    Get current vendor's profile
// @access  Private (Vendor only)
router.get('/profile/me', auth, vendorAuth, async (req, res) => {
  try {
    const vendorProfile = await VendorProfile.findOne({ userId: req.user.id })
      .populate('userId', 'name email');

    if (!vendorProfile) {
      return res.status(404).json({
        success: false,
        message: 'Vendor profile not found'
      });
    }

    res.json({
      success: true,
      profile: vendorProfile
    });

  } catch (error) {
    console.error('Error fetching vendor profile:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching vendor profile',
      error: error.message
    });
  }
});

// @route   GET /api/vendors/profile/:userId
// @desc    Get vendor profile by user ID
// @access  Public
router.get('/profile/:userId', async (req, res) => {
  try {
    const vendorProfile = await VendorProfile.findOne({ userId: req.params.userId })
      .populate('userId', 'name email');

    if (!vendorProfile) {
      return res.status(404).json({
        success: false,
        message: 'Vendor profile not found'
      });
    }

    res.json({
      success: true,
      profile: vendorProfile
    });

  } catch (error) {
    console.error('Error fetching vendor profile:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching vendor profile',
      error: error.message
    });
  }
});

// @route   PUT /api/vendors/profile/me
// @desc    Update current vendor's profile
// @access  Private (Vendor only)
router.put('/profile/me', auth, vendorAuth, uploadProfileFields(), convertUploadedFiles, async (req, res) => {
  try {
    const vendorProfile = await VendorProfile.findOne({ userId: req.user.id });
    
    if (!vendorProfile) {
      return res.status(404).json({
        success: false,
        message: 'Vendor profile not found'
      });
    }

    const updateData = { ...req.body };

    // Handle profile image update
    if (req.files?.profileImage?.[0]) {
      // Since we're using Base64, we don't need to delete old files
      updateData.profileImage = req.files.profileImage[0].base64;
    }

    // Handle banner image update
    if (req.files?.bannerImage?.[0]) {
      updateData.bannerImage = req.files.bannerImage[0].base64;
    }

    // Helper function to safely parse JSON or return default
    const safeJsonParse = (str, defaultValue = {}) => {
      if (!str || str === '') return defaultValue;
      try {
        return JSON.parse(str);
      } catch (error) {
        console.log('JSON parse error for:', str, 'using default:', defaultValue);
        return defaultValue;
      }
    };

    // Parse complex fields
    if (updateData.specialties) {
      updateData.specialties = updateData.specialties.split(',').map(s => s.trim()).filter(s => s);
    }
    if (updateData.location) {
      updateData.location = safeJsonParse(updateData.location, {});
    }
    if (updateData.experience) {
      updateData.experience = safeJsonParse(updateData.experience, {});
    }
    if (updateData.education) {
      updateData.education = safeJsonParse(updateData.education, {});
    }
    if (updateData.certifications) {
      updateData.certifications = safeJsonParse(updateData.certifications, []);
    }
    if (updateData.socialLinks) {
      updateData.socialLinks = safeJsonParse(updateData.socialLinks, {});
    }
    if (updateData.contactInfo) {
      updateData.contactInfo = safeJsonParse(updateData.contactInfo, {});
    }
    if (updateData.businessHours) {
      updateData.businessHours = safeJsonParse(updateData.businessHours, {});
    }
    if (updateData.policies) {
      updateData.policies = safeJsonParse(updateData.policies, {});
    }

    const updatedProfile = await VendorProfile.findByIdAndUpdate(
      vendorProfile._id,
      updateData,
      { new: true, runValidators: true }
    );

    res.json({
      success: true,
      message: 'Vendor profile updated successfully',
      profile: updatedProfile
    });

  } catch (error) {
    console.error('Error updating vendor profile:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating vendor profile',
      error: error.message
    });
  }
});

// @route   PUT /api/vendors/profile/:userId
// @desc    Update vendor profile
// @access  Private (Vendor only - owner of profile)
router.put('/profile/:userId', auth, vendorAuth, uploadProfileFields(), convertUploadedFiles, async (req, res) => {
  try {
    // Check if user owns this profile
    if (req.params.userId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this profile'
      });
    }

    const vendorProfile = await VendorProfile.findOne({ userId: req.params.userId });
    
    if (!vendorProfile) {
      return res.status(404).json({
        success: false,
        message: 'Vendor profile not found'
      });
    }

    const updateData = { ...req.body };

    // Handle profile image update
    if (req.files?.profileImage?.[0]) {
      // Since we're using Base64, we don't need to delete old files
      updateData.profileImage = req.files.profileImage[0].base64;
    }

    // Handle banner image update
    if (req.files?.bannerImage?.[0]) {
      updateData.bannerImage = req.files.bannerImage[0].base64;
    }

    // Parse complex fields
    if (updateData.specialties) {
      updateData.specialties = updateData.specialties.split(',').map(s => s.trim());
    }
    if (updateData.location) {
      updateData.location = JSON.parse(updateData.location);
    }
    if (updateData.experience) {
      updateData.experience = JSON.parse(updateData.experience);
    }
    if (updateData.education) {
      updateData.education = JSON.parse(updateData.education);
    }
    if (updateData.certifications) {
      updateData.certifications = JSON.parse(updateData.certifications);
    }
    if (updateData.socialLinks) {
      updateData.socialLinks = JSON.parse(updateData.socialLinks);
    }
    if (updateData.contactInfo) {
      updateData.contactInfo = JSON.parse(updateData.contactInfo);
    }
    if (updateData.businessHours) {
      updateData.businessHours = JSON.parse(updateData.businessHours);
    }
    if (updateData.policies) {
      updateData.policies = JSON.parse(updateData.policies);
    }

    const updatedProfile = await VendorProfile.findByIdAndUpdate(
      vendorProfile._id,
      updateData,
      { new: true, runValidators: true }
    );

    res.json({
      success: true,
      message: 'Vendor profile updated successfully',
      profile: updatedProfile
    });

  } catch (error) {
    console.error('Error updating vendor profile:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating vendor profile',
      error: error.message
    });
  }
});



// @route   GET /api/vendors/search
// @desc    Search vendors by name, specialty, or location
// @access  Public
router.get('/search', async (req, res) => {
  try {
    const {
      q = '',
      specialty,
      location,
      page = 1,
      limit = 12
    } = req.query;

    // Build filter object
    const filter = { status: 'active' };
    
    if (specialty) {
      filter.specialties = specialty;
    }
    
    if (location) {
      filter.$or = [
        { 'location.city': { $regex: location, $options: 'i' } },
        { 'location.state': { $regex: location, $options: 'i' } },
        { 'location.country': { $regex: location, $options: 'i' } }
      ];
    }
    
    if (q) {
      filter.$or = [
        { shopName: { $regex: q, $options: 'i' } },
        { bio: { $regex: q, $options: 'i' } },
        { tagline: { $regex: q, $options: 'i' } }
      ];
    }

    // Execute query with pagination
    const vendors = await VendorProfile.find(filter)
      .sort({ 'stats.averageRating': -1, createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .populate('userId', 'name email');

    // Get total count for pagination
    const total = await VendorProfile.countDocuments(filter);

    res.json({
      success: true,
      vendors,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / limit),
        totalVendors: total,
        hasNextPage: page * limit < total,
        hasPrevPage: page > 1
      }
    });

  } catch (error) {
    console.error('Error searching vendors:', error);
    res.status(500).json({
      success: false,
      message: 'Error searching vendors',
      error: error.message
    });
  }
});

// @route   GET /api/vendors/:userId/stats
// @desc    Get vendor statistics
// @access  Private (Vendor only)
router.get('/:userId/stats', auth, vendorAuth, async (req, res) => {
  try {
    // Check if user owns this profile
    if (req.params.userId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view these stats'
      });
    }

    const vendorProfile = await VendorProfile.findOne({ userId: req.params.userId });
    
    if (!vendorProfile) {
      return res.status(404).json({
        success: false,
        message: 'Vendor profile not found'
      });
    }

    res.json({
      success: true,
      stats: vendorProfile.stats
    });

  } catch (error) {
    console.error('Error fetching vendor stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching vendor stats',
      error: error.message
    });
  }
});

// @route   POST /api/vendors/:userId/verify
// @desc    Mark vendor as verified (Admin only)
// @access  Private (Admin only)
router.post('/:userId/verify', auth, async (req, res) => {
  try {
    // Check if user is admin
    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Admin access required'
      });
    }

    const vendorProfile = await VendorProfile.findOneAndUpdate(
      { userId: req.params.userId },
      { 
        isVerified: true,
        status: 'active'
      },
      { new: true }
    );

    if (!vendorProfile) {
      return res.status(404).json({
        success: false,
        message: 'Vendor profile not found'
      });
    }

    res.json({
      success: true,
      message: 'Vendor verified successfully',
      profile: vendorProfile
    });

  } catch (error) {
    console.error('Error verifying vendor:', error);
    res.status(500).json({
      success: false,
      message: 'Error verifying vendor',
      error: error.message
    });
  }
});

// @route   GET /api/vendors/featured
// @desc    Get featured vendor profiles for home page
// @access  Public
router.get('/featured', async (req, res) => {
  try {
    const { limit = 8 } = req.query;
    
    // Get vendor profiles with user information
    const featuredVendors = await VendorProfile.aggregate([
      {
        $lookup: {
          from: 'users',
          localField: 'userId',
          foreignField: '_id',
          as: 'user'
        }
      },
      {
        $unwind: '$user'
      },
      {
        $match: {
          'user.isActive': true,
          'user.role': 'vendor'
        }
      },
      {
        $lookup: {
          from: 'follows',
          localField: 'user._id',
          foreignField: 'following',
          as: 'followers'
        }
      },
      {
        $project: {
          _id: 1,
          shopName: 1,
          bio: 1,
          tagline: 1,
          specialties: 1,
          profileImage: 1,
          bannerImage: 1,
          location: 1,
          experience: 1,
          rating: 1,
          totalProducts: 1,
          totalFollowers: { $size: '$followers' },
          totalReviews: 1,
          user: {
            _id: 1,
            name: 1,
            email: 1
          }
        }
      },
      {
        $sort: { createdAt: -1 }
      },
      {
        $limit: parseInt(limit)
      }
    ]);

    res.json({
      success: true,
      vendors: featuredVendors
    });

  } catch (error) {
    console.error('Error fetching featured vendors:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching featured vendors',
      error: error.message
    });
  }
});

module.exports = router;
