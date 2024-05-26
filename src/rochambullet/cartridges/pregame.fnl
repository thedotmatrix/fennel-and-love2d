(import-macros {: decf : incf : lerp : clamp : coin} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Pregame (Cartridge:extend))
(local Enemy (require "src.rochambullet.classes.enemy"))
(local Rock (require "src.rochambullet.classes.rock"))
(local Paper (require "src.rochambullet.classes.paper"))
(local Scissors (require "src.rochambullet.classes.scissors"))

(var   alpha          0)
(local sphereize      {:start -0.4 :end -1.2 })
(local crop           {:start 1.5 :end 0.9125 })
(local enemies        [])

(fn load [w h board player]
  (var targetx (love.math.random (/ board.px -2) (/ board.px 2)))
  (var targety (love.math.random (/ board.px -2) (/ board.px 2)))
  (player:reset board)
  (set player.start {:x player.x :y player.y})
  (set player.x     targetx)
  (set player.y     targety)
  (player:digital board)
  (set targetx player.x)
  (set targety player.y)
  (set player.end { :x (- targetx player.start.x)
                    :y (- targety player.start.y)})
  (set player.x   player.start.x)
  (set player.y   player.start.y)
  (set player.alpha 0)
  (for [j 0 (- board.tiles 1)] (for [i 0 (- board.tiles 1)]
    (let [ex (+ (* j board.tilepx) (/ board.tilepx 2) (/ board.px -2))
          ey (+ (* i board.tilepx) (/ board.tilepx 2) (/ board.px -2))]
      (when (or (~= ex targetx) (~= ey targety))
        (do 
          (local enemy
            (match (math.floor (love.math.random 1 4))
             1 (Rock ex ey)
             2 (Paper ex ey)
             3 (Scissors ex ey)
             4 nil))
          (when enemy (table.insert enemies enemy))))))))

(fn update [self dt w h]
  ; lerp alpha
  (set alpha (self.player:anim (/ dt 4) self.board))
  (when (>= alpha 1.0) (set alpha 1.0))
  ; audio
  (love.audio.setEffect "fg" {:type "flanger" :rate 0.125 :depth alpha})
  (self.music:setEffect "fg")
  (love.audio.setEffect "eq" {:type "equalizer"
                              :lowgain (+ 0.125 (* 0.825 alpha))
                              :lowmidgain (+ 0.25 (* 0.25 alpha)) 
                              :highmidgain (- 0.5 (* 0.25 alpha))
                              :highgain (- 1 (* 0.825 alpha))})
  (self.music:setEffect "eq")
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
