(local Enemy (require "src.rochambullet.classes.enemy"))
(local HitMarker (Enemy:extend))
(tset HitMarker :new (fn [self x y]
   (set self.type "hitmarker")
   (HitMarker.super.new self x y)
   (set self.speed 0)
   (set self.anim (fn []))
   self))
HitMarker
