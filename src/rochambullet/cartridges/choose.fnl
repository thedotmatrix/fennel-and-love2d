(local Cartridge (require :classes.cartridge))
(local fennel (require "lib.fennel"))
(local Choose (Cartridge:extend))

(local commands ["rock" "paper" "scissors" "SHOOT"])

(fn update [self dt w h]
  (when (not self.turn?)
    (if (~= self.caller.name :src.rochambullet.cartridges.turn)
      (Cartridge.load self :src.rochambullet.cartridges.turn true)
      (Cartridge.load self :src.rochambullet.cartridges.attack true))))

(fn draw [old] (fn [self w h supercanvas]
  (old.draw self w h supercanvas)
  (when (and  self.turn? 
              (= self.caller.name :src.rochambullet.cartridges.choose))
    (local command (. commands self.tick))
    (love.graphics.printf command 0 (/ h 8) (/ w 8) :center 0 8 8))))

(tset Choose :new (fn [self w h old]
  (Choose.super.new self old) ;; keep old state
  (tset self :update update)
  (tset self :draw (draw old))
  (when (not self.turn) (self.player:digital self.board))
  self))
Choose
