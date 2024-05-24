(local Enemy (require "src.rochambullet.classes.enemy"))
(local Scissors (Enemy:extend))
(tset Scissors :draw (fn [self ox oy]
   (love.graphics.setColor 1 0 0 1)
   (Scissors.super.draw self ox oy)))
Scissors
