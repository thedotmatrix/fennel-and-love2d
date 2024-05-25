(import-macros {: incf} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Tick (Cartridge:extend))

(fn update [self dt w h] 
  (self.caller.update self dt w h)
  (tset self :tick? true)
  (incf self.time dt)
  (local tock self.tick)
  (set self.tick (+ (% (- (math.floor self.time) 1.0) 4.0) 1.0))
  (when (~= self.tick tock)
    (tset self :tick? false)
    (Cartridge.load self :src.rochambullet.cartridges.turn)))

(tset Tick :new (fn [self w h old]
  (Tick.super.new self old) ;; keep old state
  (tset self :update update)
  (when (not self.time) (tset self :time 1.0))
  (when (not self.tick) (tset self :tick 1.0))
  (when (not self.tick?) (tset self :tick? true))
  self))
Tick
