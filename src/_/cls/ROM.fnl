(local Object (require :lib.classic))
(local ROM (Object:extend))

(fn ROM.mix [a b]
  (a:implement b)
  a)

(fn ROM.update [!! ! dt])
(set ROM.update nil)

(fn ROM.any_love_event [!! ! ...])
(set ROM.any_love_event nil)

ROM
