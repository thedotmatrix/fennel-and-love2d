(local Enemy (require "src.rochambullet.classes.enemy"))
(local Scissors (Enemy:extend))
(tset Scissors :new (fn [self x y]
   (set self.type "scissors")
   (Scissors.super.new self x y)
   self))
Scissors
