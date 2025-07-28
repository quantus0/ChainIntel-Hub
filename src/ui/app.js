// Fetch data from backend
async function fetchChainData() {
    const response = await fetch('http://localhost:8080/api/data');
    return response.json();
}

// Update dashboard
async function updateDashboard() {
    const data = await fetchChainData();
    
    // Update chain status
    const statusDiv = document.getElementById('chain-status');
    statusDiv.innerHTML = `
        <p>Solana: ${data.solana.status}</p>
        <p>Ethereum: ${data.ethereum.status}</p>
        <p>Polygon: ${data.polygon.status}</p>
    `;
    
    // Update opportunities
    const oppDiv = document.getElementById('opportunity-list');
    oppDiv.innerHTML = data.opportunities.map(opp => `
        <p>${opp.name}: ${opp.profit}%</p>
    `).join('');
    
    // Update alerts
    const alertDiv = document.getElementById('alert-feed');
    alertDiv.innerHTML = data.alerts.map(alert => `
        <p>${alert.message}</p>
    `).join('');
}

// Refresh every 30 seconds
setInterval(updateDashboard, 30000);
updateDashboard();