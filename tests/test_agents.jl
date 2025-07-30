using Test
using Coordinator
using ChainMonitor

@testset "Agent Tests" begin
    coordinator = Coordinator.init_coordinator()
    @test coordinator.agent.name == "ChainIntelCoordinator"
    
    solana_monitor = ChainMonitor.init_monitor("Solana")
    @test solana_monitor.chain == "Solana"
end