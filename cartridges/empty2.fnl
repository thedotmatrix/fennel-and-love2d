(local Cartridge (require :classes.cartridge))
(local Empty (Cartridge:extend))

(fn draw [self w h supercanvas]
  (love.graphics.print (..  "a is " (tostring (?. self :a)) "\n"
                            "b is " (tostring (?. self :b)))))

(fn keypressed [self key scancode repeat] (match key
  :space (self.super.load self :cartridges.empty)))

(tset Empty :new (fn [self w h old]
  (Empty.super.new self) ;; discard old state
  (tset self :draw draw)
  (tset self :keypressed keypressed)
  (set self.b 69) 
  self))
Empty
