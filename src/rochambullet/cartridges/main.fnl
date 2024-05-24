(local Cartridge (require :classes.cartridge))
(local Main (Cartridge:extend))

(fn update [self dt w h]
  (Cartridge.load self :src.rochambullet.cartridges.menu true))

(tset Main :new (fn [self w h old]
  (Main.super.new self) ;; discard old state
  (tset Main :update update)  
  self))
Main
