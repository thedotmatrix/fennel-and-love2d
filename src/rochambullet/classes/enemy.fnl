(import-macros {: digital} :mac.math)
(local Character (require "src.rochambullet.classes.character"))
(local Enemy (Character:extend))
(tset Enemy :new (fn [self ex ey]
  (let [ea  (love.math.random 0 (* 2 math.pi))
        ead (digital ea)]
    (Enemy.super.new self ex ey 1 ead "src/rochambullet/assets/bomb.png" 0.5))))
(tset Enemy :draw (fn [self ox oy]
  (love.graphics.draw self.i self.x self.y 0 self.scale self.scale
                      (+ self.ox (/ ox self.scale)) 
                      (+ self.oy (/ oy self.scale)))))
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
