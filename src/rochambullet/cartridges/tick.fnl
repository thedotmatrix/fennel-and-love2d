(import-macros {: incf} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Tick (Cartridge:extend))

(fn update [! dt w h] 
  (!.caller.update ! dt w h)
  (tset ! :tick? true)
  (incf !.time dt)
  (local tock !.tick)
  (set !.tick (+ (% (- (math.floor !.time) 1.0) 4.0) 1.0))
  (when (~= !.tick tock)
    (tset ! :tick? false)
    (Cartridge.load ! :src.rochambullet.cartridges.turn)))

(tset Tick :new (fn [! w h old]
  (Tick.super.new ! old) ;; keep old state
  (tset ! :update update)
  (when (not !.time) (tset ! :time 1.0))
  (when (not !.tick) (tset ! :tick 1.0))
  (when (not !.tick?) (tset ! :tick? true))
  !))
Tick
