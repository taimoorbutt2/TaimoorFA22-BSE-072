# ArtisanMart - Multi-Vendor Marketplace

A full-stack MERN (MongoDB, Express.js, React, Node.js) web application that enables multiple vendors (artisans) to create profiles, list unique products, and sell to customers through a seamless, responsive platform.

## 🚀 Features

### Core Functionality
- **Multi-Vendor Support**: Vendors can create profiles, list products, and manage their shops
- **Product Management**: Full CRUD operations for products with categories, tags, and images
- **User Authentication**: JWT-based authentication with role-based access control
- **Shopping Cart**: Persistent cart functionality with vendor-specific grouping
- **Order Management**: Complete order lifecycle from cart to delivery
- **Review System**: Product ratings and reviews with vendor responses
- **Admin Dashboard**: Platform management and vendor approval system

### Technical Features
- **Responsive Design**: Mobile-first approach with Tailwind CSS
- **Real-time Search**: Product and vendor search with filters
- **Payment Integration**: Stripe Connect for split payments (Test Mode)
- **Image Management**: Product image handling and optimization
- **Security**: Input validation, rate limiting, and CORS protection

## 🛠️ Tech Stack

### Frontend
- **React 18** - Modern React with hooks and context
- **Vite** - Fast build tool and dev server
- **Tailwind CSS** - Utility-first CSS framework
- **React Router** - Client-side routing
- **Axios** - HTTP client for API calls
- **React Icons** - Icon library
- **React Hot Toast** - Toast notifications

### Backend
- **Node.js** - JavaScript runtime
- **Express.js** - Web framework
- **MongoDB** - NoSQL database with Mongoose ODM
- **JWT** - JSON Web Token authentication
- **bcryptjs** - Password hashing
- **Stripe** - Payment processing (Test Mode)
- **Passport.js** - Authentication middleware
- **Express Validator** - Input validation
- **Helmet** - Security headers
- **Rate Limiting** - API protection

### Database
- **MongoDB Atlas** - Cloud database service
- **Mongoose** - MongoDB object modeling

## 📁 Project Structure

```
artisanmart/
├── frontend/                 # React frontend
│   ├── src/
│   │   ├── components/      # Reusable UI components
│   │   ├── pages/          # Page components
│   │   ├── contexts/       # React contexts
│   │   └── utils/          # Utility functions
│   ├── public/             # Static assets
│   └── package.json        # Frontend dependencies
├── backend/                 # Node.js backend
│   ├── models/             # MongoDB schemas
│   ├── routes/             # API route handlers
│   ├── middleware/          # Custom middleware
│   ├── controllers/         # Business logic
│   ├── utils/              # Utility functions
│   └── package.json        # Backend dependencies
└── README.md               # Project documentation
```

## 🚀 Getting Started

### Prerequisites
- Node.js (v18 or higher)
- MongoDB Atlas account (free tier)
- Stripe account (for payment testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd artisanmart
   ```

2. **Install backend dependencies**
   ```bash
   cd backend
   npm install
   ```

3. **Install frontend dependencies**
   ```bash
   cd ../frontend
   npm install
   ```

4. **Environment Configuration**
   
   Create `backend/config.env`:
   ```env
   NODE_ENV=development
   PORT=5000
   MONGODB_URI=your_mongodb_atlas_connection_string
   JWT_SECRET=your_jwt_secret_key
   STRIPE_SECRET_KEY=your_stripe_secret_key
   STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
   CLIENT_URL=http://localhost:3000
   ```

5. **Start the backend server**
   ```bash
   cd backend
   npm run dev
   ```

6. **Start the frontend development server**
   ```bash
   cd frontend
   npm run dev
   ```

7. **Open your browser**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000
   - Health Check: http://localhost:5000/health

## 🔧 Configuration

### MongoDB Atlas Setup
1. Create a free MongoDB Atlas account
2. Create a new cluster
3. Get your connection string
4. Update `MONGODB_URI` in `backend/config.env`

### Stripe Setup (Test Mode)
1. Create a Stripe account
2. Get your test API keys
3. Update Stripe keys in `backend/config.env`
4. Use test card numbers for payment testing

## 📱 Usage

### Customer Features
- Browse products by category
- Search and filter products
- Add items to cart
- Complete checkout process
- Leave product reviews
- Track order status

### Vendor Features
- Create vendor profile
- List and manage products
- View sales analytics
- Respond to customer reviews
- Manage shop settings

### Admin Features
- Approve vendor registrations
- Monitor platform activity
- View analytics dashboard
- Manage users and products

## 🧪 Testing

### API Testing
Use tools like Postman or Thunder Client to test the backend API endpoints:

- **Health Check**: `GET /health`
- **Authentication**: `POST /api/auth/register`, `POST /api/auth/login`
- **Products**: `GET /api/products`, `POST /api/products`
- **Vendors**: `GET /api/vendors`, `POST /api/vendors`

### Frontend Testing
The React app includes:
- Responsive design testing
- Component interaction testing
- Form validation testing
- Navigation testing

## 🚀 Deployment

### Frontend (Vercel)
1. Push code to GitHub
2. Connect Vercel to your repository
3. Configure build settings
4. Deploy automatically

### Backend (Vercel/Railway)
1. Update environment variables
2. Configure MongoDB connection
3. Deploy Node.js application
4. Update frontend API endpoints

## 🔒 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: bcrypt for password security
- **Input Validation**: Comprehensive input sanitization
- **Rate Limiting**: API protection against abuse
- **CORS Configuration**: Cross-origin request handling
- **Helmet Security**: HTTP header security

## 📊 Database Schema

### Collections
- **Users**: Customer and vendor accounts
- **Vendors**: Vendor profiles and shop information
- **Products**: Product listings with metadata
- **Orders**: Order management and tracking
- **Reviews**: Product ratings and feedback

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **React Team** - For the amazing frontend framework
- **Express.js Team** - For the robust backend framework
- **Tailwind CSS** - For the utility-first CSS framework
- **MongoDB** - For the flexible NoSQL database
- **Stripe** - For payment processing capabilities

## 📞 Support

For support and questions:
- Create an issue in the GitHub repository
- Check the documentation
- Review the code examples

## 🔮 Future Enhancements

- **Mobile App**: React Native extension
- **Real-time Chat**: Vendor-customer communication
- **AI Integration**: Product recommendations using Ollama
- **Advanced Analytics**: Detailed sales and performance metrics
- **Multi-language Support**: Internationalization
- **Advanced Search**: Elasticsearch integration
- **Push Notifications**: Real-time updates

---

**Built with ❤️ using the MERN stack**
