module SwarmCore

using JuliaOS
using Coordinator
using Graphs
using Distributions
using Observables
using Logging

mutable struct SwarmAgent
    id::Int
    state::Float64
    beliefs::Vector{Float64}
    history::Vector{Float64}
end

mutable struct ChainSwarm
    coordinator::CoordinatorAgent
    agents::Vector{SwarmAgent}
    trust_matrix::Matrix{Float64}
    communication_graph::SimpleGraph
    status::Observable{Dict}
end

function init_swarm()
    coordinator = Coordinator.init_coordinator()
    agents = [SwarmAgent(i, rand(), rand(5), Float64[]) for i in 1:10]
    n = length(agents)
    trust_matrix = rand(Uniform(0.8, 1.2), n, n)
    trust_matrix ./= sum(trust_matrix, dims=2)
    graph = erdos_renyi(n, 0.5)
    ChainSwarm(coordinator, agents, trust_matrix, graph, Observable(Dict("status" => "init")))
end

function distribute_monitoring_tasks(swarm::ChainSwarm, time_window)
    tasks = [
        MonitoringTask("price_analysis", time_window),
        MonitoringTask("volume_analysis", time_window),
        MonitoringTask("tvl_tracking", time_window)
    ]
    swarm.status[] = Dict("status" => "distributing", "tasks" => length(tasks))
    swarm.coordinator.distribute_tasks(tasks)
end

function update_beliefs!(swarm::ChainSwarm, env_data)
    for agent in swarm.agents
        push!(agent.history, agent.state)
        agent.state = env_data * 0.7 + agent.state * 0.3
        agent.beliefs = vcat(agent.beliefs[2:end], agent.state)
    end
    swarm.status[] = Dict("status" => "beliefs_updated")
end

function reach_consensus!(swarm::ChainSwarm)
    @info "Starting consensus process"
    for _ in 1:10
        new_states = zeros(length(swarm.agents))
        for i in 1:length(swarm.agents)
            neighbors = neighbors(swarm.communication_graph, i)
            weighted_sum = sum(swarm.trust_matrix[i,j] * swarm.agents[j].state for j in neighbors)
            new_states[i] = weighted_sum / length(neighbors)
        end
        for (i, agent) in enumerate(swarm.agents)
            agent.state = new_states[i]
            push!(agent.history, agent.state)
        end
        @info "Consensus round completed"
    end
    swarm.status[] = Dict("status" => "consensus_reached")
end

end