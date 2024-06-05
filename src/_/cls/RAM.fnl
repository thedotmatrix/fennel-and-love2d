(local Object (require :lib.classic))
(local RAM (Object:extend))

(fn RAM.new [! old]
  (when old
    (each [k v (pairs old)]
      (tset ! k v))))

RAM
