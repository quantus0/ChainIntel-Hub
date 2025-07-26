module Consensus

using JuliaOS
using SwarmCore

function reach_consensus(swarm::ChainSwarm, analyses)
    prompt = """
    Reach consensus on:
    - Top opportunities
    - Highest risks
    - Recommended actions
    Analyses: $analyses
    """
    response = swarm.coordinator.agent.useLLM(prompt, temperature=0.2)
    return parse_consensus(response)
end

end