(import-macros {: incf} :mac.math)
(local Cartridge (require :classes.cartridge))
(local fennel (require "lib.fennel"))
(local Turn (Cartridge:extend))

(fn update [! dt w h]
  (tset ! :turn? true)
  (local take (math.floor !.turn))
  (incf !.turn (/ 1.0 (+ 4.0 1.0)))
  (if (~= take (math.floor !.turn))
    (do 
      (tset ! :turn? false)
      (Cartridge.load ! !.caller.name true))
    (do
      (!.caller.update ! dt w h)
      (Cartridge.load ! :src.rochambullet.cartridges.tick))))

(tset Turn :new (fn [! w h old]
  (Cartridge.new ! old) ;; keep old state
  (tset ! :update update)
  (when (not !.turn?) (tset ! :turn 1.1))
  !))
Turn
