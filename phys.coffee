window.Phys = {}

## Constants
Phys.G = 6.67e-11#N*m^2/kg^2 A Gravitational Constant or Newtons Constant also I'm honestly not explaining the entire thing in 1 line, Look up on google.

## Constructors
Phys.Celestial = (xCoord, yCoord, mass = 0, radius = 0) -> #The physics of a Celestial Object. This states its mass, velocity, and distances from other CelestialObjects
  @UUID = Util.UUID()
  @xCoord = xCoord
  @yCoord = yCoord
  @velocity = new Util.Vector2(0, 0)
  @mass = mass # kg
  @radius = radius # m
  @distanceTo = (object) -> # This checks and returns the distance (measure in pixels)
    xDistance = @xCoord - object.xCoord
    yDistance = @yCoord - object.yCoord
    distance = Math.sqrt(xDistance ** 2 + yDistance ** 2)
    return distance
  @gravityVectorTo = (object) -> # Using the new distance it creates a new Gravity Vector
    xDistance = @xCoord - object.xCoord
    yDistance = @yCoord - object.yCoord
    distance = @distanceTo(object)
    gravity = ((Phys.G * object.mass) / (distance ** 2))
    theta = Math.atan2(yDistance, xDistance)
    gravityVector = new Util.Vector2(Math.cos(theta) * gravity, Math.sin(theta) * gravity) #something that keith doesn't understand
    return gravityVector
  return this

## Functions
Phys.totalGravityVector = (object, allObjects) -> # This is the physics for a gravity vector
  otherObjects = allObjects.filter((obj) -> obj != object)
  gravities = otherObjects.map((otherObject) -> object.gravityVectorTo(otherObject))
  totalGravity = gravities.reduce(((totalVector, vector) -> totalVector.add(vector)), new Util.Vector2(0, 0))
  return totalGravity
# Collisions
Phys.checkCollisions = (object, allObjects) ->
  otherObjects = allObjects.filter((obj) -> obj != object)
  collisions = otherObjects.filter((otherObject) -> object.distanceTo(otherObject) <= object.radius + otherObject.radius)
  return collisions
