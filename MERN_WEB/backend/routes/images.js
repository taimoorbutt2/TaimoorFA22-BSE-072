const express = require('express');
const router = express.Router();
const path = require('path');
const fs = require('fs');

// @route   GET /api/images/:type/:filename
// @desc    Serve uploaded images with CORS headers
// @access  Public
router.get('/:type/:filename', (req, res) => {
  try {
    const { type, filename } = req.params;
    
    // Validate type to prevent directory traversal
    const allowedTypes = ['profiles', 'products', 'banners', 'gallery'];
    if (!allowedTypes.includes(type)) {
      return res.status(400).json({ message: 'Invalid image type' });
    }
    
    // Construct file path
    const filePath = path.join(__dirname, '..', 'uploads', type, filename);
    
    // Check if file exists
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ message: 'Image not found' });
    }
    
    // Set CORS headers
    res.header('Access-Control-Allow-Origin', process.env.CLIENT_URL || 'http://localhost:3000');
    res.header('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    res.header('Access-Control-Allow-Credentials', 'true');
    
    // Determine content type based on file extension
    const ext = path.extname(filename).toLowerCase();
    let contentType = 'image/jpeg'; // default
    
    if (ext === '.png') contentType = 'image/png';
    else if (ext === '.gif') contentType = 'image/gif';
    else if (ext === '.webp') contentType = 'image/webp';
    
    // Set content type and serve file
    res.setHeader('Content-Type', contentType);
    res.setHeader('Cache-Control', 'public, max-age=31536000'); // Cache for 1 year
    
    // Stream the file
    const stream = fs.createReadStream(filePath);
    stream.pipe(res);
    
  } catch (error) {
    console.error('Error serving image:', error);
    res.status(500).json({ message: 'Error serving image' });
  }
});

module.exports = router;
