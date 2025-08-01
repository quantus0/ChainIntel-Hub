using Test
using SwarmCore

@testset "Swarm Tests" begin
    swarm = SwarmCore.init_swarm()
    @test length(swarm.agents) == 10
    @test size(swarm.trust_matrix) == (10, 10)
    @test nv(swarm.communication_graph) == 10
    @test haskey(swarm.status[], "status")
end