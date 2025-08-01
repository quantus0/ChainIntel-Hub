const { useState, useEffect } = React;

const App = () => {
  const [status, setStatus] = useState({});
  const [opportunities, setOpportunities] = useState([]);
  const [alerts, setAlerts] = useState([]);

  useEffect(() => {
    const ws = new WebSocket('ws://localhost:3000');
    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      if (data.status) setStatus(data.status);
      if (data.opportunities) setOpportunities(data.opportunities);
      if (data.alerts) setAlerts(data.alerts);
    };

    const ctx = document.getElementById('priceChart').getContext('2d');
    const priceChart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: [],
        datasets: [{ label: 'Price', data: [], borderColor: '#3b82f6' }],
      },
    });

    return () => ws.close();
  }, []);

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-3xl font-bold text-center mb-6">ChainIntel Hub</h1>
      <nav className="flex justify-center space-x-4 mb-6">
        <a href="#alerts" className="text-blue-600 hover:underline">Alerts</a>
        <a href="#opportunities" className="text-blue-600 hover:underline">Opportunities</a>
        <a href="#reports" className="text-blue-600 hover:underline">Reports</a>
      </nav>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-white p-4 rounded-lg shadow">
          <h2 className="text-xl font-semibold mb-4">Live Monitoring</h2>
          <canvas id="priceChart"></canvas>
          <div>
            <p>Solana: {status.solana?.status || 'Loading...'}</p>
            <p>Ethereum: {status.ethereum?.status || 'Loading...'}</p>
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow">
          <h2 className="text-xl font-semibold mb-4">Top Opportunities</h2>
          {opportunities.map((opp, i) => (
            <p key={i} className="mb-2">{opp.action}: {opp.profit.toFixed(2)}%</p>
          ))}
        </div>
        <div className="bg-white p-4 rounded-lg shadow col-span-2">
          <h2 className="text-xl font-semibold mb-4">Intelligence Feed</h2>
          {alerts.map((alert, i) => (
            <p key={i} className={`mb-2 text-${alert.severity === 'high' ? 'red' : 'yellow'}-600`}>
              {alert.message}
            </p>
          ))}
        </div>
      </div>
    </div>
  );
};

ReactDOM.render(<App />, document.getElementById('root'));