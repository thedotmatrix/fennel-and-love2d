(import-macros {: incf : decf : clamp} :macros.math)
(local lume (require "lib.lume"))
(local Object (require "lib.classic"))
(local Character (Object:extend))
(tset Character :new (fn [self x y]
  (set self.x x)
  (set self.y y)
  (set self.speed 100)
  (set self.angle 0)))
(local Player (Character:extend))
(tset Player :new (fn [self x y]
  (Player.super:new x y)
  (set self.i (love.graphics.newImage "bin/howtolove/arrow_right.png"))
  (set self.ox (/ (self.i:getWidth) 2))
  (set self.oy (/ (self.i:getHeight) 2))
  (set self.keys {})
  (set self.dir [])
  (set self.aim 0)
  (set self.attack 0)
  (set self.duration (/ 1 8))))
(tset Player :moving (fn [self]
  (set self.dir [])
  (when (and self.keys.down (not self.keys.up)) (table.insert self.dir :s))
  (when (and self.keys.up (not self.keys.down)) (table.insert self.dir :n))
  (when (and self.keys.left (not self.keys.right)) (table.insert self.dir :w))
  (when (and self.keys.right (not self.keys.left)) (table.insert self.dir :e))
  (match self.dir
    [:s :w]  (set self.angle (* math.pi 0.75))
    [:n :w]  (set self.angle (* math.pi 1.25))
    [:s :e]  (set self.angle (* math.pi 0.25))
    [:n :e]  (set self.angle (* math.pi 1.75))
    [:w]     (set self.angle (* math.pi 1.00))
    [:e]     (set self.angle (* math.pi 0.00))
    [:s]     (set self.angle (* math.pi 0.50))
    [:n]     (set self.angle (* math.pi 1.50))
    )))
(var pc nil)

(fn load [w h] 
  (set pc (Player (/ w 2) (/ h 2))))

(fn draw [w h] (fn []
  (love.graphics.clear 0.2 0.1 0.3 1)
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.draw pc.i pc.x pc.y pc.angle 1 1 pc.ox pc.oy)
  (love.graphics.setColor 1 0.25 0.5 1)
  (let [stdarc  (math.max pc.ox pc.oy)
        attack  (* (math.sin (/ (* pc.attack math.pi) pc.duration)) 25)
        arca    (- pc.aim (/ math.pi 4))
        arcb    (+ pc.aim (/ math.pi 4))]
    (if (> pc.attack 0)
      (love.graphics.arc "fill" "open" pc.x pc.y (+ stdarc attack) arca arcb)
      (love.graphics.arc "line" "open" pc.x pc.y stdarc arca arcb)))
  (love.graphics.setColor 0.9 0.7 0.8 1)
  (love.graphics.printf "rochambullet" 0 0 w :center)))

(fn update [dt w h]
  (when (> (length pc.dir) 0)
    (incf pc.x (* (math.cos pc.angle) pc.speed dt))
    (incf pc.y (* (math.sin pc.angle) pc.speed dt)))
  (when (> pc.attack 0) (decf pc.attack dt)))

(fn keypressed [key scancode repeat?]
  (match key
    :left  (tset pc.keys key true)
    :right (tset pc.keys key true)
    :up    (tset pc.keys key true)
    :down  (tset pc.keys key true))
  (pc:moving))

(fn keyreleased [key scancode]
  (match key
    :left  (tset pc.keys key false)
    :right (tset pc.keys key false)
    :up    (tset pc.keys key false)
    :down  (tset pc.keys key false))
  (pc:moving))

(fn mousemoved [x y dx dy istouch]
  (set pc.aim (math.atan2 (- y pc.y) (- x pc.x))))

(fn mousepressed [x y button istouch presses]
  (set pc.attack pc.duration))

{: load : draw : update : keypressed : keyreleased : mousemoved : mousepressed}
