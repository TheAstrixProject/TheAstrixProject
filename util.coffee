# This line exposes the 'Util' namespace to the rest of the program.
window.Util = {}

## Constructors
# This constructor creates a 2D vector object.
# It stores an X magnitude and a Y magnitude.
Util.Vector2 = (x, y) ->
  @X = x
  @Y = y
  # The 'Vector2.add()' function adds two vectors and returns a new vector.
  @add = (vector) ->
    return (new Util.Vector2(@X + vector.X, @Y + vector.Y))
  # The 'Vector2.multiply()' function multiplies a vector by a scalar and returns a new vector.
  @multiply = (scalar) ->
    return (new Util.Vector2(@X * scalar, @Y * scalar))
  return this

## Functions
# This funtion converts values expressed in ticks-per-second to milliseconds-per-tick.
# FPS is an example of a ticks-per-second value. This function translates the
# desired FPS to the millisecond interval between each frame.
Util.ticksToMilliseconds = (d) -> 1000 / d

# This function uses both bitwise operators ('^' and '>>') in conjunction with regular
# expressions and recursion to generate a random version 4 compliant UUID.
# An example of a version 4 UUID: ed37945a-fb2b-4657-aba8-a172e5573045
Util.UUID = (a) -> if a then (a ^ Math.random() * 16 >> a / 4).toString(16) else ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, Util.UUID)

# This function uses JQuery to manipulate the DOM and correctly scale the
# external and internal bounds of the HTML5 canvas element.
Util.sizeCanvas = () ->
  canvas = $('#screen')[0] # JQuery call used to fetch the canvas element.
  canvas.style.width ='100%'
  canvas.style.height ='90%'
  canvas.width  = canvas.offsetWidth
  canvas.height = canvas.offsetHeight
  return new Util.Vector2(canvas.width, canvas.height)

# This function clears the canvas and preps it for a redraw.
Util.clear = () ->
  canvas = $('#screen')[0] # Get the canvas.
  canvasContext = canvas.getContext('2d') # Get the drawing context.
  canvasContext.clearRect(0, 0, canvas.width, canvas.height); # Clear the canvas.
