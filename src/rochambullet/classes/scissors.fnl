(local Enemy (require "src.rochambullet.classes.enemy"))
(local Scissors (Enemy:extend))
(tset Scissors :new (fn [self range x y]
   (Scissors.super.new self range x y)
   (set self.type "scissors")
   self))
Scissors
