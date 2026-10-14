
const express = require('express');

const app = express();
const PORT = 3000;

app.use(express.json());

const places = [
  {
    id: 1,
    name: 'Patenga Sea Beach',
    district: 'Chattogram',
    category: 'Beach'
  },
  {
    id: 2,
    name: 'Sajek Valley',
    district: 'Rangamati',
    category: 'Hill'
  },
  {
    id: 3,
    name: 'Kaptai Lake',
    district: 'Rangamati',
    category: 'Lake'
  }
];

app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to TripPilot API!'
  });
});


app.get('/api/places', (req, res) => {
  const page = Math.max(1, parseInt(req.query.page) || 1);
  const limit = Math.max(1, parseInt(req.query.limit) || 2);

  const startIndex = (page - 1) * limit;
  const paginatedPlaces = places.slice(
    startIndex,
    startIndex + limit
  );

  res.json({
    success: true,
    page: page,
    limit: limit,
    totalPlaces: places.length,
    totalPages: Math.ceil(places.length / limit),
    data: paginatedPlaces
  });
});

app.listen(PORT, () => {
  console.log(`TripPilot API running at http://localhost:${PORT}`);
});
