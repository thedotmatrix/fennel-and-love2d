(local Object (require :lib.classic))
(local RST (Object:extend))

(fn RST.mix [self other !]
  (self:implement other)
  self)

(fn RST.draw [! canvas])
(set RST.draw nil)

RST
