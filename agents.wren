/// Agent-based modeling (ABM) framework for Wren applications.
///
/// An agent-based (or individual-based) model is a computational simulation of autonomous agents that react to their environment (including other agents) given a predefined set of rules <sup>[[1](http://doi.org/10.1016/j.ecolmodel.2006.04.023)]</sup>.
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
class Agent {
  construct create() {
    _time = 0
    _location = null
  }

  /// The current agent-local time. Akin to a stopwatch counting up from zero.
  /// Returns: Num
  time { _time }

  /// @virtual
  /// Returns: void
  tick() {}
}

/// Represents a speific model, i.e. its agents and the space they share, by mapping unique IDs (integers) to agent
/// instances.
///
/// During simulation, the model evolves in discrete steps.
class World {
  /// Params: space: Space
  construct create(space) {
    _time = 0
    _space = space
    _agents = {}
  }

  /// The current global time. Akin to a stopwatch counting up from zero.
  /// Returns: Num
  time { _time }

  /// Returns: Space
  space { _space }

  /// Map of unique IDs to `Agent`s.
  /// Warning: Do *NOT* mutate this map. Use `space.add(agent)`, `space.remove(agent)`, and `space.move(agent)` to
  /// modify a world's agents.
  /// Returns: Agent[Num]
  agents { _agents }

  /// @virtual
  /// Returns: void
  step() {
    _time = _time + 1
    // TODO: tick all of this world's agents
  }
}

/// A specific area in which `Agent`s occupy. Base class of any `World`-space implementation.
///
/// Provided examples include a `Grid`, and `Graph`.
///
/// When creating custom spaces consider:
/// 1. Type of an agent's position.
/// 2. How agents near each other are represented, such that you can override the `neighbors` property.
/// 3. Potential random values in the space, such that you can override `randomPosition`.
///
/// Then, define a new class and override these members:
/// - `neighbors` property
/// - `randomPosition` function
/// - `add(agent)` function
/// - `remove(agent)` function
class Space {
  /// @virtual
  /// Returns: Agent[]
  neighbors { [] }

  /// @abstract
  randomPosition() { null }

  /// @abstract
  /// Params: agent: Agent
  add(agent) {}

  /// @abstract
  /// Params: agent: Agent
  remove(agent) {}

  /// @final
  /// Params: agent: Agent
  move(agent) {}
}

class Grid is Space {}

class Graph is Space {}
