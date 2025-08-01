using Test
using Coordinator
using ChainMonitor

@testset "Agent Tests" begin
    coordinator = Coordinator.init_coordinator()
    @test coordinator.agent.name == "ChainIntelCoordinator"
    @test haskey(coordinator.status[], "status")

    solana_monitor = ChainMonitor.init_monitor("Solana")
    @test solana_monitor.chain == "Solana"
    @test solana_monitor.adapter isa ChainMonitor.SolanaAdapter
end