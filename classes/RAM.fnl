(local Object (require :lib.classic))
(local RAM (Object:extend))

(fn RAM.new [self old]
  (when old
    (each [k v (pairs old)]
      (tset self k v)))
  self)

RAM
