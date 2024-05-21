(local Character (require "rochambullet.character"))
(local Enemy (Character:extend))
(tset Enemy :new (fn [self range]
  (let [ex (love.math.random (/ range -2) (/ range 2))
        ey (love.math.random (/ range -2) (/ range 2))
        ea (love.math.random 0 (* 2 math.pi))]
    (self.super.new self ex ey 128 ea))))
(tset Enemy :draw (fn [self w h]
  (love.graphics.circle "fill" self.x self.y 8)))
Enemy
