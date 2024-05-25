(import-macros {: incf : lerp : clamp} :mac.math)
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
  (when (not self.alpha) (set self.alpha 0))
  (when (not self.start) (set self.start {:x self.x :y self.y}))
  (when (not self.end)
    (set self.end {
      :x (if  (> (math.cos self.angle) 0.1)
              (+ 0 (* self.speed board.tilepx))
              (if (< (math.cos self.angle) -0.1)
                  (- 0 (* self.speed board.tilepx))
                  0))
      :y (if  (> (math.sin self.angle) 0.1)
              (+ 0 (* self.speed board.tilepx))
              (if (< (math.sin self.angle) -0.1)
                  (- 0 (* self.speed board.tilepx))
                  0))}))
  (incf self.alpha dt)
  (clamp self.alpha 0 1)
  (set self.x (+ self.start.x (lerp 0 self.end.x self.alpha)))
  (set self.y (+ self.start.y (lerp 0 self.end.y self.alpha)))
  (board:fit self)
  (if (>= self.alpha 1.0) (do (self:reset board) nil) self.alpha)))
(tset Character :digital (fn [self board]
  (local df (fn [v] 
    (+ (* (math.floor (/ v board.tilepx)) board.tilepx) (/ board.tilepx 2))))
  (set self.x (df self.x))
  (set self.y (df self.y))))
(tset Character :reset (fn [self board]
  (self:digital board)
  (set self.alpha nil)
  (set self.start nil)
  (set self.end nil)))
(tset Character :collision? (fn [self x y size]
  (let [d (math.sqrt (+ (^ (- self.x x) 2) (^ (- self.y y) 2)))]
    (< d size))))
Character
