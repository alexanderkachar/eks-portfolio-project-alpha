const fs = require('fs/promises');
const path = require('path');
const { createPool } = require('./db');

async function main() {
  const migrationsDir = path.join(__dirname, '..', 'migrations');
  const files = (await fs.readdir(migrationsDir))
    .filter((file) => file.endsWith('.sql'))
    .sort();

  const pool = createPool();
  try {
    for (const file of files) {
      const sql = await fs.readFile(path.join(migrationsDir, file), 'utf8');
      console.log(`Applying migration ${file}`);
      await pool.query(sql);
    }
  } finally {
    await pool.end();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
