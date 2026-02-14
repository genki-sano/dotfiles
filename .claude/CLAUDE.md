# Principles

## Core

- Don't hold back. Give it your all.
- Always Think in English, but respond in Japanese.
- For maximum efficiency, whenever you need to perform multiple independent operations, invoke all relevant tools simultaneously rather than sequentially.
- MUST use subagents for complex problem verification
- After receiving tool results, carefully reflect on their quality and determine optimal next steps before proceeding. Use your thinking to plan and iterate based on this new information, and then take the best next action.

## Agent Delegation Strategy

### CRITICAL

- The primary agent must act exclusively as an orchestrator.
- Do not perform execution tasks directly; all actual work must be delegated to sub-agents.

### Delegation Priority

1. Specialized Sub-Agents: Priority must be given to a specialized sub-agent if one exists for the specific task.
2. General-Purpose Sub-Agents: If no specialized agent is suitable, use the `general-purpose` Task Agent.
   - For complex reasoning or deep analysis: Specify `model: opus`.
   - For straightforward tasks or implementation: Specify `model: sonnet`.
