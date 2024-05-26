(local Enemy (require "src.rochambullet.classes.enemy"))
(local Rock (Enemy:extend))
(tset Rock :new (fn [self range x y]
   (set self.type "rock")
   (Rock.super.new self range x y)
   self))
Rock
