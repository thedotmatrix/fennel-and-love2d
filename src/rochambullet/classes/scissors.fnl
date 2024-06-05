(local Enemy (require "src.rochambullet.classes.enemy"))
(local Scissors (Enemy:extend))
(tset Scissors :new (fn [! x y]
   (set !.type "scissors")
   (Scissors.super.new ! x y)
   !))
Scissors
