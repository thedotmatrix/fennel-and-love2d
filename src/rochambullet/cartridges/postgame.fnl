(import-macros {: decf : incf : lerp : clamp : coin} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Postgame (Cartridge:extend))

(var   alpha          0)
(local sphereize      {:end -0.4 :start -1.2 })
(local crop           {:end 1.5 :start 0.9125 })

(fn overlay [old] (fn [self w h]
  (old:overlay w h)
  (_G.font:setFilter "linear" "linear")
  (love.graphics.setColor 0 0 0 1)
  (love.graphics.printf ["Thx" "For" "PLAYIN"] 
                          0 (+ 0 (/ h 36)) (/ w 8) :center 0 8 8)
  (love.graphics.printf "g a m e  o v e r" 
                          0 (+ (/ h 2) (/ h 4.5)) (/ w 4) :center 0 4 4)
  (love.graphics.setColor 1 1 1 1)
  (_G.font:setFilter "nearest" "nearest")
  (love.graphics.printf [[1 0 1 1] "Thx" [0 1 0 1] "For" [0 1 1 1] "PLAYIN"] 
                          0 (+ 0 (/ h 36)) (/ w 8) :center 0 8 8)
  (love.graphics.printf "g a m e  o v e r"
                          0 (+ (/ h 2) (/ h 4.5)) (/ w 4) :center 0 4 4)))

(fn update [self dt w h]
  ; lerp alpha
  (set alpha (self.player:anim (/ dt 5) self.board))
  (when (>= alpha 1.0) (set alpha 1.0))
  ; shader
  (set self.sphereize! (lerp sphereize.start sphereize.end alpha))
  (set self.crop! (lerp crop.start crop.end alpha))
  (self.shader:send :fx self.sphereize!)
  (self.shader:send :manual_amount self.crop!)
  ; dynamic transform
  (let [tx (- (/ w 2) self.player.x)
        ty (- (/ h 2) self.player.y)]
    (self.followplayer:setTransformation tx ty 0 1 1 0 0 0 0))
  ; animations done
  (when (= alpha 1.0)
    (Cartridge.load self :src.rochambullet.cartridges.menu true)))

(tset Postgame :new (fn [self w h old]
  (Postgame.super.new self old) ;; keep old state
  (tset self :update update)
  (tset self :mousepressed nil)
  (tset self :mousemoved nil)
  (tset self :sphereize! sphereize.start)
  (tset self :crop! crop.start)
  (tset self :overlay (overlay old))
  (self.player:reset self.board)
  self))
Postgame
