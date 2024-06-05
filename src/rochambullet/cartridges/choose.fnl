(local Enemy (require "src.rochambullet.classes.enemy"))
(local Cartridge (require :classes.cartridge))
(local fennel (require "lib.fennel"))
(local Choose (Cartridge:extend))

(local commands ["rock" "paper" "scissors" "SHOOT"])
(local metronome (love.audio.newSource "src/rochambullet/assets/metronome.mp3" "static"))

(fn update [! dt w h]
  (when (not (metronome:isPlaying)) (metronome:play))
  (when (not !.turn?)
    (if (~= !.caller.name :src.rochambullet.cartridges.turn)
      (Cartridge.load ! :src.rochambullet.cartridges.turn true)
      (Cartridge.load ! :src.rochambullet.cartridges.attack true))))

(fn overlay [old] (fn [! w h]
  (when old.overlay (old:overlay w h))
  (local command (. commands !.tick))
  (local prompt (if (= !.tick (length commands)) 
                    "!!! GET READY !!!" "! click/tap to change type !"))
  (when (and !.tick? command)
    (_G.font:setFilter "linear" "linear")
    (love.graphics.setColor 0 0 0 1)
    (love.graphics.printf command 0 (* 5.5 (/ h 9)) (/ w 8) :center 0 8 8)
    (love.graphics.printf prompt 0 (/ h 4.5) (/ w 4) :center 0 4 4)
    (_G.font:setFilter "nearest" "nearest")
    (Enemy.typeColor command)
    (love.graphics.printf command 0 (* 5.5 (/ h 9)) (/ w 8) :center 0 8 8)
    (love.graphics.printf prompt 0 (/ h 4.5) (/ w 4) :center 0 4 4))))

(fn mousepressed [! x y button istouch presses]
  (let [(tx ty) (!.followplayer:inverseTransformPoint x y)]
    (when (and (or (= button 1) istouch) (< !.tick (length commands)))
      (!.player:choose (. commands !.tick)))))

(tset Choose :new (fn [! w h old]
  (Choose.super.new ! old) ;; keep old state
  (tset ! :overlay (overlay old))
  (tset ! :update update)
  (tset ! :mousepressed mousepressed)
  (love.audio.setEffect "fg" {:type "flanger" :rate 0.125 :depth 1})
  (!.music:setEffect "fg")
  (love.audio.setEffect "eq" {:type "equalizer"
                              :lowgain 1
                              :lowmidgain 0.5 
                              :highmidgain 0.25
                              :highgain 0.125})
  (!.music:setEffect "eq")
  !))
Choose
