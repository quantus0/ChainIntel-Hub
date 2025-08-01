module Collectors

using HTTP
using JSON
using Observables

mutable struct DataCollector
    source::String
    config::Dict
    data::Observable{Dict}
end

function init_collector(source::String)
    config = Dict(
        "coingecko" => Dict("api_key" => ENV["COINGECKO_API_KEY"]),
        "defillama" => Dict("endpoint" => "https://api.llama.fi")
    )
    DataCollector(source, config[source], Observable(Dict()))
end

function fetch_data(collector::DataCollector)
    try
        if collector.source == "coingecko"
            resp = HTTP.get("https://api.coingecko.com/api/v3/coins/markets",
                query=Dict("vs_currency" => "usd"))
            data = JSON.parse(String(resp.body))
            collector.data[] = data
            return data
        end
    catch e
        collector.data[] = Dict("error" => string(e))
        return Dict("error" => string(e))
    end
end

end