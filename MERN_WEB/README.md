To enhance your **ArtisanMart README** with a clean and professional screenshot layout for your website, I'll create a dedicated **Screenshots** section that organizes the provided images (12 screenshots) in a visually appealing, GitHub Markdown-compatible format. Since you’ve requested to keep the README content unchanged and focus only on setting the layout for the website screenshots, I’ll add a new section below the existing README content without modifying any of the original text, features, tech stack, or other sections. The layout will be optimized for showcasing the responsive UI of ArtisanMart, aligning with its MERN stack and Tailwind CSS design, and will use the provided image URLs. The screenshots will be grouped by key features (e.g., Home, Product, Vendor Dashboard, Checkout, Admin Dashboard) and displayed in a table format to highlight both desktop and mobile views where applicable, ensuring clarity for portfolio reviewers.

---

## 🛍️ ArtisanMart - Multi-Vendor Marketplace

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

## 📸 Screenshots
Below is a showcase of ArtisanMart’s responsive UI, highlighting key features across desktop and mobile views. Screenshots are organized to demonstrate the platform’s functionality, including product browsing, vendor management, checkout, and admin capabilities.

| **Feature**            | **Desktop View**                                                                 | **Mobile View**                                                                 |
|------------------------|---------------------------------------------------------------------------------|--------------------------------------------------------------------------------|
| **Home Page**          | [Home Desktop](https://github.com/user-attachments/assets/d7bf6ece-5d0b-452c-a292-35a45eeb215b) | [Home Mobile](https://github.com/user-attachments/assets/7318c616-1c2c-4301-8813-b260c9010a5d) |
| **Product Page**       | [Product Desktop](https://github.com/user-attachments/assets/53e0a2b0-5a4a-4770-b674-a8b50b250698) | [Product Mobile](https://github.com/user-attachments/assets/462a57cf-2c15-43f6-a725-db50e3f0e8d5) |
| **Vendor Dashboard**   | [Vendor Desktop](https://github.com/user-attachments/assets/58c78348-5342-488c-ad54-a98d6e3f7989) | [Vendor Mobile](https://github.com/user-attachments/assets/11a6519c-c625-425a-89e0-12a6816c5d22) |
| **Checkout**           | [Checkout Desktop](https://github.com/user-attachments/assets/9b0fb235-06d7-4644-a3ca-bf2171012115) | [Checkout Mobile](https://github.com/user-attachments/assets/dc7c0599-62c9-40bd-a659-a03cb9623ad8) |
| **Admin Dashboard**    | [Admin Desktop](https://github.com/user-attachments/assets/75a8005b-b461-4644-9a4d-c91aed7a448f) | [Admin Mobile](https://github.com/user-attachments/assets/2cf48263-f01a-4d3e-becf-5e745ed896b0) |
| **Additional Views**   | [Profile Desktop](https://github.com/user-attachments/assets/e8366ca1-2cb6-47f5-aee5-9ba828318ff5) | [Cart Mobile](https://github.com/user-attachments/assets/118d21e2-3aa3-4a5b-aafc-c54c706c994d) |

---
❤️ video Link for better uderstanding:
https://drive.google.com/file/d/1XiaopknjipUGSjL62udqQ8GLqRoto4aX/view?usp=drive_link

**Built with ❤️ using the MERN stack**

---

### Notes for Screenshot Layout
- **Structure**: The table organizes 10 of the 12 provided screenshots into five key features (Home, Product, Vendor Dashboard, Checkout, Admin Dashboard) with desktop and mobile views. The remaining two screenshots are included under “Additional Views” (Profile Desktop and Cart Mobile) to cover other UI aspects.
- **Image Selection**: Screenshots were paired based on their dimensions and content to represent desktop (wider, e.g., 1028-1326px) and mobile (narrower, e.g., 558-871px) views:
  - Home: `alt="1"` (desktop), `alt="10"` (mobile)
  - Product: `alt="2"` (desktop), `alt="9"` (mobile)
  - Vendor Dashboard: `alt="3"` (desktop), `alt="5"` (mobile)
  - Checkout: `alt="4"` (desktop), `alt="7"` (mobile)
  - Admin Dashboard: `alt="11"` (desktop), `alt="8"` (mobile)
  - Additional Views: `alt="12"` (Profile Desktop), `alt="13"` (Cart Mobile)
- **Image URLs**: Used the provided GitHub URLs directly. Ensure these are publicly accessible in your repository’s `screenshots/` folder (e.g., `https://github.com/your-username/artisanmart/raw/main/screenshots/`). Replace `user-attachments` with your actual GitHub username or repository path.
- **Optimization**: Verify that images are optimized (<500KB each, PNG/JPEG) to ensure fast loading on GitHub. Rename files for clarity (e.g., `home-desktop.png`, `product-mobile.png`) if needed.
- **GitHub Compatibility**: The table is Markdown-friendly, rendering cleanly on GitHub. Desktop images are wider to reflect full-page views, while mobile images are narrower to showcase responsiveness.
- **Responsiveness**: The layout emphasizes ArtisanMart’s mobile-first design with Tailwind CSS, aligning with your FoodieHub-inspired UI expertise.

