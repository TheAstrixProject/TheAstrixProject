window.Collisions = {}

Collisions.check = (p,arr) ->
  ps = arr.filter((x) -> x != p)
  cs = ps.filter((x) -> x.R + p.R >= Math.sqrt((x.X - p.X)^2 + (x.Y - p.Y)^2))
  return(cs)
