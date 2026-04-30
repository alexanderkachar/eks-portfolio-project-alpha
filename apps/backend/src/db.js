const { Pool } = require('pg');

function createPool() {
  return new Pool({
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT || '5432', 10),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    ssl: process.env.DB_SSL === 'false' ? false : { rejectUnauthorized: false },
  });
}

module.exports = { createPool };
