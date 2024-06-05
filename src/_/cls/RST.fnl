(local Object (require :lib.classic))
(local RST (Object:extend))

(fn RST.mix [a b]
  (a:implement b)
  a)

(fn RST.draw [! canvas])
(set RST.draw nil)

RST
