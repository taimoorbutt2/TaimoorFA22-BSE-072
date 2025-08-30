const multer = require('multer');

// Configure multer to store files in memory (not on disk)
const storage = multer.memoryStorage();

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

// Convert file buffer to Base64
const convertToBase64 = (file) => {
  if (!file) return null;
  
  const base64 = file.buffer.toString('base64');
  const mimeType = file.mimetype;
  
  return `data:${mimeType};base64,${base64}`;
};

// Convert multiple files to Base64
const convertMultipleToBase64 = (files) => {
  if (!files || !Array.isArray(files)) return [];
  
  return files.map(file => convertToBase64(file));
};

// Specific upload configurations
const uploadSingle = (fieldName) => upload.single(fieldName);
const uploadMultiple = (fieldName, maxCount = 5) => upload.array(fieldName, maxCount);
const uploadFields = (fields) => upload.fields(fields);

// Upload multiple specific fields (e.g., profileImage and bannerImage)
const uploadProfileFields = () => upload.fields([
  { name: 'profileImage', maxCount: 1 },
  { name: 'bannerImage', maxCount: 1 }
]);

// Middleware to automatically convert uploaded files to Base64
const convertUploadedFiles = (req, res, next) => {
  try {
    // Convert single file
    if (req.file) {
      req.file.base64 = convertToBase64(req.file);
    }
    
    // Convert multiple files
    if (req.files) {
      if (Array.isArray(req.files)) {
        req.files.forEach(file => {
          file.base64 = convertToBase64(file);
        });
      } else {
        // Handle fields with multiple files
        Object.keys(req.files).forEach(fieldName => {
          if (Array.isArray(req.files[fieldName])) {
            req.files[fieldName].forEach(file => {
              file.base64 = convertToBase64(file);
            });
          }
        });
      }
    }
    
    next();
  } catch (error) {
    next(error);
  }
};

module.exports = {
  upload,
  uploadSingle,
  uploadMultiple,
  uploadFields,
  uploadProfileFields,
  convertToBase64,
  convertMultipleToBase64,
  convertUploadedFiles
};
