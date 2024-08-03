const WebSocket = require('ws');

// Create a WebSocket server instance
const wss = new WebSocket.Server({ port: 8080 });

wss.on('connection', ws => {
    console.log('Client connected');

    ws.on('message', message => {
        console.log('Received: %s', message);

        // Broadcast the received message to all connected clients
        wss.clients.forEach(client => {
            if (client !== ws && client.readyState === WebSocket.OPEN) {
                client.send(message);
            }
        });
    });

    ws.on('close', () => {
        console.log('Client disconnected');
    });
});

wss.on('listening', () => {
    console.log('Server listening on port 8080...');
});