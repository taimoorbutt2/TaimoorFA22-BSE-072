const mongoose = require('mongoose');
const Review = require('./models/Review');
const Product = require('./models/Product');
require('dotenv').config({ path: './config.env' });

async function testReviews() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB Atlas');

    // Check if there are any reviews in the database
    const totalReviews = await Review.countDocuments();
    console.log('📊 Total reviews in database:', totalReviews);

    if (totalReviews > 0) {
      // Get a sample review
      const sampleReview = await Review.findOne();
      console.log('🔍 Sample review:', {
        id: sampleReview._id,
        product: sampleReview.product,
        user: sampleReview.user,
        rating: sampleReview.rating,
        comment: sampleReview.comment
      });

      // Check the product this review belongs to
      const product = await Product.findById(sampleReview.product);
      if (product) {
        console.log('📦 Product details:', {
          id: product._id,
          name: product.name,
          rating: product.rating,
          reviewCount: product.reviewCount
        });
      }

      // Count reviews for this specific product
      const productReviews = await Review.countDocuments({ product: sampleReview.product });
      console.log('📝 Reviews for this product:', productReviews);

      // Test the aggregation query
      const stats = await Review.aggregate([
        { $match: { product: sampleReview.product } },
        {
          $group: {
            _id: null,
            avgRating: { $avg: '$rating' },
            totalReviews: { $sum: 1 }
          }
        }
      ]);
      console.log('📊 Aggregation stats:', stats);
    }

    // Check products with their ratings
    const products = await Product.find({}, 'name rating reviewCount').limit(5);
    console.log('🏷️ Products with ratings:', products.map(p => ({
      name: p.name,
      rating: p.rating,
      reviewCount: p.reviewCount
    })));

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

testReviews();
