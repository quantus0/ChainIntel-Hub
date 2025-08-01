module Analysis

using JuliaOS
using Observables

mutable struct AnalysisAgent
    agent::Agent
    specialization::String
    insights::Observable{Dict}
end

function init_analysis(specialization::String)
    llm_config = LLMConfig(model="gpt-4", temperature=0.3)
    agent = Agent(name="$(specialization)Analysis", llm_config=llm_config)
    AnalysisAgent(agent, specialization, Observable(Dict()))
end

function analyze_data(analyst::AnalysisAgent, data)
    prompt = """
    Perform $(analyst.specialization) analysis:
    - Identify patterns
    - Calculate metrics
    - Generate insights
    Data: $data
    """
    try
        response = analyst.agent.useLLM(prompt, temperature=0.2)
        insights = parse_insights(response)
        analyst.insights[] = insights
        return insights
    catch e
        analyst.insights[] = Dict("error" => string(e))
        return Dict("error" => string(e))
    end
end

end