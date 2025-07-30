using Test
using Anomaly

@testset "Analysis Tests" begin
    data = Dict("volume" => 1000, "price" => 100)
    anomalies = Anomaly.detect_anomalies(data)
    @test !isempty(anomalies)
end