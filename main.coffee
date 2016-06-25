## Constants
framerate = 30#fps
scale = 900000#m/px
simspeed = 100000#x
G = 6.67e-11#N*m^2/kg^2

## Constructors
Vector2 = (x,y) ->
  this.X = x
  this.Y = y
  this.add = (v) ->
    return (new Vector2(this.X + v.X, this.Y + v.Y))
  this.scalar = (s) ->
    return (new Vector2(this.X * s, this.Y * s))
  return this

Planet = (x,y) ->
  this.X = x
  this.Y = y
  this.V = new Vector2(0,0)
  this.M = 5.972e24 # kg
  this.R = 6.371e6 # m
  this.gVectorTo = (p) ->
    x = this.X - p.X
    y = this.Y - p.Y
    r = Math.sqrt(x * x + y * y)
    g = ((G * p.M) / (r * r))
    theta = Math.atan2(y,x)
    gVector = new Vector2(Math.cos(theta) * g, Math.sin(theta) * g)
    return gVector
  return this

## Functions
fps = (d) -> 1000 / d

totalGravityVector = (p,arr) ->
  ps = arr.filter((x) -> x != p)
  vs = ps.map((x) -> p.gVectorTo(x))
  tgv = vs.reduce(((a,v) -> a.add(v)), new Vector2(0,0))
  return tgv

animate = (p,arr) ->
  p.V = p.V.add(totalGravityVector(p,arr))
  p.X -= (p.V.X / framerate) * simspeed # Why must this be negative?
  p.Y -= (p.V.Y / framerate) * simspeed

sizeCanvas = () ->
  canvas = $('#screen')[0]
  canvas.style.width ='100%'
  canvas.style.height='95%' # Why does 100% make the canvas bigger than the window?
  canvas.width  = canvas.offsetWidth
  canvas.height = canvas.offsetHeight

clear = () ->
  canvas = $('#screen')[0]
  ctx = canvas.getContext('2d')
  ctx.clearRect(0, 0, canvas.width, canvas.height);

draw = (p) ->
  canvas = $('#screen')[0]
  ctx = canvas.getContext('2d')
  ctx.drawImage($('#POL')[0], (p.X / scale) - (p.R / scale), (p.Y / scale) - (p.R / scale), (p.R / scale) * 2, (p.R / scale) * 2)

## Streams
resize = $(window).asEventStream('resize')
clicksRaw = $('#screen').asEventStream('click')
reset = $('#reset').asEventStream('click').map('reset')
combinedInput = clicksRaw.merge(reset)
tick = Bacon.interval(fps(framerate))

## Subscriptions
resize.onValue(sizeCanvas)

## Properties

# Testing Initialization Code
init = [new Planet(900 * scale,400 * scale),new Planet(900 * scale,(400 * scale) + 3.844e8)]
#init[0].V = new Vector2(-50 * scale,0)
init[1].M = 7.35e22
init[1].R = 1.75e6
init[1].V = new Vector2(1000,0)
# To be removed in the future

planets = combinedInput.scan(init, (a,e) ->
  if e == 'reset'
    return []
  else
    a.concat(new Planet(e.offsetX * scale, e.offsetY * scale)))

## Initialize
sizeCanvas()

## Game Loop
planets.sampledBy(tick).onValue((model) ->
  clear()
  for planet in model
    animate(planet,model)
    draw(planet)
  )
