
const express = require('express');
const { initializeApp, cert } = require('firebase-admin/app');
const { buildSchema } = require('graphql');
const { createHandler } = require('graphql-http/lib/use/express');
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



const createPlace = (id, name, district, category, description) => ({
  id,
  name,
  district,
  category,
  description,
  entryFee: 'To be verified',
  openingHours: 'To be verified',
  imageUrl: '',
  mapQuery: `${name}, ${district}, Bangladesh`,
  videoUrl: ''
});

const places = [
  {
  ...createPlace(1, 'Patenga Sea Beach', 'Chattogram', 'Beach',
    'A popular sea beach in Chattogram, known for its coastal views, sunset scenery and nearby ship activities.'),
  videoUrl: 'https://youtu.be/FqcQZDPwZzE'
},

  {
  ...createPlace(2, "Foy's Lake", 'Chattogram', 'Lake',
    'A scenic man-made lake surrounded by hills in the Pahartali area of Chattogram.'),
  videoUrl: 'https://youtu.be/SyJwTsznMDU?si=9KPSfbTsr59DBpc3'
},

  createPlace(3, 'Chandranath Hill', 'Chattogram', 'Hill',
    'A well-known hill in Sitakunda, popular for hiking, natural scenery and the Chandranath Temple.'),

  createPlace(4, 'Sitakunda Botanical Garden and Eco Park', 'Chattogram', 'Park',
    'A natural eco-tourism destination in Sitakunda, featuring green surroundings, forest trails and waterfalls.'),

  {
  ...createPlace(5, 'Guliakhali Sea Beach', 'Chattogram', 'Beach',
    'A coastal destination in Sitakunda, known for its green vegetation, tidal waterways and distinctive natural scenery.'),
  videoUrl: 'https://youtu.be/dgLKMdIxmvw?si=SOviCXd4ieqbw_yv'
},

  {
  ...createPlace(6, 'Banshbaria Sea Beach', 'Chattogram', 'Beach',
    'A coastal destination in Sitakunda known for its beach views and peaceful natural surroundings.'),
  videoUrl: 'https://youtu.be/A020yPqyFBk?si=lEQ-hiT7Ska3B1Z0'
},

  createPlace(7, 'Khoiyachora Waterfall', 'Chattogram', 'Waterfall',
    'A popular multi-step waterfall located in the hills of Mirsarai.'),

  createPlace(8, 'Chattogram War Cemetery', 'Chattogram', 'Historical',
    'A memorial cemetery honoring soldiers who died during the Second World War.'),

  createPlace(9, "Cox's Bazar Sea Beach", "Cox's Bazar", 'Beach',
    'A famous sandy beach along the Bay of Bengal and one of Bangladesh’s major tourist destinations.'),

  createPlace(10, 'Inani Beach', "Cox's Bazar", 'Beach',
    'A scenic beach known for its rocky shoreline, clear coastal views and natural surroundings.'),

  createPlace(11, 'Himchari National Park', "Cox's Bazar", 'Park',
    'A natural park featuring hills, forest areas, waterfalls and coastal scenery.'),

  createPlace(12, 'Maheshkhali Island', "Cox's Bazar", 'Island',
    'An island known for its hills, coastal landscapes and traditional communities.'),

  createPlace(13, 'Adinath Temple', "Cox's Bazar", 'Historical',
    'A historic Hindu temple situated on the top of Mainak Hill in Maheshkhali.'),

  createPlace(14, 'Sonadia Island', "Cox's Bazar", 'Island',
    'A coastal island known for its sandy beaches, mangrove areas and natural environment.'),

  createPlace(15, "Saint Martin's Island", "Cox's Bazar", 'Island',
    'A coral island in the Bay of Bengal known for its beaches and marine environment.'),

  createPlace(16, 'Ramu Buddhist Temple', "Cox's Bazar", 'Historical',
    'A Buddhist religious and cultural site featuring temples and traditional architecture.'),

  createPlace(17, 'Kaptai Lake', 'Rangamati', 'Lake',
    'A large lake surrounded by green hills and scenic landscapes in Rangamati.'),

  createPlace(18, 'Shuvolong Waterfall', 'Rangamati', 'Waterfall',
    'A waterfall near Kaptai Lake that attracts visitors for its natural scenery.'),

  createPlace(19, 'Rangamati Hanging Bridge', 'Rangamati', 'Landmark',
    'A well-known suspension bridge offering views of Kaptai Lake and the surrounding hills.'),

  createPlace(20, 'Rajban Vihara', 'Rangamati', 'Historical',
    'A significant Buddhist monastery and religious destination in Rangamati.'),

  createPlace(21, 'Peda Ting Ting', 'Rangamati', 'Island',
    'A popular island destination on Kaptai Lake known for its scenic surroundings.'),

  createPlace(22, 'Nilachal', 'Bandarban', 'Hill',
    'A hilltop viewpoint offering panoramic views of Bandarban and the surrounding landscape.'),

  createPlace(23, 'Nilgiri', 'Bandarban', 'Hill',
    'A popular hilltop destination known for its mountain scenery and cloud-covered views.'),

  createPlace(24, 'Boga Lake', 'Bandarban', 'Lake',
    'A natural mountain lake surrounded by hills in the remote areas of Bandarban.'),

  createPlace(25, 'Nafakhum Waterfall', 'Bandarban', 'Waterfall',
    'A notable waterfall on the Remakri River, surrounded by the hills of Bandarban.'),

  createPlace(26, 'Buddha Dhatu Jadi', 'Bandarban', 'Historical',
    'A prominent Buddhist temple known for its golden exterior and hilltop location.'),

  createPlace(27, 'Alutila Cave', 'Khagrachhari', 'Cave',
    'A natural cave attraction located in the Alutila hills of Khagrachhari.'),

  createPlace(28, 'Richhang Waterfall', 'Khagrachhari', 'Waterfall',
    'A natural waterfall surrounded by greenery and hills in Khagrachhari.'),

  createPlace(29, 'Debota Pukur', 'Khagrachhari', 'Lake',
    'A scenic natural waterbody located in the hilly landscape of Khagrachhari.'),

  createPlace(30, 'Khagrachhari Horticulture Park', 'Khagrachhari', 'Park',
    'A green recreational area featuring gardens and natural surroundings.'),

  createPlace(31, 'Muhuri Project', 'Feni', 'Lake',
    'A water management and irrigation project featuring a large waterbody and open landscapes.'),

  createPlace(32, 'Bijoy Singh Dighi', 'Feni', 'Lake',
    'A historic large pond and local landmark in Feni.'),

  createPlace(33, 'Rajajhir Dighi', 'Feni', 'Lake',
    'A historic waterbody and popular local landmark in Feni.'),

  createPlace(34, 'Nijhum Dwip', 'Noakhali', 'Island',
    'An island destination known for its natural landscapes, wildlife and mangrove forests.'),

  createPlace(35, 'Gandhi Ashram', 'Noakhali', 'Historical',
    'A historical institution preserving the memory and work of Mahatma Gandhi in the region.'),

  createPlace(36, 'Bajra Shahi Mosque', 'Noakhali', 'Historical',
    'A historic mosque known for its traditional Mughal-inspired architectural features.'),

  createPlace(37, 'Musapur Closer', 'Noakhali', 'Beach',
    'A coastal area near the Feni River estuary, known for its open landscape and water views.'),

  createPlace(38, 'Dalal Bazar Zamindar Bari', 'Lakshmipur', 'Historical',
    'A historic zamindar residence reflecting the architectural heritage of the region.'),

  createPlace(39, 'Jinn Mosque', 'Lakshmipur', 'Historical',
    'A locally known religious site associated with traditional stories and local heritage.'),

  createPlace(40, 'Ramgati Meghna River Bank', 'Lakshmipur', 'River',
    'A riverside destination offering views of the Meghna River and its surrounding landscape.'),

  createPlace(41, 'Shalban Vihara', 'Cumilla', 'Historical',
    'An important archaeological site featuring the remains of an ancient Buddhist monastery.'),

  createPlace(42, 'Mainamati Museum', 'Cumilla', 'Historical',
    'An archaeological museum displaying artifacts discovered in the Mainamati region.'),

  createPlace(43, 'Mainamati War Cemetery', 'Cumilla', 'Historical',
    'A memorial cemetery honoring Commonwealth soldiers who died during the Second World War.'),

  createPlace(44, 'Dharmasagar Dighi', 'Cumilla', 'Lake',
    'A historic large pond and popular recreational landmark in Cumilla.'),

  createPlace(45, 'Three Rivers Confluence', 'Chandpur', 'River',
    'A river viewpoint near Chandpur where several major rivers meet.'),

  createPlace(46, 'Boro Station Molehead', 'Chandpur', 'River',
    'A popular riverside area in Chandpur known for its river views and local atmosphere.'),

  createPlace(47, 'Hajiganj Boro Masjid', 'Chandpur', 'Historical',
    'A prominent mosque and religious landmark in Hajiganj.'),

  createPlace(48, 'Arifail Mosque', 'Brahmanbaria', 'Historical',
    'A historic mosque in Sarail known for its traditional architectural design.'),

  createPlace(49, 'Haripur Zamindar Bari', 'Brahmanbaria', 'Historical',
    'A historic zamindar residence reflecting the architectural heritage of Brahmanbaria.'),

  createPlace(50, 'Titas River', 'Brahmanbaria', 'River',
    'A well-known river flowing through the Brahmanbaria region and surrounding landscapes.')
];
const schema = buildSchema(`
  type Place {
    id: Int
    name: String
    district: String
    category: String
    description: String
    entryFee: String
    openingHours: String
    imageUrl: String
    mapQuery: String
    videoUrl: String
  }

  type Query {
    places(district: String, category: String, search: String): [Place]
    place(id: Int!): Place
  }
`);
const root = {
  places: ({ district, category, search }) => {
    const normalizedSearch = (search || '').trim().toLowerCase();

    return places.filter((place) => {
      const matchesDistrict =
        !district || place.district === district;

      const matchesCategory =
        !category || place.category === category;

      const matchesSearch =
        !normalizedSearch ||
        place.name.toLowerCase().includes(normalizedSearch);

      return matchesDistrict && matchesCategory && matchesSearch;
    });
  },

  place: ({ id }) => {
    return places.find((place) => place.id === id) || null;
  }
};
console.log('FIRST PLACE:', places[0]);


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

  console.log('API ROUTE DATA:', filteredPlaces[0]);
  
res.json({
  success: true,
  page,
  limit,
  totalPlaces,
  totalPages,
  data: filteredPlaces
    .slice(startIndex, startIndex + limit)
    .map((place) => ({
      id: place.id,
      name: place.name,
      district: place.district,
      category: place.category,
      description: place.description || 'Description not available.',
      entryFee: place.entryFee || 'To be verified',
      openingHours: place.openingHours || 'To be verified',
      imageUrl: place.imageUrl || '',
      mapQuery: place.mapQuery || `${place.name}, ${place.district}, Bangladesh`,
      videoUrl: place.videoUrl || ''
    }))
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
app.all('/graphql', createHandler({
  schema: schema,
  rootValue: root
}));
app.listen(PORT, () => {
  console.log(`TripPilot API running at http://localhost:${PORT}`);
});
