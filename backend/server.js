
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
  // 1. Chattogram
  { id: 1, name: 'Patenga Sea Beach', district: 'Chattogram', category: 'Beach' },
  { id: 2, name: "Foy's Lake", district: 'Chattogram', category: 'Lake' },
  { id: 3, name: 'Chandranath Hill', district: 'Chattogram', category: 'Hill' },
  { id: 4, name: 'Sitakunda Botanical Garden and Eco Park', district: 'Chattogram', category: 'Park' },
  { id: 5, name: 'Guliakhali Sea Beach', district: 'Chattogram', category: 'Beach' },
  { id: 6, name: 'Banshbaria Sea Beach', district: 'Chattogram', category: 'Beach' },
  { id: 7, name: 'Khoiyachora Waterfall', district: 'Chattogram', category: 'Waterfall' },
  { id: 8, name: 'Chattogram War Cemetery', district: 'Chattogram', category: 'Historical' },

  // 2. Cox's Bazar
  { id: 9, name: "Cox's Bazar Sea Beach", district: "Cox's Bazar", category: 'Beach' },
  { id: 10, name: 'Inani Beach', district: "Cox's Bazar", category: 'Beach' },
  { id: 11, name: 'Himchari National Park', district: "Cox's Bazar", category: 'Park' },
  { id: 12, name: 'Maheshkhali Island', district: "Cox's Bazar", category: 'Island' },
  { id: 13, name: 'Adinath Temple', district: "Cox's Bazar", category: 'Historical' },
  { id: 14, name: 'Sonadia Island', district: "Cox's Bazar", category: 'Island' },
  { id: 15, name: "Saint Martin's Island", district: "Cox's Bazar", category: 'Island' },
  { id: 16, name: 'Ramu Buddhist Temple', district: "Cox's Bazar", category: 'Historical' },

  // 3. Rangamati
  { id: 17, name: 'Kaptai Lake', district: 'Rangamati', category: 'Lake' },
  { id: 18, name: 'Shuvolong Waterfall', district: 'Rangamati', category: 'Waterfall' },
  { id: 19, name: 'Rangamati Hanging Bridge', district: 'Rangamati', category: 'Landmark' },
  { id: 20, name: 'Rajban Vihara', district: 'Rangamati', category: 'Historical' },
  { id: 21, name: 'Peda Ting Ting', district: 'Rangamati', category: 'Island' },

  // 4. Bandarban
  { id: 22, name: 'Nilachal', district: 'Bandarban', category: 'Hill' },
  { id: 23, name: 'Nilgiri', district: 'Bandarban', category: 'Hill' },
  { id: 24, name: 'Boga Lake', district: 'Bandarban', category: 'Lake' },
  { id: 25, name: 'Nafakhum Waterfall', district: 'Bandarban', category: 'Waterfall' },
  { id: 26, name: 'Buddha Dhatu Jadi', district: 'Bandarban', category: 'Historical' },

  // 5. Khagrachhari
  { id: 27, name: 'Alutila Cave', district: 'Khagrachhari', category: 'Cave' },
  { id: 28, name: 'Richhang Waterfall', district: 'Khagrachhari', category: 'Waterfall' },
  { id: 29, name: 'Debota Pukur', district: 'Khagrachhari', category: 'Lake' },
  { id: 30, name: 'Khagrachhari Horticulture Park', district: 'Khagrachhari', category: 'Park' },

  // 6. Feni
  { id: 31, name: 'Muhuri Project', district: 'Feni', category: 'Lake' },
  { id: 32, name: 'Bijoy Singh Dighi', district: 'Feni', category: 'Lake' },
  { id: 33, name: 'Rajajhir Dighi', district: 'Feni', category: 'Lake' },

  // 7. Noakhali
  { id: 34, name: 'Nijhum Dwip', district: 'Noakhali', category: 'Island' },
  { id: 35, name: 'Gandhi Ashram', district: 'Noakhali', category: 'Historical' },
  { id: 36, name: 'Bajra Shahi Mosque', district: 'Noakhali', category: 'Historical' },
  { id: 37, name: 'Musapur Closer', district: 'Noakhali', category: 'Beach' },

  // 8. Lakshmipur
  { id: 38, name: 'Dalal Bazar Zamindar Bari', district: 'Lakshmipur', category: 'Historical' },
  { id: 39, name: 'Jinn Mosque', district: 'Lakshmipur', category: 'Historical' },
  { id: 40, name: 'Ramgati Meghna River Bank', district: 'Lakshmipur', category: 'River' },

  // 9. Cumilla
  { id: 41, name: 'Shalban Vihara', district: 'Cumilla', category: 'Historical' },
  { id: 42, name: 'Mainamati Museum', district: 'Cumilla', category: 'Historical' },
  { id: 43, name: 'Mainamati War Cemetery', district: 'Cumilla', category: 'Historical' },
  { id: 44, name: 'Dharmasagar Dighi', district: 'Cumilla', category: 'Lake' },

  // 10. Chandpur
  { id: 45, name: 'Three Rivers Confluence', district: 'Chandpur', category: 'River' },
  { id: 46, name: 'Boro Station Molehead', district: 'Chandpur', category: 'River' },
  { id: 47, name: 'Hajiganj Boro Masjid', district: 'Chandpur', category: 'Historical' },

  // 11. Brahmanbaria
  { id: 48, name: 'Arifail Mosque', district: 'Brahmanbaria', category: 'Historical' },
  { id: 49, name: 'Haripur Zamindar Bari', district: 'Brahmanbaria', category: 'Historical' },
  { id: 50, name: 'Titas River', district: 'Brahmanbaria', category: 'River' }
];


app.get('/api/places', (req, res) => {
  const requestedPage = Math.max(1, parseInt(req.query.page) || 1);
  const limit = Math.max(1, parseInt(req.query.limit) || 5);

  const district = (req.query.district || '').toString();
  const category = (req.query.category || '').toString();
  const search = (req.query.search || '').toString().trim().toLowerCase();

  const filteredPlaces = places.filter((place) => {
    const matchesDistrict =
      !district || place.district === district;

    const matchesCategory =
      !category || place.category === category;

    const matchesSearch =
      !search || place.name.toLowerCase().includes(search);

    return matchesDistrict && matchesCategory && matchesSearch;
  });

  const totalPlaces = filteredPlaces.length;
  const totalPages = Math.max(1, Math.ceil(totalPlaces / limit));

  const page = Math.min(requestedPage, totalPages);
  const startIndex = (page - 1) * limit;

  res.json({
    success: true,
    page,
    limit,
    totalPlaces,
    totalPages,
    data: filteredPlaces.slice(startIndex, startIndex + limit)
  });
});


app.get('/', (req, res) => {
  res.json({ message: 'Welcome to TripPilot API!' });
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
