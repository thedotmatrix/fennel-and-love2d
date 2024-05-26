(import-macros {: digital} :mac.math)
(local Character (require "src.rochambullet.classes.character"))
(local Enemy (Character:extend))
(tset Enemy :new (fn [self ex ey]
  (let [ea  (love.math.random 0 (* 2 math.pi))
        ead (digital ea)
        img (.. "src/rochambullet/assets/" self.type ".png")]
    (Enemy.super.new self ex ey 1 ead 0.3 img))))
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
(tset Enemy :draw (fn [self ox oy]
  (Enemy.typeColor self.type)
  (love.graphics.draw self.i self.x self.y 0 self.scale self.scale
                      (+ self.ox (/ ox self.scale)) 
                      (+ self.oy (/ oy self.scale)))
  (love.graphics.setColor 1 1 1 1)))
(tset Enemy :draw* (fn [self offset] ;; TODO draw visible dupes only
  (self:draw (* offset -1)  (* offset -1))
  (self:draw (* offset 0)   (* offset -1))
  (self:draw (* offset 1)   (* offset -1))
  (self:draw (* offset -1)  (* offset 0))
  (self:draw (* offset 0)   (* offset 0))
  (self:draw (* offset 1)   (* offset 0))
  (self:draw (* offset -1)  (* offset 1))
  (self:draw (* offset 0)   (* offset 1))
  (self:draw (* offset 1)   (* offset 1))))
Enemy
