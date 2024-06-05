(import-macros {: incf : lerp : clamp} :mac.math)
(local Object (require "lib.classic"))
(local Character (Object:extend))
(local end (fn [! board speed] {
  :x (if  (> (math.cos !.angle) 0.1)
          (+ 0 (* speed board.tilepx))
          (if (< (math.cos !.angle) -0.1)
            (- 0 (* speed board.tilepx))
            0))
  :y (if  (> (math.sin !.angle) 0.1)
          (+ 0 (* speed board.tilepx))
          (if (< (math.sin !.angle) -0.1)
            (- 0 (* speed board.tilepx))
            0))}))
(local df (fn [v board] 
  (+  (* (math.floor (/ v board.tilepx)) board.tilepx) 
      (/ board.tilepx 2))))
(tset Character :new (fn [! x y speed angle scale image]
  (set !.x x)
  (set !.y y)
  (set !.speed speed)
  (set !.angle angle)
  (when image (set !.i (love.graphics.newImage image)))
  (set !.ox (/ (!.i:getWidth) 2))
  (set !.oy (/ (!.i:getHeight) 2))
  (set !.scale scale)
  (set !.size (* (math.max !.ox !.oy) !.scale))
  !))
(tset Character :anim (fn [! dt board]
  (when (not !.alpha) (set !.alpha 0))
  (when (not !.start) (set !.start {:x !.x :y !.y}))
  (when (not !.end) (set !.end (end ! board !.speed)))
  (incf !.alpha dt)
  (clamp !.alpha 0 1)
  (local alphasquared (* !.alpha !.alpha))
  (set !.x (+ !.start.x (lerp 0 !.end.x alphasquared)))
  (set !.y (+ !.start.y (lerp 0 !.end.y alphasquared)))
  (board:fit !)
  !.alpha))
(tset Character :digital (fn [! board]
  (set !.x (df !.x board))
  (set !.y (df !.y board))))
(tset Character :reset (fn [! board speed]
  (if (and speed !.alpha)
    (do
      (set !.end (end ! board speed))
      (set !.start.x (- !.x (lerp 0 !.end.x !.alpha)))
      (set !.start.y (- !.y (lerp 0 !.end.y !.alpha)))
      (set !.start.x (df !.start.x board))
      (set !.start.y (df !.start.y board)))
    (do 
      (!:digital board)
      (set !.alpha nil)
      (set !.start nil)
      (set !.end nil)))))
(tset Character :dist (fn [! x y]
  (math.sqrt (+ (^ (- !.x x) 2) (^ (- !.y y) 2)))))
(tset Character :check (fn [! x y size]
  (let [d (!:dist x y)]
    (< d size))))
Character
