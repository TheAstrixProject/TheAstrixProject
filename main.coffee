## Constants
fps = 60#fps
paused = false#bool
simSpeed = 50000#x
scale = 1350000#m/px

## Functions
update = (p,arr) ->
  A = Phys.totalGravityVector(p,arr).scalar(1/fps).scalar(simSpeed)
  p.V = p.V.add(A)
  p.X -= (p.V.X / fps) * simSpeed # Why must this be negative?
  p.Y -= (p.V.Y / fps) * simSpeed

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
reset = $('#reset').asEventStream('click').map('r')
pause = $('#pause').asEventStream('click')
slower = $('#slower').asEventStream('click').map(1/2)
faster = $('#faster').asEventStream('click').map(2)
speedInput = slower.merge(faster)
input = new Bacon.Bus()
input.plug(clicksRaw.merge(reset))

## Subscriptions
resize.onValue(Util.sizeCanvas)

## Testing Initialization Code
initState = () ->
  s = [new Phys.Celestial(600 * scale,275 * scale),new Phys.Celestial(600 * scale,(275 * scale) + 3.844e8)]
  s[0].V = new Util.Vector2(-12.325,0)
  s[1].M = 7.35e22
  s[1].R = 1.75e6
  s[1].V = new Util.Vector2(1000,0)
  return s
# To be removed in the future

## Properties
objs = input.scan(initState(), (a,e) ->
  if typeof e is 'string'
    if e.slice(0,2) is 'd '
      return a.filter((x) -> x.UUID != e.slice(2))
    if e is 'r'
      return initState()
  else
    return a.concat(new Phys.Celestial(e.offsetX * scale, e.offsetY * scale)))

isPaused = pause.map(1).scan(1, (a,v) -> a + v).map((x) -> x % 2 == 0)
isPaused.onValue((newPaused) -> paused = newPaused)
isPaused.map((x) -> if x then "Play" else "Pause").assign($('#pause'), 'text')

speed = speedInput.scan(simSpeed, (a,e) -> Math.round(a * e))
speed.onValue((newSpeed) -> simSpeed = newSpeed)
speed.assign($('#speed'), 'text')

## Initialize
Util.sizeCanvas()

## Game Loop
objs.sample(Util.ticksToMilliseconds(fps)).onValue((model) ->
  clear()

  for planet in model
    if not paused then update(planet,model)

  for planet in model
    if Phys.checkCollisions(planet,model).length > 0 then input.push('d ' + planet.UUID)

  for planet in model
    draw(planet)
  )
