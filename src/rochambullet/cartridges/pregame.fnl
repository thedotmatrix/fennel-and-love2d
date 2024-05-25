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
(local start          {:x nil :y nil})
(local end            {:x nil :y nil})
(local enemies        [])

(fn load [w h board player]
  (set start.x    player.x)
  (set start.y    player.y)
  (set player.x   (love.math.random (/ board.px -4) (/ board.px 4)))
  (set player.y   (love.math.random (/ board.px -4) (/ board.px 4)))
  (player:digital board)
  (set end.x      player.x)
  (set end.y      player.y)
  (set player.x   start.x)
  (set player.y   start.y)
  (for [i 1 3]
    (table.insert enemies (Rock board end.x end.y))
    (table.insert enemies (Paper board end.x end.y))
    (table.insert enemies (Scissors board end.x end.y))))

(fn update [self dt w h]
  ; lerp alpha
  (local alpha (self.player:anim dt self.board))
  (if alpha
    (do
      ; shader
      (set self.sphereize! (lerp sphereize.start sphereize.end alpha))
      (set self.crop! (lerp crop.start crop.end alpha))
      (self.shader:send :fx self.sphereize!)
      (self.shader:send :manual_amount self.crop!)
      ; dynamic transform
      (let [tx (- (/ w 2) self.player.x)
            ty (- (/ h 2) self.player.y)]
        (self.followplayer:setTransformation tx ty 0 1 1 0 0 0 0)))
      ; animations done
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
