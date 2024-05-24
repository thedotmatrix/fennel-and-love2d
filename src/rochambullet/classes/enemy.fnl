(local Character (require "src.rochambullet.classes.character"))
(local Enemy (Character:extend))
(tset Enemy :new (fn [self board]
  (let [ex (love.math.random (/ board.px -2) (/ board.px 2))
        ey (love.math.random (/ board.px -2) (/ board.px 2))
        ea (love.math.random 0 (* 2 math.pi))
        ead (* (math.floor (/   (+ ea (/ math.pi 8)) 
                                (/ math.pi 4))) 
              (/ math.pi 4))]
    (Enemy.super.new self ex ey 1 ead "src/rochambullet/assets/bomb.png" 0.5)
    (self:digital board))))
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
