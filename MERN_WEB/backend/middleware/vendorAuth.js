const vendorAuth = (req, res, next) => {
  try {
    // Check if user exists and has vendor role
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. Please log in.'
      });
    }

    if (req.user.role !== 'vendor') {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Vendor role required.'
      });
    }

    next();
  } catch (error) {
    console.error('Vendor auth middleware error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error in vendor authentication',
      error: error.message
    });
  }
};

module.exports = vendorAuth;
