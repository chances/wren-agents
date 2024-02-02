# wren-agents

Agent-based modeling (ABM) framework for [Wren](https://wren.io) applications.

An agent-based (or individual-based) model is a computational simulation of autonomous agents that react to their
environment (including other agents) given a predefined set of rules <sup>[[1](http://doi.org/10.1016/j.ecolmodel.2006.04.023)]</sup>. Many real-world emergent behaviors given simple agent interactions can only be captured in an
agent-based model.

## Features
- Base-class library (BCL) to create agent-based models
- `Space` base-class to represent the area agents occupy, including these implementations:
  - `Grid` - 2D areas of a given size
  - `Graph` - Network of agents

## Prior Art
- [agents.jl](https://juliadynamics.github.io/Agents.jl/stable)

## License

[MIT License](https://opensource.org/licenses/MIT)

Copyright &copy; 2024 Chance Snow. All rights reserved.
