(import-macros {: incf} :macros.math)
(local Object (require "lib.classic"))
(local Character (Object:extend))
(tset Character :new (fn [self x y speed angle image scale]
  (set self.x x)
  (set self.y y)
  (set self.speed speed)
  (set self.angle angle)
  (set self.i (love.graphics.newImage image))
  (set self.ox (/ (self.i:getWidth) 2))
  (set self.oy (/ (self.i:getHeight) 2))
  (set self.scale scale)
  (set self.size (* (math.max self.ox self.oy) self.scale))
  self))
(tset Character :update (fn [self dt wraparound]
  (incf self.x (* (math.cos self.angle) self.speed dt))
  (incf self.y (* (math.sin self.angle) self.speed dt))
  (set self.x (- (% (+ self.x (/ wraparound 2)) wraparound) (/ wraparound 2)))
  (set self.y (- (% (+ self.y (/ wraparound 2)) wraparound) (/ wraparound 2)))))
(tset Character :collision? (fn [self x y size]
  (let [d (math.sqrt (+ (^ (- self.x x) 2) (^ (- self.y y) 2)))]
    (< d size))))
Character
