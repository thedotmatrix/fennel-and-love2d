(local Enemy (require "src.rochambullet.classes.enemy"))
(local Paper (Enemy:extend))
(tset Paper :new (fn [self range]
   (Paper.super.new self range)
   (set self.type "paper")
   self))
(tset Paper :draw (fn [self ox oy]
   (love.graphics.setColor 0 0 1)
   (Paper.super.draw self ox oy)))
Paper
