/// Agent-based modeling (ABM) framework for Wren applications.
///
/// An agent-based (or individual-based) model is a computational simulation of autonomous agents that react to their environment (including other agents) given a predefined set of rules ^[[1](http://doi.org/10.1016/j.ecolmodel.2006.04.023)]^.
/// Many real-world emergent behaviors given simple agent interactions can only be captured in an agent-based model.
///
/// ## Prior Art
///
/// [agents.jl](https://juliadynamics.github.io/Agents.jl/stable)
///
/// Authors: Chance Snow <git@chancesnow.me>
/// Copyright: Copyright © 2024 Chance Snow
/// License: MIT License

/// An autonomous agent that behave given a set of rules.
class Agent {}

/// Represents a speific model, i.e. its agents and the space they share, by mapping unique IDs (integers) to agent
/// instances.
///
/// During simulation, the model evolves in discrete steps.
class World {}

/// A specific area in which `Agent`s occupy.
///
/// Provided examples include a `Grid`, and `Graph`.
class Space {}

class Grid is Space {}

class Graph is Space {}
