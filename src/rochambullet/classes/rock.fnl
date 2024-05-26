(local Enemy (require "src.rochambullet.classes.enemy"))
(local Rock (Enemy:extend))
(tset Rock :new (fn [self x y]
   (set self.type "rock")
   (Rock.super.new self x y)
   self))
Rock
