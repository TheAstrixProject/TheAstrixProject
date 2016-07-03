window.Util = {}

## Constructors
Util.Vector2 = (x,y) ->
  @X = x
  @Y = y
  this.add = (v) ->
    return (new Util.Vector2(@X + v.X, @Y + v.Y))
  this.scalar = (s) ->
    return (new Util.Vector2(@X * s, @Y * s))
  return this

## Functions
Util.ticksToMilliseconds = (d) -> 1000 / d

Util.UUID = (a) -> if a then (a ^ Math.random() * 16 >> a / 4).toString(16) else ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g,Util.UUID)

Util.sizeCanvas = () ->
  canvas = $('#screen')[0]
  canvas.style.width ='100%'
  canvas.style.height='90%' # Why does 100% make the canvas bigger than the window?
  canvas.width  = canvas.offsetWidth
  canvas.height = canvas.offsetHeight
