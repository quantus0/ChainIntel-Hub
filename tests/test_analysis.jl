using Test
using Anomaly
using Opportunities

@testset "Analysis Tests" begin
    data = [Dict("price_usd" => 100.0 + i * 10) for i in 1:20]
    push!(data, Dict("price_usd" => 1000.0))
    anomalies = Anomaly.analyze_data(data)
    @test length(anomalies) >= 1
    @test anomalies[end]["severity"] == "high"

    opp_data = [Dict("buy_price" => 100.0, "sell_price" => 110.0)]
    detector = Opportunities.init_detector()
    opportunities = Opportunities.identify_opportunities(detector, opp_data)
    @test !isempty(opportunities)
end