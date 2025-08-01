module Anomaly

using JuliaOS
using StatsBase
using DataStructures
using Observables

mutable struct AnomalyDetector
    window::CircularDeque{Float64}
    threshold::Float64
    anomalies::Observable{Vector{Dict}}
end

function init_detector(window_size::Int=100, threshold::Float64=3.0)
    AnomalyDetector(CircularDeque{Float64}(window_size), threshold, Observable(Dict[]))
end

function detect_anomaly(detector::AnomalyDetector, value::Float64)
    push!(detector.window, value)
    if length(detector.window) >= 10
        μ = mean(detector.window)
        σ = std(detector.window)
        z_score = abs(value - μ) / (σ + 1e-10)
        if z_score > detector.threshold
            severity = z_score > 5.0 ? "high" : z_score > 3.5 ? "medium" : "low"
            anomaly = Dict("value" => value, "z_score" => z_score, "severity" => severity, "timestamp" => time())
            push!(detector.anomalies[], anomaly)
            return true
        end
    end
    return false
end

function analyze_data(data)
    detector = init_detector()
    anomalies = Dict[]
    for item in data
        if haskey(item, "price_usd")
            if detect_anomaly(detector, item["price_usd"])
                push!(anomalies, detector.anomalies[][end])
            end
        end
    end
    return anomalies
end

end