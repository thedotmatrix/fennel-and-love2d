(local Enemy (require "src.rochambullet.classes.enemy"))
(local Rock (Enemy:extend))
(tset Rock :new (fn [! x y]
   (set !.type "rock")
   (Rock.super.new ! x y)
   !))
Rock
