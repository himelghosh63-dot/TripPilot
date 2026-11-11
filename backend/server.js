
const express = require('express');
const { initializeApp, cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('./serviceAccountKey.json');
const app = express();
const PORT = 3000;

const FIREBASE_API_KEY = 'AIzaSyA27y6HOVIYhdv4HChLbW3hujb2XDw3c0s';

initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();
const auth = getAuth();

app.use(express.json());

const places = [
  { id: 1, name: 'Patenga Sea Beach', district: 'Chattogram', category: 'Beach' },
  { id: 2, name: 'Sajek Valley', district: 'Rangamati', category: 'Hill' },
  { id: 3, name: 'Kaptai Lake', district: 'Rangamati', category: 'Lake' }
];

app.get('/', (req, res) => {
  res.json({ message: 'Welcome to TripPilot API!' });
});

app.get('/api/places', (req, res) => {
  const page = Math.max(1, parseInt(req.query.page) || 1);
  const limit = Math.max(1, parseInt(req.query.limit) || 2);
  const startIndex = (page - 1) * limit;

  res.json({
    success: true,
    page,
    limit,
    totalPlaces: places.length,
    totalPages: Math.ceil(places.length / limit),
    data: places.slice(startIndex, startIndex + limit)
  });
});
app.use((req, res, next) => {
  console.log('REQUEST:', req.method, req.url);
  next();
});
console.log('LOGIN ROUTE LOADED');

app.post('/api/auth/login', async (req, res) => {
  try {
    const { identifier, password } = req.body;

    if (!identifier || !password) {
      return res.status(400).json({
        success: false,
        message: 'Username/Email and password are required.'
      });
    }

    let email = identifier.trim();

    if (!email.includes('@')) {
      const usernameDoc = await db
        .collection('usernames')
        .doc(email.toLowerCase())
        .get();

      if (!usernameDoc.exists) {
        return res.status(401).json({
          success: false,
          message: 'Invalid username or password.'
        });
      }

      email = usernameDoc.data().email;
    }

    const response = await fetch(
      `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${FIREBASE_API_KEY}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email,
          password,
          returnSecureToken: true
        })
      }
    );

    const result = await response.json();
    console.log('FIREBASE LOGIN ERROR:', result.error?.message || 'No error');

    if (!response.ok) {
      return res.status(401).json({
        success: false,
        message: 'Invalid username/email or password.'
      });
    }

    const user = await auth.getUser(result.localId);

    if (!user.emailVerified) {
      return res.status(403).json({
        success: false,
        message: 'Please verify your email first.'
      });
    }

    const customToken = await auth.createCustomToken(user.uid);

    res.json({ success: true, customToken });

  } catch (error) {
    console.error('Login error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Login failed. Please try again.'
    });
  }
});

app.listen(PORT, () => {
  console.log(`TripPilot API running at http://localhost:${PORT}`);
});
