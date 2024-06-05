(local Cartridge (require :classes.cartridge))
(local Main (Cartridge:extend))

(fn update [! dt w h]
  (Cartridge.load ! :src.rochambullet.cartridges.menu true))

(tset Main :new (fn [! w h old]
  (Main.super.new !) ;; discard old state
  (tset Main :update update)  
  !))
Main
