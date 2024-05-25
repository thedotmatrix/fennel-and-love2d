(local Enemy (require "src.rochambullet.classes.enemy"))
(local Cartridge (require :classes.cartridge))
(local fennel (require "lib.fennel"))
(local Choose (Cartridge:extend))

(local commands ["rock" "paper" "scissors" "SHOOT"])

(fn update [self dt w h]
  (when (not self.turn?)
    (if (~= self.caller.name :src.rochambullet.cartridges.turn)
      (Cartridge.load self :src.rochambullet.cartridges.turn true)
      (Cartridge.load self :src.rochambullet.cartridges.attack true))))

(fn overlay [self w h]
  (local command (. commands self.tick))
  (when (and self.tick? command)
    (Enemy.typeColor command)
    (love.graphics.printf command 0 (/ h 8) (/ w 8) :center 0 8 8)))

(fn mousepressed [self x y button istouch presses]
  (let [(tx ty) (self.followplayer:inverseTransformPoint x y)]
    (when (and (or (= button 1) istouch) (< self.tick (length commands)))
      (set self.player.type (. commands self.tick)))))

(tset Choose :new (fn [self w h old]
  (Choose.super.new self old) ;; keep old state
  (tset self :overlay overlay)
  (tset self :update update)
  (tset self :mousepressed mousepressed)
  self))
Choose
