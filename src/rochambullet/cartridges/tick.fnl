(import-macros {: incf : clamp} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Tick (Cartridge:extend))

(fn update [self dt w h] 
  (incf self.time dt)
  (local tock self.tick)
  (set self.tick (+ (% (- (math.floor self.time) 1) 4) 1))
  (when (~= self.tick tock)
    (Cartridge.load self :src.rochambullet.cartridges.turn)))

(tset Tick :new (fn [self w h old]
  (Tick.super.new self old) ;; keep old state
  (tset self :update update)
  (when (not self.time) (tset self :time 1))
  (when (not self.tick) (tset self :tick 1))
  self))
Tick
