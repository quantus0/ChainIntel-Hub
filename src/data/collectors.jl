module Collectors

using HTTP
using JSON

mutable struct DataCollector
    source::String
    config::Dict
end

function init_collector(source::String)
    config = Dict(
        "coingecko" => Dict("api_key" => ENV["COINGECKO_API_KEY"]),
        "defillama" => Dict("endpoint" => "https://api.llama.fi")
    )
    DataCollector(source, config[source])
end

function fetch_data(collector::DataCollector)
    if collector.source == "coingecko"
        resp = HTTP.get("https://api.coingecko.com/api/v3/coins/markets", 
            query=Dict("vs_currency" => "usd"))
        return JSON.parse(String(resp.body))
    end
    # Add more sources as needed
end

end