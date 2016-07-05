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
  return cs

Phys.collisionElastic = (p,arr) ->
  if arr.length == 0
    return(p.V)
  else
    for planet in arr
      #get p's angle and velocity (polar vector)
      pA = Math.atan2(p.Y,p.X)
      pV = Math.sqrt(p.X ** 2 + p.Y ** 2)
      #get planet's angle and velocity (polar vector)
      planetA = Math.atan2(planet.Y,planet.X)
      planetV = Math.sqrt(planet.X ** 2 + planet.Y ** 2)
      #get impact plane angle
      iPA = Math.atan2((p.Y - planet.Y),(p.X - planet.X)) + 90
      #get new vector's angle
      newA = (iPA - pA) + iPA
      console.log(newA)
      #get new vector's velocity
      newV = Math.abs((p.M - planet.M) / (p.M + planet.M) * pV + (2 * p.M) / (p.M + planet.M) * planetV)
      console.log(newV)
      #make new regular vector with new angle and velocity
      newVector = new Util.Vector2(Math.cos(newA) * newV , Math.sin(newA) * newV)
    return(newVector)
