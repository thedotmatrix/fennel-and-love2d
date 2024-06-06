(import-macros {: digital} :mac.math)
(local Character (require "src.rochambullet.classes.character"))
(local Enemy (Character:extend))
(tset Enemy :new (fn [! ex ey]
  (let [ea  (love.math.random 0 (* 2 math.pi))
        ead (digital ea)
        img (.. "src/rochambullet/assets/" !.type ".png")]
    (Enemy.super.new ! ex ey 1 ead 0.3 img))))
(tset Enemy :typeColor (fn [typ]
  (match typ 
    "rock"      (love.graphics.setColor 1 0 1 1)
    "paper"     (love.graphics.setColor 0 1 0 1)
    "scissors"  (love.graphics.setColor 0 1 1 1)
    _           (love.graphics.setColor 1 1 1 1))))
(tset Enemy :weakColor (fn [typ]
  (match typ 
    "rock"      (Enemy.typeColor "scissors")
    "paper"     (Enemy.typeColor "rock")
    "scissors"  (Enemy.typeColor "paper")
    _           (love.graphics.setColor 1 1 1 1))))
(tset Enemy :draw (fn [! ox oy]
  (Enemy.typeColor !.type)
  (love.graphics.draw !.i !.x !.y 0 !.scale !.scale
                      (+ !.ox (/ ox !.scale)) 
                      (+ !.oy (/ oy !.scale)))
  (love.graphics.setColor 1 1 1 1)))
(tset Enemy :draw* (fn [! offset] ;; LATER draw visible dupes only
  (!:draw (* offset -1)  (* offset -1))
  (!:draw (* offset 0)   (* offset -1))
  (!:draw (* offset 1)   (* offset -1))
  (!:draw (* offset -1)  (* offset 0))
  (!:draw (* offset 0)   (* offset 0))
  (!:draw (* offset 1)   (* offset 0))
  (!:draw (* offset -1)  (* offset 1))
  (!:draw (* offset 0)   (* offset 1))
  (!:draw (* offset 1)   (* offset 1))))
Enemy
