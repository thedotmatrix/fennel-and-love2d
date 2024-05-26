(local Enemy (require "src.rochambullet.classes.enemy"))
(local Paper (Enemy:extend))
(tset Paper :new (fn [self x y]
   (set self.type "paper")
   (Paper.super.new self x y)
   self))
Paper
