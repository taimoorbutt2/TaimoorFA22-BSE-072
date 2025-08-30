const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Ensure upload directories exist
const createUploadDirs = () => {
  const dirs = [
    'uploads',
    'uploads/products',
    'uploads/profiles',
    'uploads/banners',
    'uploads/gallery'
  ];
  
  dirs.forEach(dir => {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  });
};

createUploadDirs();

// Configure storage for different upload types
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    let uploadPath = 'uploads/';
    
    // Determine upload path based on field name or route
    if (file.fieldname === 'profileImage') {
      uploadPath += 'profiles/';
    } else if (file.fieldname === 'bannerImage') {
      uploadPath += 'banners/';
    } else if (file.fieldname === 'images') {
      uploadPath += 'products/';
    } else if (file.fieldname === 'gallery') {
      uploadPath += 'gallery/';
    } else {
      uploadPath += 'products/'; // default
    }
    
    cb(null, uploadPath);
  },
  filename: function (req, file, cb) {
    // Generate unique filename with timestamp
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    const name = path.basename(file.originalname, ext);
    
    // Clean filename (remove special characters)
    const cleanName = name.replace(/[^a-zA-Z0-9]/g, '-').toLowerCase();
    
    cb(null, `${cleanName}-${uniqueSuffix}${ext}`);
  }
});

// File filter for images
const fileFilter = (req, file, cb) => {
  // Check file type
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Only image files are allowed!'), false);
  }
};

// Configure multer
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
    files: 10 // Maximum 10 files
  }
});

// Specific upload configurations
const uploadSingle = (fieldName) => upload.single(fieldName);
const uploadMultiple = (fieldName, maxCount = 5) => upload.array(fieldName, maxCount);
const uploadFields = (fields) => upload.fields(fields);

// Helper function to get file URL
const getFileUrl = (filename, type = 'products') => {
  if (!filename) return null;
  
  // For local development, return relative path
  // In production, this would be your domain + path
  return `/uploads/${type}/${filename}`;
};

// Helper function to delete file
const deleteFile = (filepath) => {
  if (filepath && fs.existsSync(filepath)) {
    fs.unlinkSync(filepath);
    return true;
  }
  return false;
};

// Helper function to get file path from URL
const getFilePathFromUrl = (url) => {
  if (!url) return null;
  
  // Remove leading slash and domain if present
  const cleanUrl = url.replace(/^https?:\/\/[^\/]+/, '');
  return path.join(process.cwd(), cleanUrl);
};

module.exports = {
  upload,
  uploadSingle,
  uploadMultiple,
  uploadFields,
  getFileUrl,
  deleteFile,
  getFilePathFromUrl
};
