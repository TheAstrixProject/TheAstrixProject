window.Phys = {}

## Constants
Phys.G = 6.67e-11#N*m^2/kg^2

## Constructors
Phys.Celestial = (x,y) ->
  @UUID = Util.UUID()
  @X = x
  @Y = y
  @V = new Util.Vector2(0,0)
  @M = 5.972e24 # kg
  @R = 6.371e6 # m
  @distanceTo = (p) ->
    x = @X - p.X
    y = @Y - p.Y
    r = Math.sqrt(x * x + y * y)
    return r
  @gVectorTo = (p) ->
    r = this.distanceTo(p)
    g = ((Phys.G * p.M) / (r * r))
    theta = Math.atan2(y,x)
    gVector = new Util.Vector2(Math.cos(theta) * g, Math.sin(theta) * g)
    return gVector
  return this

## Functions
Phys.totalGravityVector = (p,arr) ->
  ps = arr.filter((x) -> x != p)
  vs = ps.map((x) -> p.gVectorTo(x))
  tgv = vs.reduce(((a,v) -> a.add(v)), new Util.Vector2(0,0))
  return tgv

Phys.checkCollisions = (p,arr) ->
  ps = arr.filter((x) -> x != p)
  cs = ps.filter((x) -> x.distanceTo(p) <= x.R + p.R)
  us = cs.map((x) -> x.UUID) # Not sure if we should return objects or UUID's here...
  return us
