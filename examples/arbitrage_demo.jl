using SwarmCore
using Opportunities
using Plots
using HTTP
using JSON
using ArgParse

function parse_args()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--testnet"
            help = "Use Solana testnet data"
            action = :store_true
    end
    return parse_args(s)
end

function fetch_testnet_data()
    try
        resp = HTTP.get("https://api.testnet.solana.com", JSON.serialize(Dict("method" => "getRecentBlockhash")))
        return JSON.parse(String(resp.body))
    catch e
        return Dict("price" => 150.0 + randn() * 5)
    end
end

function run_arbitrage_demo()
    args = parse_args()
    swarm = SwarmCore.init_swarm()
    data = args["testnet"] ? fetch_testnet_data() : Dict(
        "buy_price" => 150.0 + randn() * 5,
        "sell_price" => 152.0 + randn() * 5
    )
    detector = Opportunities.init_detector()
    opportunities = Opportunities.identify_opportunities(detector, [data])
    
    println("Arbitrage Opportunities: ", opportunities)
    
    prices = [data["buy_price"], data["sell_price"]]
    plot = plot(prices, label=["Buy" "Sell"], title="Arbitrage Spread", lw=2)
    savefig(plot, "arbitrage_plot.png")
    println("Plot saved as arbitrage_plot.png")
end

run_arbitrage_demo()