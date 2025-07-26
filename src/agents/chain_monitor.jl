module ChainMonitor

using JuliaOS
using Solana

mutable struct ChainMonitorAgent
    agent::Agent
    chain::String
    client::SolanaClient
end

function init_monitor(chain::String)
    llm_config = LLMConfig(model="gpt-4", temperature=0.3)
    agent = Agent(name="$(chain)Monitor", llm_config=llm_config)
    client = SolanaClient(rpc_url="https://api.mainnet-beta.solana.com")
    ChainMonitorAgent(agent, chain, client)
end

function monitor_chain(monitor::ChainMonitorAgent)
    data = monitor.client.get_recent_transactions()
    prompt = """
    Analyze $(monitor.chain) chain data:
    - Transaction volume
    - Smart contract activity
    - Token transfers
    Data: $data
    """
    response = monitor.agent.useLLM(prompt, temperature=0.2)
    return parse_analysis(response)
end

end