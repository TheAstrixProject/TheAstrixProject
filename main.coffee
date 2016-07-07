## Constants
fps = 60#fps
isPaused = false#bool
simSpeed = 50000#x
scale = 1350000#m/px

## Functions
updateObject = (object, allObjects) ->
  acceleration = Phys.totalGravityVector(object, allObjects).multiply(1 / fps).multiply(simSpeed)
  object.velocity = object.velocity.add(acceleration)
  object.xCoord -= (object.velocity.X / fps) * simSpeed # Figure this '-=' shit out later
  object.yCoord -= (object.velocity.Y / fps) * simSpeed

drawObject = (object) ->
  canvasContext = $('#screen')[0].getContext('2d')
  canvasContext.drawImage($('#POL')[0]
    , (object.xCoord / scale) - (object.radius / scale)
    , (object.yCoord / scale) - (object.radius / scale)
    , (object.radius / scale) * 2
    , (object.radius / scale) * 2)

## Streams
resizeS = $(window).asEventStream('resize')
clickS = $('#screen').asEventStream('click')
resetS = $('#reset').asEventStream('click').map('reset')
pauseS = $('#pause').asEventStream('click')
slowS = $('#slower').asEventStream('click').map(1/2)
fastS = $('#faster').asEventStream('click').map(2)
speedS = slowS.merge(fastS)
inputS = new Bacon.Bus()
inputS.plug(clickS.merge(resetS))

## Subscriptions
resizeS.onValue(Util.sizeCanvas)

## Testing Initialization Code
initState = () ->
  s = [new Phys.Celestial(600 * scale, 275 * scale), new Phys.Celestial(600 * scale, (275 * scale) + 3.844e8)]
  s[0].velocity = new Util.Vector2(-12.325, 0)
  s[1].mass = 7.35e22
  s[1].radius = 1.75e6
  s[1].velocity = new Util.Vector2(1000, 0)
  return s
# To be removed in the future

## Properties
modelP = inputS.scan(initState(), (model, event) ->
  if typeof event is 'string'
    if event.slice(0, 7) is 'delete '
      return model.filter((x) -> x.UUID != event.slice(7))
    if event is 'reset'
      return initState()
  else
    return model.concat(new Phys.Celestial(event.offsetX * scale, event.offsetY * scale)))

pauseP = pauseS.map(1).scan(1, (accumulator, value) -> accumulator + value).map((value) -> value % 2 == 0)
pauseP.onValue((newPause) -> isPaused = newPause)
pauseP.map((pause) -> if pause then 'Play' else 'Pause').assign($('#pause'), 'text')

speedP = speedS.scan(simSpeed, (accumulator, factor) -> Math.round(accumulator * factor))
speedP.onValue((newSpeed) -> simSpeed = newSpeed)
speedP.assign($('#speed'), 'text')

## Initialize
Util.sizeCanvas()

## Game Loop
modelP.sample(Util.ticksToMilliseconds(fps)).onValue((model) ->
  Util.clear()

  for object in model
    if not isPaused then updateObject(object, model)

  for object in model
    if Phys.checkCollisions(object, model).length > 0 then inputS.push('delete ' + object.UUID)

  for object in model
    drawObject(object)
  )
