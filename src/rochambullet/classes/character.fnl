(import-macros {: decf : incf} :mac.math)
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
(tset Character :anim (fn [self dt board]
  (when (> (math.cos self.angle) 0.1) (incf self.x (* self.speed board.tilepx dt)))
  (when (< (math.cos self.angle) -0.1) (decf self.x (* self.speed board.tilepx dt)))
  (when (> (math.sin self.angle) 0.1) (incf self.y (* self.speed board.tilepx dt)))
  (when (< (math.sin self.angle) -0.1) (decf self.y (* self.speed board.tilepx dt)))
  (set self.x (- (% (+ self.x (/ board.px 2)) board.px) (/ self.speed board.px 2)))
  (set self.y (- (% (+ self.y (/ board.px 2)) board.px) (/ self.speed board.px 2)))))
(tset Character :tick (fn [self board]
  (self:digital board)))
(tset Character :digital (fn [self board]
  (local df (fn [v] 
    (+ (* (math.floor (/ v board.tilepx)) board.tilepx) (/ board.tilepx 2))))
  (set self.x (df self.x))
  (set self.y (df self.y))
  (when self.daim (set self.angle self.daim))
  (set self.speed 1)))
(tset Character :collision? (fn [self x y size]
  (let [d (math.sqrt (+ (^ (- self.x x) 2) (^ (- self.y y) 2)))]
    (< d size))))
Character
