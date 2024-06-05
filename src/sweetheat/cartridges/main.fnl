(local sweetheat (require "src.sweetheat.assets.sweetheat"))
(local Cartridge (require :classes.cartridge))
(local Main (Cartridge:extend))

(fn update [! dt w h]
  (sweetheat.update dt))

(fn draw [! w h supercanvas]
  (sweetheat.draw w h supercanvas))

(tset Main :new (fn [! w h old]
  (Main.super.new !) ;; discard old state
  (sweetheat.load w h)
  (tset Main :update update)
  (tset Main :draw draw)
  !))
Main
