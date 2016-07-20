## Constants
fps = 60#fps
isPaused = false#bool
simSpeed = 50000#x
scale = 1350000#m/px
mousePos = new Phys.Celestial(0,0)
viewPort = new Util.Vector2(0,0)#Tuple
lastView = new Util.Vector2(0,0)#Tuple
lastClick = new Util.Vector2(0,0)#Tuple

## Functions

# This function updates the movement of an object.
updateObject = (object, allObjects) ->
  # Get acceleration of gravity on an object, scaled by the fps and speed of the simulation.
  acceleration = Phys.totalGravityVector(object, allObjects).multiply(1 / fps).multiply(simSpeed)
  # Add acceleration of gravity to the velocity vector.
  object.velocity = object.velocity.add(acceleration)
  # Update xCoord and yCoord using 'velocity' and scale by the fps and speed of the simulation.
  object.xCoord -= (object.velocity.X / fps) * simSpeed # Figure this '-=' shit out later...
  object.yCoord -= (object.velocity.Y / fps) * simSpeed

# Draws a graphical representation of each object.
drawObject = (object) ->
  # Gets the context of the screen.
  canvasContext = $('#screen')[0].getContext('2d')
  # Draws a "POL" for each object.
  canvasContext.drawImage($('#POL')[0]
    , (object.xCoord / scale) - (object.radius / scale) + viewPort.X
    , (object.yCoord / scale) - (object.radius / scale) + viewPort.Y
    , (object.radius / scale) * 2
    , (object.radius / scale) * 2)

## Streams

# Stream of window resize events.
resizeS = $(window).asEventStream('resize')
# Stream of mouse events on the screen.
clickS = $('#screen').asEventStream('mousedown mouseup mousemove mousewheel')
# Stream of 'reset' strings created when the 'reset' button is clicked.
resetS = $('#reset').asEventStream('click').map('reset')
# Stream of click events created when the 'pause' button is clicked.
pauseS = $('#pause').asEventStream('click')
# Stream of '1/2' created when the 'slower' button is clicked.
slowS = $('#slower').asEventStream('click').map(1/2)
# Stream of '2' created when the 'faster' button is clicked.
fastS = $('#faster').asEventStream('click').map(2)
# Combines 'slowS' and 'fastS' into one stream of faster and slower click events.
speedS = slowS.merge(fastS)
# Creates a Bacon Bus that allows events to be manually pushed to it.
inputS = new Bacon.Bus()
# Combines 'clickS' and 'resetS' streams into a single input stream and feeds them to 'inputS'.
inputS.plug(clickS.merge(resetS))

## Subscriptions

# Calls 'sizeCanvas()' function when resize stream has a new value.
resizeS.onValue(Util.sizeCanvas)

## Testing Initialization Code.
initState = () ->
  s = [ new Phys.Celestial(0, -100 * scale, 5.972e24, 6.371e6), new Phys.Celestial(100 * scale, 0, 5.972e24, 6.371e6)
      , new Phys.Celestial(-100 * scale, 0, 5.972e24, 6.371e6), new Phys.Celestial(0, 100 * scale, 5.972e24, 6.371e6) ]
  #s = [new Phys.Celestial(0, 0, 5.972e24, 6.371e6), new Phys.Celestial(0, 3.844e8, 7.35e22, 1.75e6)]
  #s[0].velocity = new Util.Vector2(-12.325, 0)
  #s[1].velocity = new Util.Vector2(1000, 0)
  return s
# To be removed in the future.

## Properties

# Defines a property as the result of a folded input stream.
modelP = inputS.scan(initState(), (model, event) ->
  # If 'event', which comes from the input stream, is a string variable...
  if typeof event is 'string'
    # And if the first 7 characters of that string are 'delete' plus SPACE...
    if event.slice(0, 7) is 'delete '
      # Return the model without the object whose UUID is equal to the remaining characters after 'delete' and SPACE.
      return model.filter((x) -> x.UUID != event.slice(7))
    if event.slice(0, 8) is 'collide '
      collidingObjects = model.filter((x) -> event.slice(8).split(' ').indexOf(x.UUID) > -1)
      if collidingObjects.length != event.slice(8).split(' ').length
        return model
      newModel = model.filter((x) -> collidingObjects.map((x) -> x.UUID).indexOf(x.UUID) < 0)
      newModel.push(Phys.handleCollision(collidingObjects))
      return newModel
    # If the string is 'reset'...
    if event is 'reset'
      # Return the initial state.
      return initState()
  if event.type is 'mousedown'
    if event.which == 1
      # Return an updated model that is the same plus a new object with the mouse's X and Y coords.
      return model.concat(new Phys.Celestial((event.offsetX - viewPort.X) * scale, (event.offsetY - viewPort.Y) * scale, 5.972e24, 6.371e6))
    if event.which == 2
      # Comment this section
      lastView = viewPort
      lastClick = new Util.Vector2(event.offsetX, event.offsetY)
      return model
    else
      return model
  if event.type is 'mouseup' or event.type is 'mousemove'
    if event.which == 2
      # Comment this section
      shift = new Util.Vector2(event.offsetX - lastClick.X, event.offsetY - lastClick.Y)
      viewPort = lastView.add(shift)
      return model
    else
      mousePos.xCoord = (event.offsetX - viewPort.X) * scale
      mousePos.yCoord = (event.offsetY - viewPort.Y) * scale
      # Ignore input and return the same model.
      return model
  if event.type is 'mousewheel'
    if event.originalEvent.wheelDelta > 0
      scale = Math.round(scale * 0.9)
    else
      scale = Math.round(scale * 1.1)
    return model
)

# Changes 'isPaused' value when pause stream has new value.
pauseP = pauseS.map(1).scan(1, (accumulator, value) -> accumulator + value).map((value) -> value % 2 == 0)
pauseP.onValue((newPause) -> isPaused = newPause)
pauseP.map((pause) -> if pause then 'Play' else 'Pause').assign($('#pause'), 'text')

# Changes the 'simSpeed' value when a faster or slower event occurs.
speedP = speedS.scan(simSpeed, (accumulator, factor) -> Math.round(accumulator * factor))
speedP.onValue((newSpeed) -> simSpeed = newSpeed)
speedP.assign($('#speed'), 'text')

## Initialize
screenSize = Util.sizeCanvas()
viewPort = screenSize.multiply(1/2)

## Game Loop
modelP.sample(Util.ticksToMilliseconds(fps)).onValue((model) ->
  # Clears the screen.
  Util.clear()

  # For every object...
  for object in model
    # Update if the simulation is not paused.
    if not isPaused then updateObject(object, model)

  # For every object...
  for object in model
    collisions = Phys.checkCollisions(object,model)
    if collisions.length > 0 then inputS.push(Util.formatCollisions(collisions.concat(object)))

  for object in Phys.checkCollisions(mousePos,model)
    objectInfo = 'UUID: ' + object.UUID + '\tVelocity: (' + Math.round(object.velocity.X) + ', ' + Math.round(object.velocity.Y) + ')'
    $('#objectInfo').text(objectInfo)

  # For every object...
  for object in model
    # Draw the object.
    drawObject(object)
  )
