using Test
using Collectors

@testset "Data Tests" begin
    collector = Collectors.init_collector("coingecko")
    @test collector.source == "coingecko"
end