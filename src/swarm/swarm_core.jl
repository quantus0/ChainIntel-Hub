module SwarmCore

using JuliaOS
using Coordinator

mutable struct ChainSwarm
    coordinator::CoordinatorAgent
    agents::Vector{Agent}
    communication_protocol::String
end

function init_swarm()
    coordinator = Coordinator.init_coordinator()
    agents = [
        ChainMonitor.init_monitor("Solana"),
        ChainMonitor.init_monitor("Ethereum"),
        Analysis.init_analysis("Price"),
        Analysis.init_analysis("Volume")
    ]
    ChainSwarm(coordinator, agents, "async_message_passing")
end

function distribute_monitoring_tasks(swarm::ChainSwarm, time_window)
    tasks = [
        MonitoringTask("price_analysis", time_window),
        MonitoringTask("volume_analysis", time_window),
        MonitoringTask("tvl_tracking", time_window)
    ]
    swarm.coordinator.distribute_tasks(tasks)
end

end