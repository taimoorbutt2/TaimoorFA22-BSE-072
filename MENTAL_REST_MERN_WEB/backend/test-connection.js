// Simple test script to check backend connection
require('dotenv').config();
const mongoose = require('mongoose');

console.log('🔍 Testing Backend Connection...');
console.log('MONGODB_URI:', process.env.MONGODB_URI ? '✅ Set' : '❌ Not set');
console.log('JWT_SECRET:', process.env.JWT_SECRET ? '✅ Set' : '❌ Not set');
console.log('PORT:', process.env.PORT || '5000');

// Test MongoDB connection
if (process.env.MONGODB_URI) {
  console.log('\n🔗 Testing MongoDB connection...');
  mongoose.connect(process.env.MONGODB_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => {
    console.log('✅ MongoDB connected successfully');
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ MongoDB connection error:', err.message);
    process.exit(1);
  });
} else {
  console.log('❌ MONGODB_URI not set in .env file');
  process.exit(1);
}
