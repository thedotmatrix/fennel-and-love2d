(import-macros {: arctan} :mac.math)
(local Character (require "src.rochambullet.classes.character"))
(local Player (Character:extend))
(tset Player :new (fn [self x y]
  (self.super.new self x y 128 0 "src/rochambullet/assets/player.png" 0.125)
  (set self.keys {})
  (set self.dir [])
  (set self.threat -1)
  (set self.attack 0)
  (set self.duration (/ 1 8))
  self))
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
(tset Player :aiming (fn [self mx my]
  (set self.aim (arctan mx my self.x self.y))))
(tset Player :attacking (fn [self]
  (set self.attack self.duration)))
(tset Player :draw (fn [pc]
  (match pc.threat 
    -1 (love.graphics.setColor 0.25 0.25 1 1)
    0 (love.graphics.setColor 1 1 0 1)
    1 (love.graphics.setColor 1 0 0 1))
  (love.graphics.draw pc.i pc.x pc.y pc.angle pc.scale pc.scale pc.ox pc.oy)
  (love.graphics.setColor 1 1 1 1)
  (let [stdarc  (* pc.size 2)
        attack  (* (math.sin (/ (* pc.attack math.pi) pc.duration)) 25)
        arca    (- pc.aim (/ math.pi 4))
        arcb    (+ pc.aim (/ math.pi 4))]
    (if (> pc.attack 0)
      (love.graphics.arc "fill" "open" pc.x pc.y (+ stdarc attack) arca arcb)
      (love.graphics.arc "line" "open" pc.x pc.y stdarc arca arcb)))
  (love.graphics.setColor 1 1 1 1)))
Player
