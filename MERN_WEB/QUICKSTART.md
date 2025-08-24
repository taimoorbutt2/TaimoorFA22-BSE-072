# 🚀 ArtisanMart Quick Start Guide

Get ArtisanMart up and running in minutes!

## ⚡ Quick Start

### 1. Install Dependencies
```bash
npm run install:all
```

### 2. Environment Setup
Create `backend/config.env` with your configuration:
```env
NODE_ENV=development
PORT=5000
MONGODB_URI=your_mongodb_atlas_connection_string
JWT_SECRET=your_secret_key_here
STRIPE_SECRET_KEY=sk_test_your_stripe_key
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_key
CLIENT_URL=http://localhost:3000
```

### 3. Start Development Servers
```bash
npm run dev
```

This will start both:
- **Frontend**: http://localhost:3000
- **Backend**: http://localhost:5000

## 🔧 Manual Start

### Frontend Only
```bash
cd frontend
npm run dev
```

### Backend Only
```bash
cd backend
npm run dev
```

## 📱 What's Working

✅ **Frontend**
- React app with routing
- Authentication pages (Login/Register)
- Responsive navigation
- User dashboard
- Tailwind CSS styling

✅ **Backend**
- Express server with middleware
- MongoDB models (User, Vendor, Product, Order, Review)
- Authentication routes
- Product and vendor routes
- JWT authentication
- Input validation

## 🧪 Test the App

1. Open http://localhost:3000
2. Navigate to `/register` to create an account
3. Try logging in at `/login`
4. Access the dashboard at `/dashboard`

## 🚨 Common Issues

### Port Already in Use
- Frontend: Change port in `frontend/vite.config.js`
- Backend: Change port in `backend/config.env`

### MongoDB Connection
- Ensure your MongoDB Atlas connection string is correct
- Check if your IP is whitelisted in MongoDB Atlas

### Dependencies
- Run `npm run install:all` to install all dependencies
- Clear `node_modules` and reinstall if needed

## 📚 Next Steps

1. **Complete the backend routes** - Add missing functionality
2. **Build the frontend pages** - Create product listings, cart, etc.
3. **Add Stripe integration** - Set up payment processing
4. **Deploy to Vercel** - Frontend deployment
5. **Deploy backend** - Railway, Render, or Vercel

## 🆘 Need Help?

- Check the main README.md for detailed documentation
- Review the code structure in `src/` directories
- Test API endpoints with Postman or Thunder Client

---

**Happy coding! 🎉**
