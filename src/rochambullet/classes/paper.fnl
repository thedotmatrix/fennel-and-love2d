(local Enemy (require "src.rochambullet.classes.enemy"))
(local Paper (Enemy:extend))
(tset Paper :new (fn [self range x y]
   (Paper.super.new self range x y)
   (set self.type "paper")
   self))
Paper
