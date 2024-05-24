(import-macros {: incf : clamp} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Turn (Cartridge:extend))

(local commands ["rock" "paper" "scissors" "SHOOT"])

(fn draw [old] (fn [self w h supercanvas]
  (old.draw self w h supercanvas)
  (when self.turn?
    (local command (. self.commands self.tick))
    (love.graphics.printf command 0 (/ h 8) (/ w 8) :center 0 8 8))))

(fn update [self dt w h]
  (tset self :turn? true)
  (local take (math.floor self.turn))
  (incf self.turn (/ 1 (+ (length commands) 1)))
  (if (~= take (math.floor self.turn))
    (do 
      (tset self :turn? false)
      (Cartridge.load self :src.rochambullet.cartridges.game))
    (Cartridge.load self :src.rochambullet.cartridges.tick)))

(tset Turn :new (fn [self w h old]
  (Turn.super.new self old) ;; keep old state
  (tset self :commands commands)
  (tset self :draw (draw old))
  (tset self :update update)
  (when (not self.turn?) (tset self :turn 1.01))
  self))
Turn
