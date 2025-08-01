module Opportunities

using JuliaOS
using Random
using Observables

mutable struct QLearningAgent
    q_table::Dict{Tuple, Float64}
    learning_rate::Float64
    discount_factor::Float64
    exploration_rate::Float64
end

function init_q_learner()
    QLearningAgent(Dict(), 0.1, 0.9, 0.1)
end

function effective_profit(buy_price, sell_price, buy_vol, sell_vol, latency)
    slippage = (buy_vol + sell_vol) * 0.0005
    tx_cost = 0.01 * (buy_price + sell_price)
    return sell_price - buy_price - slippage - tx_cost - latency * 0.001
end

function select_action(learner::QLearningAgent, state)
    if rand() < learner.exploration_rate
        return rand(["buy", "sell", "hold"])
    end
    best_action = "hold"
    best_value = -Inf
    for action in ["buy", "sell", "hold"]
        value = get(learner.q_table, (state, action), 0.0)
        if value > best_value
            best_value = value
            best_action = action
        end
    end
    return best_action
end

function update_q_table!(learner::QLearningAgent, state, action, reward, next_state)
    current_q = get(learner.q_table, (state, action), 0.0)
    max_future_q = maximum([get(learner.q_table, (next_state, a), 0.0) for a in ["buy", "sell", "hold"]])
    new_q = current_q + learner.learning_rate * (reward + learner.discount_factor * max_future_q - current_q)
    learner.q_table[(state, action)] = new_q
end

mutable struct OpportunityDetector
    learner::QLearningAgent
    opportunities::Observable{Vector{Dict}}
end

function init_detector()
    OpportunityDetector(init_q_learner(), Observable(Dict[]))
end

function identify_opportunities(detector::OpportunityDetector, data)
    opportunities = Dict[]
    for item in data
        if haskey(item, "buy_price") && haskey(item, "sell_price")
            state = (item["buy_price"], item["sell_price"])
            action = select_action(detector.learner, state)
            if action != "hold"
                profit = effective_profit(item["buy_price"], item["sell_price"], 1000, 1000, 0.5)
                if profit > 0
                    opp = Dict("action" => action, "profit" => profit, "timestamp" => time())
                    push!(opportunities, opp)
                    reward = profit
                    next_state = (item["buy_price"] * 1.01, item["sell_price"] * 0.99)
                    update_q_table!(detector.learner, state, action, reward, next_state)
                    push!(detector.opportunities[], opp)
                end
            end
        end
    end
    return opportunities
end

end