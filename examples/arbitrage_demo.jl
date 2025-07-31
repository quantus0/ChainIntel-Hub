using SwarmCore
using Opportunities

function run_arbitrage_demo()
    swarm = SwarmCore.init_swarm()
    data = Dict(
        "solana_price" => 150.0,
        "ethereum_price" => 152.0
    )
    opportunities = Opportunities.identify_opportunities(data)
    println("Arbitrage Opportunities: ", opportunities)
end

run_arbitrage_demo()