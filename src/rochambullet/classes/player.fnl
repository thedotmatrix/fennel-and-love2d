(import-macros {: coin : arctan : digital} :mac.math)
(local Character (require "src.rochambullet.classes.character"))
(local Enemy (require "src.rochambullet.classes.enemy"))
(local Player (Character:extend))
(tset Player :choose (fn [self t]
  (set self.type t)
  (set self.file (.. "src/rochambullet/assets/hand_" self.type ".png"))
  (set self.i (love.graphics.newImage self.file))))
(tset Player :new (fn [self x y]
  (self:choose (coin "rock" (coin "paper" "scissors")))
  (Player.super.new self x y 1 (/ math.pi -2) 0.4 self.file)
  (self:aiming x (- y 1))
  (set self.threat -1)
  self))
(tset Player :aiming (fn [self mx my]
  (set self.aim (arctan mx my self.x self.y))
  (set self.daim (digital self.aim))
  (set self.angle self.daim)))
(tset Player :draw (fn [pc]
  (let [stdarc  (* pc.size 2)
        arca    (- pc.aim (/ math.pi 4))
        arcb    (+ pc.aim (/ math.pi 4))]
    (love.graphics.setColor 0 0 0 0.5)
    (love.graphics.arc "fill" "open" pc.x pc.y (- stdarc 1) 0 (* math.pi 2))
    (Enemy.weakColor pc.type)
    (love.graphics.draw pc.i pc.x pc.y pc.daim pc.scale pc.scale pc.ox pc.oy)
    (when (= pc.threat 1) (do
      (local blink (math.sin (* 2 math.pi 24 (love.timer.getTime))))
      (love.graphics.setColor 0 0 0 blink)
      (love.graphics.arc "fill" "open" pc.x pc.y (- stdarc 1) 0 (* math.pi 2))))
    (Enemy.typeColor pc.type) 
    (for [i 0 4 1]
      (love.graphics.arc "line" "open" pc.x pc.y (+ stdarc i) arca arcb))
  (love.graphics.setColor 1 1 1 1))))
Player
