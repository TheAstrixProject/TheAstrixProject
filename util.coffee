window.Util = {}

## Constructors
Util.Vector2 = (x,y) ->
  this.X = x
  this.Y = y
  this.add = (v) ->
    return (new Util.Vector2(this.X + v.X, this.Y + v.Y))
  this.scalar = (s) ->
    return (new Util.Vector2(this.X * s, this.Y * s))
  return this

## Functions
Util.ticksToMilliseconds = (d) -> 1000 / d

Util.sizeCanvas = () ->
  canvas = $('#screen')[0]
  canvas.style.width ='100%'
  canvas.style.height='90%' # Why does 100% make the canvas bigger than the window?
  canvas.width  = canvas.offsetWidth
  canvas.height = canvas.offsetHeight
