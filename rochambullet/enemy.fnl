(local Character (require "rochambullet.character"))
(local Enemy (Character:extend))
(tset Enemy :new (fn [self range]
  (let [ex (love.math.random (/ range -2) (/ range 2))
        ey (love.math.random (/ range -2) (/ range 2))
        ea (love.math.random 0 (* 2 math.pi))]
    (self.super.new self ex ey 128 ea "bin/rochambullet/bomb.png" 0.25))))
(tset Enemy :draw (fn [self ox oy]
  (love.graphics.draw self.i self.x self.y 0 self.scale self.scale
                      (+ self.ox (/ ox self.scale)) 
                      (+ self.oy (/ oy self.scale)))))
(tset Enemy :draw* (fn [self offset] ;; FIXME draw visible dupes only
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
