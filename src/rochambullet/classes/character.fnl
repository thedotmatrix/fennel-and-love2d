(import-macros {: incf : lerp : clamp} :mac.math)
(local Object (require "lib.classic"))
(local Character (Object:extend))
(local end (fn [self board speed] {
  :x (if  (> (math.cos self.angle) 0.1)
          (+ 0 (* speed board.tilepx))
          (if (< (math.cos self.angle) -0.1)
            (- 0 (* speed board.tilepx))
            0))
  :y (if  (> (math.sin self.angle) 0.1)
          (+ 0 (* speed board.tilepx))
          (if (< (math.sin self.angle) -0.1)
            (- 0 (* speed board.tilepx))
            0))}))
(local df (fn [v board] 
  (+  (* (math.floor (/ v board.tilepx)) board.tilepx) 
      (/ board.tilepx 2))))
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
  (when (not self.end) (set self.end (end self board self.speed)))
  (incf self.alpha dt)
  (clamp self.alpha 0 1)
  (local alphasquared (* self.alpha self.alpha))
  (set self.x (+ self.start.x (lerp 0 self.end.x alphasquared)))
  (set self.y (+ self.start.y (lerp 0 self.end.y alphasquared)))
  (board:fit self)
  self.alpha))
(tset Character :digital (fn [self board]
  (set self.x (df self.x board))
  (set self.y (df self.y board))))
(tset Character :reset (fn [self board speed]
  (if (and speed self.alpha)
    (do
      (set self.end (end self board speed))
      (set self.start.x (- self.x (lerp 0 self.end.x self.alpha)))
      (set self.start.y (- self.y (lerp 0 self.end.y self.alpha)))
      (set self.start.x (df self.start.x board))
      (set self.start.y (df self.start.y board)))
    (do 
      (self:digital board)
      (set self.alpha nil)
      (set self.start nil)
      (set self.end nil)))))
(tset Character :check (fn [self x y size]
  (let [d (math.sqrt (+ (^ (- self.x x) 2) (^ (- self.y y) 2)))]
    (< d size))))
Character
