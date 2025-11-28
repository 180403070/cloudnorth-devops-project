const express = require('express');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'CloudNorth Backend is running' });
});

app.get('/api/products', (req, res) => {
  const products = [
    { id: 1, name: 'Laptop', price: 999.99, category: 'Electronics' },
    { id: 2, name: 'Smartphone', price: 699.99, category: 'Electronics' },
    { id: 3, name: 'Headphones', price: 199.99, category: 'Electronics' },
    { id: 4, name: 'T-Shirt', price: 29.99, category: 'Clothing' },
    { id: 5, name: 'Coffee Mug', price: 14.99, category: 'Home' },
  ];
  res.json(products);
});

// Start server
app.listen(port, () => {
  console.log(`CloudNorth Backend API running on port ${port}`);
});
