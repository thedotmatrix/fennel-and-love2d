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

(fn overlay [old] (fn [self w h]
  (when old.overlay (old:overlay w h))
  (local command (. commands self.tick))
  (local prompt (if (= self.tick (length commands)) 
                    "!!! GET READY !!!" "! click to change type !"))
  (when (and self.tick? command)
    (_G.font:setFilter "linear" "linear")
    (love.graphics.setColor 0 0 0 1)
    (love.graphics.printf command 0 (* 5 (/ h 9)) (/ w 8) :center 0 8 8)
    (love.graphics.printf prompt 0 (/ h 4.5) (/ w 4) :center 0 4 4)
    (_G.font:setFilter "nearest" "nearest")
    (Enemy.typeColor command)
    (love.graphics.printf command 0 (* 5 (/ h 9)) (/ w 8) :center 0 8 8)
    (love.graphics.printf prompt 0 (/ h 4.5) (/ w 4) :center 0 4 4))))

(fn mousepressed [self x y button istouch presses]
  (let [(tx ty) (self.followplayer:inverseTransformPoint x y)]
    (when (and (or (= button 1) istouch) (< self.tick (length commands)))
      (set self.player.type (. commands self.tick)))))

(tset Choose :new (fn [self w h old]
  (Choose.super.new self old) ;; keep old state
  (tset self :overlay (overlay old))
  (tset self :update update)
  (tset self :mousepressed mousepressed)
  self))
Choose
