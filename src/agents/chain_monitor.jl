module ChainMonitor

using JuliaOS
using Solana
using Observables
using HTTP

abstract type ChainAdapter end

struct SolanaAdapter <: ChainAdapter
    endpoint::String
end

struct EthereumAdapter <: ChainAdapter
    endpoint::String
end

function get_block_time(adapter::SolanaAdapter)
    try
        client = SolanaClient(rpc_url=adapter.endpoint)
        return client.get_block_time()
    catch e
        return Dict("error" => string(e))
    end
end

function get_block_time(adapter::EthereumAdapter)
    try
        resp = HTTP.post(adapter.endpoint, JSON.serialize(Dict("method" => "eth_blockNumber")))
        return JSON.parse(String(resp.body))
    catch e
        return Dict("error" => string(e))
    end
end

mutable struct ChainMonitorAgent
    agent::Agent
    chain::String
    adapter::ChainAdapter
    data_stream::Observable{Dict}
end

function init_monitor(chain::String)
    llm_config = LLMConfig(model="gpt-4", temperature=0.3)
    agent = Agent(name="$(chain)Monitor", llm_config=llm_config)
    adapter = chain == "Solana" ? SolanaAdapter("https://api.mainnet-beta.solana.com") :
                EthereumAdapter("https://mainnet.infura.io/v3/your-project-id")
    ChainMonitorAgent(agent, chain, adapter, Observable(Dict()))
end

function monitor_chain(monitor::ChainMonitorAgent)
    data = get_block_time(monitor.adapter)
    prompt = """
    Analyze $(monitor.chain) chain data:
    - Transaction volume
    - Block time
    - Token transfers
    Data: $data
    """
    try
        response = monitor.agent.useLLM(prompt, temperature=0.2)
        monitor.data_stream[] = parse_analysis(response)
    catch e
        monitor.data_stream[] = Dict("error" => string(e))
    end
end

end