const express = require('express');
const router = express.Router();
const Product = require('../models/Product');
const { uploadMultiple, convertUploadedFiles } = require('../middleware/base64Upload');
const { auth } = require('../middleware/auth');
const vendorAuth = require('../middleware/vendorAuth');

// @route   POST /api/products
// @desc    Create a new product
// @access  Private (Vendor only)
router.post('/', auth, vendorAuth, uploadMultiple('images', 5), convertUploadedFiles, async (req, res) => {
  try {
    // Debug: Log the incoming request data
    console.log('Creating product - Request body:', req.body);
    console.log('Creating product - Files:', req.files ? req.files.length : 0);
    console.log('Creating product - User:', req.user);
    console.log('Creating product - User role:', req.user?.role);
    
    const {
      name,
      description,
      price,
      category,
      stock,
      tags,
      materials,
      careInstructions,
      dimensions,
      weight
    } = req.body;

    // Get images as Base64 from uploaded files
    const images = req.files ? req.files.map(file => file.base64) : [];

    // Debug: Log the stock value being processed
    console.log('Creating product with stock:', { 
      originalStock: stock, 
      parsedStock: parseInt(stock), 
      finalStock: parseInt(stock) || 0 
    })
    
    // Create new product
    const product = new Product({
      name,
      description,
      price: parseFloat(price),
      category,
      images,
      vendor: req.user.id,
      vendorName: req.user.name,
      stock: parseInt(stock) || 0,
      tags: tags ? tags.split(',').map(tag => tag.trim()) : [],
      materials: materials ? materials.split(',').map(material => material.trim()) : [],
      careInstructions,
      dimensions: (() => {
        try {
          if (!dimensions) return {};
          if (typeof dimensions === 'string') {
            return dimensions.trim() ? JSON.parse(dimensions) : {};
          }
          return dimensions;
        } catch (error) {
          console.error('Error parsing dimensions:', dimensions, error);
          return {};
        }
      })(),
      weight: (() => {
        try {
          if (!weight) return {};
          if (typeof weight === 'string') {
            return weight.trim() ? JSON.parse(weight) : {};
          }
          return weight;
        } catch (error) {
          console.error('Error parsing weight:', weight, error);
          return {};
        }
      })()
    });

    const savedProduct = await product.save();

    res.status(201).json({
      success: true,
      message: 'Product created successfully',
      product: savedProduct
    });

  } catch (error) {
    console.error('Error creating product:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating product',
      error: error.message
    });
  }
});

// @route   GET /api/products
// @desc    Get all products with filtering and pagination
// @access  Public
router.get('/', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 12,
      category,
      minPrice,
      maxPrice,
      search,
      sortBy = 'createdAt',
      sortOrder = 'desc'
    } = req.query;

    // Build filter object
    const filter = { isActive: true };
    
    if (category) {
      filter.category = category;
    }
    
    if (minPrice || maxPrice) {
      filter.price = {};
      if (minPrice) filter.price.$gte = parseFloat(minPrice);
      if (maxPrice) filter.price.$lte = parseFloat(maxPrice);
    }
    
    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { tags: { $in: [new RegExp(search, 'i')] } }
      ];
    }

    // Build sort object
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;

    // Execute query with pagination
    const products = await Product.find(filter)
      .sort(sort)
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .populate('vendor', 'name shopName');

    // Debug: Log the products being returned
    console.log('Products being returned:', products.map(p => ({ 
      id: p._id, 
      name: p.name, 
      stock: p.stock, 
      stockType: typeof p.stock,
      inStock: p.inStock,
      inStockType: typeof p.inStock
    })))

    // Get total count for pagination
    const total = await Product.countDocuments(filter);

    res.json({
      success: true,
      products,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / limit),
        totalProducts: total,
        hasNextPage: page * limit < total,
        hasPrevPage: page > 1
      }
    });

  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching products',
      error: error.message
    });
  }
});

// @route   GET /api/products/featured
// @desc    Get featured products
// @access  Public
router.get('/featured', async (req, res) => {
  try {
    const featuredProducts = await Product.find({ 
      isActive: true, 
      isFeatured: true 
    })
    .sort({ rating: -1, createdAt: -1 })
    .limit(8)
    .populate('vendor', 'name shopName');

    res.json({
      success: true,
      products: featuredProducts
    });

  } catch (error) {
    console.error('Error fetching featured products:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching featured products',
      error: error.message
    });
  }
});

// @route   GET /api/products/vendor/me
// @desc    Get current vendor's products
// @access  Private (Vendor only)
router.get('/vendor/me', auth, vendorAuth, async (req, res) => {
  try {
    const products = await Product.find({ 
      vendor: req.user.id, 
      isActive: true 
    })
    .sort({ createdAt: -1 })
    .populate('vendor', 'name shopName');

    res.json({
      success: true,
      products
    });

  } catch (error) {
    console.error('Error fetching vendor products:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching vendor products',
      error: error.message
    });
  }
});

// @route   GET /api/products/vendor/:vendorId
// @desc    Get products by vendor
// @access  Public
router.get('/vendor/:vendorId', async (req, res) => {
  try {
    const { vendorId } = req.params;
    const { page = 1, limit = 12 } = req.query;

    const products = await Product.find({ 
      vendor: vendorId, 
      isActive: true 
    })
    .sort({ createdAt: -1 })
    .limit(limit * 1)
    .skip((page - 1) * limit)
    .populate('vendor', 'name shopName');

    const total = await Product.countDocuments({ 
      vendor: vendorId, 
      isActive: true 
    });

    res.json({
      success: true,
      products,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / limit),
        totalProducts: total
      }
    });

  } catch (error) {
    console.error('Error fetching vendor products:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching vendor products',
      error: error.message
    });
  }
});

// @route   GET /api/products/:id
// @desc    Get single product by ID
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const product = await Product.findById(req.params.id)
      .populate('vendor', 'name shopName profileImage');

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    res.json({
      success: true,
      product
    });

  } catch (error) {
    console.error('Error fetching product:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching product',
      error: error.message
    });
  }
});

// @route   PUT /api/products/:id
// @desc    Update product
// @access  Private (Vendor only - owner of product)
router.put('/:id', auth, vendorAuth, uploadMultiple('images', 5), convertUploadedFiles, async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Check if user owns this product
    if (product.vendor.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this product'
      });
    }

    const updateData = { ...req.body };
    
    // Handle new images if uploaded
    if (req.files && req.files.length > 0) {
      const newImages = req.files.map(file => file.base64);
      
      // Since we're using Base64, we don't need to delete old files
      if (req.body.replaceImages === 'true') {
        updateData.images = newImages;
      } else {
        // Add new images to existing ones
        updateData.images = [...product.images, ...newImages];
      }
    }

    // Parse numeric fields
    if (updateData.price) updateData.price = parseFloat(updateData.price);
    if (updateData.stock) updateData.stock = parseInt(updateData.stock);
    if (updateData.tags) {
      updateData.tags = updateData.tags.split(',').map(tag => tag.trim());
    }
    if (updateData.materials) {
      updateData.materials = updateData.materials.split(',').map(material => material.trim());
    }

    const updatedProduct = await Product.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    );

    res.json({
      success: true,
      message: 'Product updated successfully',
      product: updatedProduct
    });

  } catch (error) {
    console.error('Error updating product:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating product',
      error: error.message
    });
  }
});

// @route   DELETE /api/products/:id
// @desc    Delete product
// @access  Private (Vendor only - owner of product)
router.delete('/:id', auth, vendorAuth, async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Check if user owns this product
    if (product.vendor.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this product'
      });
    }

    // No need to delete files since we're using Base64 storage

    // Delete product
    await Product.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'Product deleted successfully'
    });

  } catch (error) {
    console.error('Error deleting product:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting product',
      error: error.message
    });
  }
});

// @route   GET /api/products/categories
// @desc    Get all product categories
// @access  Public
router.get('/categories', async (req, res) => {
  try {
    const categories = await Product.distinct('category');
    
    res.json({
      success: true,
      categories
    });

  } catch (error) {
    console.error('Error fetching categories:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching categories',
      error: error.message
    });
  }
});

module.exports = router;
