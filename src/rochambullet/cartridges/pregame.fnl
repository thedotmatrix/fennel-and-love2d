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
(local Player         (require "src.rochambullet.classes.player"))
(local start          {:x nil :y nil})
(var player nil)
(local end            {:x nil :y nil})
(local followplayer   (love.math.newTransform))
(local enemies        [])

(fn load [w h board]
  (set start.x  (love.math.random (* w -1) w))
  (set start.y  (love.math.random (* h -1) h))
  (set player   (Player start.x start.y))
  (set end.x    (coin (/ board.tilepx -2) (/ board.tilepx 2)))
  (set end.y    (coin (/ board.tilepx -2) (/ board.tilepx 2)))
  (for [i 1 9] ;; FIXME enemies cant spawn on top of player
    (table.insert enemies (Rock board))
    (table.insert enemies (Paper board))
    (table.insert enemies (Scissors board))))

(fn draw [self w h supercanvas]
  (love.graphics.setCanvas self.canvas)
  (love.graphics.push)
  (love.graphics.applyTransform self.followplayer)
  (love.graphics.applyTransform self.centercanvas)
  (self.board:draw*)
  (each [_ e (pairs self.enemies)] (e:draw* self.board.px))
  (self.player:draw)
  (love.graphics.pop)
  (love.graphics.setCanvas supercanvas)
  (love.graphics.setShader self.shader)
  (love.graphics.push)
  (love.graphics.applyTransform (self.centercanvas:inverse))
  (love.graphics.clear 0.25 0 0.25 1)
  (love.graphics.draw self.canvas)
  (love.graphics.pop)
  (love.graphics.setShader))

(fn update [self dt w h]
  ; lerp alpha
  (incf alpha dt)
  (clamp alpha 0 1)
  ; shader
  (set self.sphereize! (lerp sphereize.start sphereize.end alpha))
  (set self.crop! (lerp crop.start crop.end alpha))
  (self.shader:send :fx self.sphereize!)
  (self.shader:send :manual_amount self.crop!)
  ; player position
  (set self.player.x (lerp start.x end.x alpha))
  (set self.player.y (lerp start.y end.y alpha))
  ; camera transform
  (let [tx (- (/ w 2) self.player.x)
        ty (- (/ h 2) self.player.y)]
    (self.followplayer:setTransformation tx ty 0 1 1 0 0 0 0))
  ; animation done
  (when (>= alpha 1.0)
    (Cartridge.load self :src.rochambullet.cartridges.choose true)))

(fn mousemoved [self x y dx dy istouch]
  (let [(tx ty) (self.followplayer:inverseTransformPoint x y)]
    (self.player:aiming tx ty)))

(tset Pregame :new (fn [self w h old]
  (Pregame.super.new self old) ;; keep old state
  (load w h self.board)
  (tset self :sphereize! -0.4)
  (tset self :crop! 1.5)
  (tset self :player player)
  (tset self :followplayer followplayer)
  (tset self :enemies enemies)
  (tset self :draw draw)
  (tset self :update update)
  (tset self :mousepressed nil)
  (tset self :mousemoved mousemoved)
  self))
Pregame
