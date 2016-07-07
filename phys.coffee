window.Phys = {}

## Constants
Phys.G = 6.67e-11#N*m^2/kg^2

## Constructors
Phys.Celestial = (xCoord, yCoord) ->
  @UUID = Util.UUID()
  @xCoord = xCoord
  @yCoord = yCoord
  @velocity = new Util.Vector2(0, 0)
  @mass = 5.972e24 # kg
  @radius = 6.371e6 # m
  @distanceTo = (object) ->
    xDistance = @xCoord - object.xCoord
    yDistance = @yCoord - object.yCoord
    distance = Math.sqrt(xDistance ** 2 + yDistance ** 2)
    return distance
  @gravityVectorTo = (object) ->
    xDistance = @xCoord - object.xCoord
    yDistance = @yCoord - object.yCoord
    distance = @distanceTo(object)
    gravity = ((Phys.G * object.mass) / (distance ** 2))
    theta = Math.atan2(yDistance, xDistance)
    gravityVector = new Util.Vector2(Math.cos(theta) * gravity, Math.sin(theta) * gravity)
    return gravityVector
  return this

## Functions
Phys.totalGravityVector = (object, allObjects) ->
  otherObjects = allObjects.filter((obj) -> obj != object)
  gravities = otherObjects.map((otherObject) -> object.gravityVectorTo(otherObject))
  totalGravity = gravities.reduce(((totalVector, vector) -> totalVector.add(vector)), new Util.Vector2(0, 0))
  return totalGravity

Phys.checkCollisions = (object, allObjects) ->
  otherObjects = allObjects.filter((obj) -> obj != object)
  collisions = otherObjects.filter((otherObject) -> object.distanceTo(otherObject) <= object.radius + otherObject.radius)
  return collisions
