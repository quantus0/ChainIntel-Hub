module Reporter

using JuliaOS
using Observables

mutable struct ReporterAgent
    agent::Agent
    reports::Observable{Vector{String}}
end

function init_reporter()
    llm_config = LLMConfig(model="gpt-4", temperature=0.3)
    agent = Agent(name="ReportGenerator", llm_config=llm_config)
    ReporterAgent(agent, Observable(String[]))
end

function generate_report(reporter::ReporterAgent, analyses)
    prompt = """
    Generate comprehensive report:
    - Summarize cross-chain insights
    - Highlight opportunities
    - List risks
    Analyses: $analyses
    """
    try
        response = reporter.agent.useLLM(prompt, temperature=0.2)
        report = parse_report(response)
        push!(reporter.reports[], report)
        return report
    catch e
        push!(reporter.reports[], "Error: $(string(e))")
        return "Error: $(string(e))"
    end
end

end