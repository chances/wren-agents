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

// TODO: Write a Jupyter kernel for Wren: https://jupyter-client.readthedocs.io/en/latest/kernels.html

import "random" for Random

/// An autonomous agent that behave given a set of rules.
class Agent {
  /// Aborts: When the world has exhaused its supply of agent IDs.
  construct create() {
    if (__lastId == Num.maxSafeInteger) Fiber.abort("Error: The world has exhaused its supply of agent IDs.")
    _id = (__lastId = __lastId == null ? 0 : __lastId + 1)
    _live = true
    _location = null
    _time = 0
  }

  /// Returns: Num
  id { _id }

  /// Whether this agent is living in its world.
  /// Returns: Bool
  live { _live }
  /// @protected
  /// Warning: Do *NOT* directly mutate an agent's liveness. It is managed for you by the `World` simulation.
  /// See: `Space.kill(agent)`
  live=(value) { _live = value }

  /// Position of this agent in its `World`.
  /// Returns: Pos
  location { _location }
  /// @protected
  /// Warning: Do *NOT* directly mutate an agent's position. It is managed for you by the `World` simulation.
  /// See: `Space.move(agent, pos)`
  location=(value) { _location = value }

  /// The current agent-local time. Akin to a stopwatch counting up from zero.
  /// Returns: Num
  time { _time }

  /// @virtual
  /// Returns: Num Current agent-local time.
  /// See: `time`
  tick() {
    _time = _time + 1
  }
}

/// @private
var random = Random.new()

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

    space.world = this
  }

  /// The current global time. Akin to a stopwatch counting up from zero.
  /// Returns: Num
  time { _time }

  /// Returns: Space
  space { _space }

  /// Map of unique IDs to `Agent`s.
  /// Warning: Do *NOT* mutate this map. Use `space.add(agent)`, `space.remove(agent)`, and `space.move(agent, pos)` to
  /// modify a world's agents.
  /// Returns: Agent[Num]
  agents { _agents }

  /// Returns: Agent A random agent from the model.
  randomAgent { _agents.values.count == 0 ? null : _agents[random.int(_agents.count)] }

  /// @virtual
  /// Returns: Num Current global time.
  /// See: `time`
  tick() {
    _agents.values.each {|agent| agent.tick() }
    _time = _time + 1
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
/// - `randomPosition` property
/// - `neighbors(agentOrPos)` and `neighbors(agentOrPos, radius)` functions
class Space {
  /// Returns: Bool Whether the given `value` is an instance of `Agent` or `Pos`.
  /// Aborts: When the given value is _not_ an instance of `Agent` or `Pos`.
  static isAgentOrPos(value) {
    if (!(value is Agent || value is Pos)) Fiber.abort("Error: Expected a value of type `Agent` or `Pos`.")
    return true
  }
  /// The world this space represents.
  /// Returns: World
  world { _world }
  /// Params: value: World
  world=(value) { _world = value }

  /// @abstract
  /// Returns: Pos
  randomPosition { Fiber.abort("Error: `Space.randomPosition` is abstract.") }

  /// @virtual
  /// Params: agentOrPos: Agent | Pos around which to find neighbors. If an `Agent` is given, it is excluded.
  /// Returns: Sequence<Agent>
  /// See: Prior art: Agents.jl [`nearby_ids`](https://juliadynamics.github.io/Agents.jl/stable/api/#Agents.nearby_ids)
  neighbors(agentOrPos) { Fiber.abort("Error: `Space.neighbors(agentOrPos)` is abstract.") }
  /// Params:
  ///   agentOrPos: Agent | Pos around which to find neighbors. If an `Agent` is given, it is excluded.
  ///   radius: Num Inclusive distance within which to search
  neighbors(agentOrPos, radius) { Fiber.abort("Error: `Space.neighbors(agentOrPos, radius)` is abstract.") }

  /// @final
  /// Add the given agent to this space.
  /// Params: agent: Agent
  /// Aborts: When this space does not belong to a `World`.
  add(agent) {
    this.add(agent, null)
  }
  /// Add the given agent to this space at the given `pos`ition.
  /// Params:
  ///   agent: Agent
  ///   location: null | Pos
  /// Aborts: When this space does not belong to a `World`.
  add(agent, location) {
    if (_world == null) Fiber.abort("Error: This space is not attached to a `World`.")
    world.agents[agent.id] = agent
    move(agent, location)
  }

  /// @final
  /// Remove the given agent from this space.
  /// Params: agent: Agent
  /// Aborts: When this space does not belong to a `World`.
  remove(agent) {
    if (_world == null) Fiber.abort("Error: This space is not attached to a `World`.")
    if (!world.agents.containsKey(agent.id)) Fiber.abort("Error: The given agent does not exist in this space's world.")
    world.agents.remove(agent.id)
  }

  /// @virtual
  /// Move the given `agent` to a new `location`.
  /// Params:
  ///   agent: Agent
  ///   location: null | Pos
  /// Aborts: When this space does not belong to a `World`.
  move(agent, location) {
    if (_world == null) Fiber.abort("Error: This space is not attached to a `World`.")
    agent.location = location
  }

  /// @final
  /// Params: agent: Agent
  /// Aborts: When this space does not belong to a `World`.
  kill(agent) {
    if (_world == null) Fiber.abort("Error: This space is not attached to a `World`.")
    if (!world.agents.containsKey(agent.id)) Fiber.abort("Error: The given agent does not exist in this space's world.")
    agent.live = false
  }
}

import "./wren_modules/wren-vector/vector" for Vector

/// 2D area of a given size. Positions are 2D vectors. Agents _may_ share locations.
class Grid is Space {
  /// Params:
  ///   width: Num
  ///   height: Num
  construct create(width, height) {
    _size = Vector.new(width, height)
  }

  /// Returns: Vector
  size { _size }
  /// Returns: Num
  width { _size.x }
  /// Returns: Num
  height { _size.y }

  /// Returns: Pos
  randomPosition { Pos.at(Vector.new(random.int(width), random.int(height))) }

  /// Params: agentOrPos: Agent | Pos around which to find neighbors. If an `Agent` is given, it is excluded.
  /// Returns: Sequence<Agent>
  neighbors(agentOrPos) { neighbors(agentOrPos, width.max(height)) }
  /// Params:
  ///   agentOrPos: Agent | Pos around which to find neighbors. If an `Agent` is given, it is excluded.
  ///   radius: Num Inclusive distance within which to search.
  neighbors(agentOrPos, radius) {
    Space.isAgentOrPos(agentOrPos)
    return world.agents.values.where {|n|
      if (agentOrPos is Agent && n.id == agentOrPos.id) return false
      var other = agentOrPos is Agent ? agentOrPos.location.pos : agentOrPos.pos
      var distance = (n.location.pos - other).magnitude
      return distance <= radius
    }
  }

  /// Move the given `agent` to a new `location`.
  /// Params:
  ///   agent: Agent
  ///   location: null | Pos When `null`, the agent is placed randomly in this space.
  /// Aborts: When this space does not belong to a `World`.
  move(agent, location) {
    super.move(agent, location == null ? randomPosition : location)
  }
}

/// A graph of agents. Agents _may_ share locations.
///
/// Nodes in the graph are collections of agents. Edges are connections to the node's neighbors.
/// Remarks: Represented internally as an [adjacency list](https://en.wikipedia.org/wiki/Adjacency_list) of agent IDs.
class Graph is Space {
  construct create() {
    /// Adjacency list of agent IDs.
    /// Type: (Num[])[Num]
    _nodes = {}
  }

  /// Returns: Pos randomly adjacent to another agent.
  randomPosition {
    if (_nodes.values.isEmpty) return null
    var id = null
    while (agent == null || world.agents.containsKey(id) == false) {
      id = random.int(lastId)
    }
    return Pos.at(id)
  }

  /// Params: agentOrPos: Agent | Pos around which to find neighbors. If an `Agent` is given, it is excluded.
  /// Returns: Sequence<Agent>
  neighbors(agentOrPos) { neighbors(agentOrPos, Num.maxSafeInteger) }
  /// Params:
  ///   agentOrPos: Agent | Pos around which to find neighbors. If an `Agent` is given, it is excluded.
  ///   radius: Num Inclusive distance within which to search.
  /// Aborts: When the given agent's position or position is not the correct type.
  neighbors(agentOrPos, radius) {
    Space.isAgentOrPos(agentOrPos)
    return world.agents.values.where {|n|
      if (agentOrPos is Agent && n.id == agentOrPos.id) return false
      var other = agentOrPos is Agent ? agentOrPos.location.pos : agentOrPos.pos
      if (other is Num == false) Fiber.abort("Error: The given agent's position or position is not the correct type.")
      /// Try to find agent `n` in root's neighbors in a breadth-first search.
      /// Short-circuit if the search radius is exceeded or a node is not in the graph
      var search = Fn.new {|root, distance|
        if (distance > radius || _nodes.containsKey(root) == false) return false
        if (_nodes[root].any {|needle| _nodes[root].contains(n.id) }) return true
        return _nodes[root].any {|node| search(node, distance + 1) }
      }
      return search.call(other, 0)
    }
  }

  /// Move the given `agent` to a new `location`.
  /// Params:
  ///   agent: Agent
  ///   location: null | Pos
  /// Aborts: When this space does not belong to a `World`.
  move(agent, location) {
    location = location == null ? Pos.at(agent.id) : location
    super.move(agent, location)

    // Disconnect the agent from its old neighbors
    var neighbors = _nodes.containsKey(agent.id) ? _nodes[agent.id] : []
    neighbors.each {|n| _nodes[n].remove(agent.id) }

    if (location.pos == agent.id) _nodes[agent.id] = []
    // Connect the agent to its new neighbor and vice-versa
    if (location.pos != agent.id) {
      _nodes[agent.id] = [location.pos]
      var oppositeLinkExists = _nodes.containsKey(location.pos)
      oppositeLinkExists ? _nodes[location.pos].add(agent.id) : _nodes[location.pos] = [agent.id]
    }
  }
}

/// @final
/// A position in a `World`'s space.
/// See: `Space`
class Pos {
  /// `List` of valid types to represent an agent's position in a `Space`.
  /// Returns: String[] `Class` names.
  static validTypes {[
    Num.name,
    Map.name,
    Vector.name
  ]}

  /// Params: pos: Num | Map | Vector
  /// Aborts: When the given `pos` is not of a valid type.
  /// See: `validTypes`
  construct at(pos) {
    var valid = pos is Num || pos is Map || pos is Vector
    if (!valid) Fiber.abort("Error: `%(pos)` is not a valid position type. See `Pos.validTypes`.")
    _pos = pos
  }

  /// Returns: Num | Map | Vector
  /// See: `Agent.location`
  pos { _pos }
}
