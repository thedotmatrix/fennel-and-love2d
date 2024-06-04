(local Object (require :lib.classic))
(local ROM (Object:extend))

(fn ROM.mix [self other !]
  (self:implement other)
  (when ! (self.load !))
  self)

(fn ROM.load [!])
(set ROM.load nil)

(fn ROM.update [!! ! dt])
(set ROM.update nil)

(fn ROM.any_love_event [!! ! ...])
(set ROM.any_love_event nil)

ROM
