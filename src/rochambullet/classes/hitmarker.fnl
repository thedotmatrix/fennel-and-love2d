(local Enemy (require "src.rochambullet.classes.enemy"))
(local HitMarker (Enemy:extend))
(tset HitMarker :new (fn [! x y]
   (set !.type "hitmarker")
   (HitMarker.super.new ! x y)
   (set !.speed 0)
   (set !.anim (fn []))
   !))
HitMarker
