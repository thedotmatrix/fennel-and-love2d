(import-macros {: incf} :mac.math)
(local Cartridge (require :classes.cartridge))
(local fennel (require "lib.fennel"))
(local Turn (Cartridge:extend))

(fn update [self dt w h]
  (tset self :turn? true)
  (local take (math.floor self.turn))
  (incf self.turn (/ 1 (+ 4 1)))
  (if (~= take (math.floor self.turn))
    (do 
      (tset self :turn? false)
      (Cartridge.load self self.caller.name true))
    (do
      (self.caller.update self dt w h)
      (Cartridge.load self :src.rochambullet.cartridges.tick))))

(tset Turn :new (fn [self w h old]
  (Cartridge.new self old) ;; keep old state
  (tset self :update update)
  (when (not self.turn?) (tset self :turn 1.01))
  self))
Turn
