(import-macros {: decf : incf : lerp : clamp : coin} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Postgame (Cartridge:extend))

(var   alpha          0)
(local sphereize      {:end -0.4 :start -1.2 })
(local crop           {:end 1.5 :start 0.9125 })

(fn overlay [old] (fn [! w h]
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

(fn update [! dt w h]
  ; lerp alpha
  (set alpha (!.player:anim (/ dt 5) !.board))
  (when (>= alpha 1.0) (set alpha 1.0))
  ; shader
  (set !.sphereize! (lerp sphereize.start sphereize.end alpha))
  (set !.crop! (lerp crop.start crop.end alpha))
  (!.shader:send :fx !.sphereize!)
  (!.shader:send :manual_amount !.crop!)
  ; dynamic transform
  (let [tx (- (/ w 2) !.player.x)
        ty (- (/ h 2) !.player.y)]
    (!.followplayer:setTransformation tx ty 0 1 1 0 0 0 0))
  ; animations done
  (when (= alpha 1.0)
    (Cartridge.load ! :src.rochambullet.cartridges.menu true)))

(tset Postgame :new (fn [! w h old]
  (Postgame.super.new ! old) ;; keep old state
  (tset ! :update update)
  (tset ! :mousepressed nil)
  (tset ! :mousemoved nil)
  (tset ! :sphereize! sphereize.start)
  (tset ! :crop! crop.start)
  (tset ! :overlay (overlay old))
  (!.player:reset !.board)
  !))
Postgame
