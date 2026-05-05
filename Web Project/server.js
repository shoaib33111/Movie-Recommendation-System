const express = require('express');
const sql = require('mssql');
const path = require('path');

const app = express();
app.use(express.static('public'));

// ✅ APNA SQL SERVER KA NAAM YAHAN LIKHO
const dbConfig = {
  server: 'localhost',        // ya apna PC ka naam jaise: 'DESKTOP-ABC\\SQLEXPRESS'
  database: 'MovieDB',
  options: {
    encrypt: false,
    trustServerCertificate: true
  },
  authentication: {
    type: 'default',          // Windows Authentication use karne ke liye neeche wala option dekho
    options: {
      userName: '',           // SQL Login hai toh username likho, nahi toh khali rehne do
      password: ''            // SQL Login hai toh password likho, nahi toh khali rehne do
    }
  }
};

// Windows Authentication ke liye yeh use karo (upar wala hata do):
// const dbConfig = {
//   server: 'localhost',
//   database: 'MovieDB',
//   options: { encrypt: false, trustServerCertificate: true },
//   authentication: { type: 'ntlm', options: { domain: '', userName: '', password: '' } }
// };

let pool;

async function connectDB() {
  try {
    pool = await sql.connect(dbConfig);
    console.log('✅ Database se connect ho gaya!');
  } catch (err) {
    console.error('❌ Database connect nahi hua:', err.message);
    console.log('👉 server.js mein dbConfig check karo');
  }
}

// ─── API ROUTES ───────────────────────────────────────────

// 1. Search movies — SearchMovie procedure
app.get('/api/search', async (req, res) => {
  const keyword = req.query.q || '';
  try {
    const result = await pool.request()
      .input('Keyword', sql.VarChar(100), keyword)
      .execute('SearchMovie');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 2. Movies by genre — GetMoviesByGenre procedure
app.get('/api/genre/:id', async (req, res) => {
  try {
    const result = await pool.request()
      .input('GenreID', sql.Int, parseInt(req.params.id))
      .execute('GetMoviesByGenre');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 3. Top movies — GetTopMovies procedure
app.get('/api/top', async (req, res) => {
  try {
    const result = await pool.request().execute('GetTopMovies');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 4. Recommend movies — RecommendMovies procedure
app.get('/api/recommend/:userId', async (req, res) => {
  try {
    const result = await pool.request()
      .input('UserID', sql.Int, parseInt(req.params.userId))
      .execute('RecommendMovies');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 5. Genre Analysis — GenreAnalysis view
app.get('/api/analysis', async (req, res) => {
  try {
    const result = await pool.request()
      .query('SELECT * FROM GenreAnalysis ORDER BY TotalMovies DESC');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 6. Movie Ratings — MovieRatings view
app.get('/api/ratings', async (req, res) => {
  try {
    const result = await pool.request()
      .query('SELECT * FROM MovieRatings ORDER BY AvgRating DESC');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 7. All Movies
app.get('/api/movies', async (req, res) => {
  try {
    const result = await pool.request()
      .query(`SELECT M.*, G.GenreName FROM Movies M 
              JOIN Genres G ON M.GenreID = G.GenreID`);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─── START SERVER ─────────────────────────────────────────
connectDB().then(() => {
  app.listen(3000, () => {
    console.log('🎬 MovieDB chal raha hai: http://localhost:3000');
    console.log('   Browser mein yeh link kholo!');
  });
});
