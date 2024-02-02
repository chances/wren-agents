import "./agents" for Agent, World, Space, Graph
var world = World.create(Graph.create())
var ant = Agent.create()
Space.isAgentOrPos(ant)
world.space.add(ant)
world.space.add(Agent.create(), ant.location)
