(import-macros {: incf} :macros.math)
(local Object (require "lib.classic"))
(local Character (Object:extend))
(tset Character :new (fn [self x y speed angle]
  (set self.x x)
  (set self.y y)
  (set self.speed speed)
  (set self.angle angle)
  self))
(tset Character :update (fn [self dt wraparound]
  (incf self.x (* (math.cos self.angle) self.speed dt))
  (incf self.y (* (math.sin self.angle) self.speed dt))
  (set self.x (- (% (+ self.x (/ wraparound 2)) wraparound) (/ wraparound 2)))
  (set self.y (- (% (+ self.y (/ wraparound 2)) wraparound) (/ wraparound 2)))))
Character
