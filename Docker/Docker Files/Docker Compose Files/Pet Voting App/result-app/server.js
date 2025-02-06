const express = require('express');
const { Pool } = require('pg');
const socketIO = require('socket.io');
const path = require('path');

const app = express();
const server = require('http').Server(app);
const io = socketIO(server);

// PostgreSQL connection
const pool = new Pool({
    user: process.env.POSTGRES_USER,
    host: process.env.POSTGRES_HOST,
    database: process.env.POSTGRES_DB,
    password: process.env.POSTGRES_PASSWORD,
    port: 5432,
});

app.use(express.static('public'));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

async function getVotes() {
    const result = await pool.query('SELECT pet, COUNT(*) as count FROM votes GROUP BY pet');
    return result.rows.reduce((acc, row) => {
        acc[row.pet] = parseInt(row.count);
        return acc;
    }, { dogs: 0, cats: 0, lizards: 0 });
}

io.on('connection', async (socket) => {
    const votes = await getVotes();
    socket.emit('current_votes', votes);
});

// Update all clients every 2 seconds
setInterval(async () => {
    const votes = await getVotes();
    io.emit('current_votes', votes);
}, 2000);

const port = process.env.PORT || 8085;
server.listen(port, () => {
    console.log(`Result app listening at http://localhost:${port}`);
});
