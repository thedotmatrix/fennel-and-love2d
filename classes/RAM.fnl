(local Object (require :lib.classic))
(local RAM (Object:extend))

(tset RAM :new (fn [self old]
  (when old
    (each [k v (pairs old)]
      (tset self k v)))
  self))

RAM
