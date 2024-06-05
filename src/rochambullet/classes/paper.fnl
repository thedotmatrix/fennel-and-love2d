(local Enemy (require "src.rochambullet.classes.enemy"))
(local Paper (Enemy:extend))
(tset Paper :new (fn [! x y]
   (set !.type "paper")
   (Paper.super.new ! x y)
   !))
Paper
