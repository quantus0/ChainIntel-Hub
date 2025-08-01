module Consensus

using JuliaOS
using SwarmCore
using Observables

function reach_consensus(swarm::ChainSwarm, analyses)
    prompt = """
    Reach consensus on:
    - Top opportunities
    - Highest risks
    - Recommended actions
    Analyses: $analyses
    """
    try
        response = swarm.coordinator.agent.useLLM(prompt, temperature=0.2)
        consensus = parse_consensus(response)
        swarm.status[] = Dict("status" => "consensus", "result" => consensus)
        return consensus
    catch e
        swarm.status[] = Dict("status" => "error", "error" => string(e))
        return Dict("error" => string(e))
    end
end

end