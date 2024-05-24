(import-macros {: arctan} :mac.math)
(local Character (require "src.rochambullet.classes.character"))
(local Player (Character:extend))
(tset Player :new (fn [self x y]
  (Player.super.new self x y 1 (/ math.pi -2) 
                    "src/rochambullet/assets/player.png" (/ 1 3))
  (set self.aim (/ math.pi -2))
  (set self.threat -1)
  self))
(tset Player :aiming (fn [self mx my]
  (set self.aim (arctan mx my self.x self.y))
  (local digital (* (math.floor (/  (+ self.aim (/ math.pi 8)) 
                                    (/ math.pi 4))) 
                    (/ math.pi 4)))
  (set self.daim digital)))
(tset Player :draw (fn [pc]
  (match pc.threat 
    -1 (love.graphics.setColor 0.25 0.25 1 1)
    0 (love.graphics.setColor 1 1 0 1)
    1 (love.graphics.setColor 1 0 0 1))
  (love.graphics.draw pc.i pc.x pc.y pc.daim pc.scale pc.scale pc.ox pc.oy)
  (love.graphics.setColor 1 1 1 1)
  (let [stdarc  (* pc.size 2)
        arca    (- pc.aim (/ math.pi 4))
        arcb    (+ pc.aim (/ math.pi 4))]
    (love.graphics.arc "line" "open" pc.x pc.y stdarc arca arcb))
  (love.graphics.setColor 1 1 1 1)))
Player
