(local sweetheat (require "src.sweetheat.assets.sweetheat"))
(local Cartridge (require :classes.cartridge))
(local Main (Cartridge:extend))

(fn update [self dt w h]
  (sweetheat.update dt))

(fn draw [self w h supercanvas]
  (sweetheat.draw w h supercanvas))

(tset Main :new (fn [self w h old]
  (Main.super.new self) ;; discard old state
  (sweetheat.load w h)
  (tset Main :update update)
  (tset Main :draw draw)
  self))
Main
