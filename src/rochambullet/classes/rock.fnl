(local Enemy (require "src.rochambullet.classes.enemy"))
(local Rock (Enemy:extend))
(tset Rock :new (fn [self range x y]
   (Rock.super.new self range x y)
   (set self.type "rock")
   self))
(tset Rock :draw (fn [self ox oy]
   (love.graphics.setColor 1 0 0)
   (Rock.super.draw self ox oy)))
Rock
