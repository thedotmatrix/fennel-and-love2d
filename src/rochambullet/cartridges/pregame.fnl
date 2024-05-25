(import-macros {: decf : incf : lerp : clamp : coin} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Pregame (Cartridge:extend))
(local Enemy (require "src.rochambullet.classes.enemy"))
(local Rock (require "src.rochambullet.classes.rock"))
(local Paper (require "src.rochambullet.classes.paper"))
(local Scissors (require "src.rochambullet.classes.scissors"))

(var alpha            0)
(local sphereize      {:start -0.4 :end -1.2 })
(local crop           {:start 1.5 :end 0.9125 })
(local enemies        [])

(fn load [w h board player]
  (player:reset board)
  (set player.start {:x player.x :y player.y})
  (set player.x     (love.math.random (/ board.px -2) (/ board.px 2)))
  (set player.y     (love.math.random (/ board.px -2) (/ board.px 2)))
  (player:digital board)
  (set player.end { :x (+ player.x (/ board.tilepx 2)) 
                    :y (+ player.y (/ board.tilepx 2))})
  (print [player.end.x "\t" player.end.y])
  (set player.x   player.start.x)
  (set player.y   player.start.y)
  (set player.alpha 0)
  (for [i 1 4]
    (table.insert enemies (Rock board player.end.x player.end.y))
    (table.insert enemies (Paper board player.end.x player.end.y))
    (table.insert enemies (Scissors board player.end.x player.end.y))))

(fn update [self dt w h]
  ; lerp alpha
  (var alpha (self.player:anim dt self.board))
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
    (Cartridge.load self :src.rochambullet.cartridges.choose true)))

(fn mousemoved [self x y dx dy istouch]
  (let [(tx ty) (self.followplayer:inverseTransformPoint x y)]
    (self.player:aiming tx ty)))

(tset Pregame :new (fn [self w h old]
  (Pregame.super.new self old) ;; keep old state
  (load w h self.board self.player)
  (tset self :sphereize! -0.4)
  (tset self :crop! 1.5)
  (tset self :enemies enemies)
  (tset self :update update)
  (tset self :overlay nil)
  (tset self :mousepressed nil)
  (tset self :mousemoved mousemoved)
  self))
Pregame
