const express = require('express');
const WebSocket = require('ws');
const app = express();
const wss = new WebSocket.Server({ port: 3000 });

app.use(express.json());

let swarmData = {
  status: {},
  opportunities: [],
  alerts: [],
};

// Simulate data updates from Julia backend
setInterval(() => {
  swarmData = {
    status: {
      solana: { status: Math.random() > 0.2 ? 'Normal' : 'High Activity' },
      ethereum: { status: Math.random() > 0.2 ? 'Normal' : 'High Gas' },
    },
    opportunities: [
      { action: 'Buy SOL', profit: (Math.random() * 5).toFixed(2) },
      { action: 'Sell ETH', profit: (Math.random() * 3).toFixed(2) },
    ],
    alerts: [
      { message: `Price spike detected: ${Math.random() > 0.5 ? 'SOL' : 'ETH'}`, severity: Math.random() > 0.7 ? 'high' : 'medium' },
    ],
  };
  wss.clients.forEach(client => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(swarmData));
    }
  });
}, 5000);

app.get('/api/status', (req, res) => res.json(swarmData.status));
app.get('/api/opportunities', (req, res) => res.json(swarmData.opportunities));
app.get('/api/alerts', (req, res) => res.json(swarmData.alerts));

app.listen(3000, () => console.log('API server running on port 3000'));