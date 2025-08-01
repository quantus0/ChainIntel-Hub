module Coordinator

using JuliaOS
using Observables

mutable struct CoordinatorAgent
    agent::Agent
    tasks::Vector{Task}
    status::Observable{Dict}
end

function init_coordinator()
    llm_config = LLMConfig(
        model="gpt-4",
        temperature=0.3,
        max_tokens=2000
    )
    agent = Agent(name="ChainIntelCoordinator", llm_config=llm_config)
    CoordinatorAgent(agent, [], Observable(Dict("status" => "idle")))
end

function distribute_tasks(coordinator::CoordinatorAgent, tasks::Vector{Task})
    coordinator.status[] = Dict("status" => "distributing", "tasks" => length(tasks))
    for task in tasks
        prompt = "Assign task: $(task.description) to appropriate agent"
        try
            response = coordinator.agent.useLLM(prompt, temperature=0.2)
            assign_task(coordinator, task, parse_agent(response))
        catch e
            coordinator.status[] = Dict("status" => "error", "error" => string(e))
        end
    end
    coordinator.status[] = Dict("status" => "complete")
end

function aggregate_results(coordinator::CoordinatorAgent)
    prompt = """
    Aggregate results from all agents:
    - Summarize key findings
    - Identify cross-chain patterns
    - Generate actionable insights
    """
    response = coordinator.agent.useLLM(prompt, temperature=0.2)
    coordinator.status[] = Dict("status" => "aggregated", "results" => response)
    return parse_summary(response)
end

end