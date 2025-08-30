const mongoose = require('mongoose');
const Review = require('./models/Review');
const Product = require('./models/Product');
require('dotenv').config({ path: './config.env' });

// Copy the updateProductRating function from reviews.js
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

async function fixAllProductRatings() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB Atlas');

    // Get all products
    const products = await Product.find({}, '_id name rating reviewCount');
    console.log('📦 Found products:', products.length);

    // Update ratings for each product
    for (const product of products) {
      console.log(`\n🔄 Processing product: ${product.name} (${product._id})`);
      await updateProductRating(product._id);
    }

    // Verify the updates
    console.log('\n✅ Verification - Updated products:');
    const updatedProducts = await Product.find({}, 'name rating reviewCount');
    updatedProducts.forEach(p => {
      console.log(`  ${p.name}: Rating ${p.rating}, Reviews ${p.reviewCount}`);
    });

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

fixAllProductRatings();
