(import-macros {: decf} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Pregame (Cartridge:extend))
(local Enemy (require "src.rochambullet.classes.enemy"))
(local Rock (require "src.rochambullet.classes.rock"))
(local Paper (require "src.rochambullet.classes.paper"))
(local Scissors (require "src.rochambullet.classes.scissors"))

(local Player (require "src.rochambullet.classes.player"))
(var player nil)
(local followplayer (love.math.newTransform))
(local enemies [])

(fn load [w h boardpx]
  (set player (Player (love.math.random (* w -1) w) 
                      (love.math.random (* h -1) h)))
  (for [i 1 10] 
    (table.insert enemies (Rock boardpx))
    (table.insert enemies (Paper boardpx))
    (table.insert enemies (Scissors boardpx))))

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
  (if (> self.sphereize! -1.2)
    (decf self.sphereize! (* (+ (- self.sphereize! -1.2) 0.1) dt))
    (Cartridge.load self :src.rochambullet.cartridges.turn))
  (self.shader:send :fx self.sphereize!)
  (self.shader:send :manual_amount (* (- 1.5 (/ self.sphereize! -2.4)) 0.9125))
  (when (~= self.player.x 0) (decf self.player.x (* self.player.x dt)))
  (when (~= self.player.x 0) (decf self.player.y (* self.player.y dt)))
  (let [tx (- (/ w 2) self.player.x)
        ty (- (/ h 2) self.player.y)]
    (self.followplayer:setTransformation tx ty 0 1 1 0 0 0 0)))

(fn mousemoved [self x y dx dy istouch]
  (let [(tx ty) (self.followplayer:inverseTransformPoint x y)]
    (self.player:aiming tx ty)))

(fn mousepressed [self x y button istouch presses]
  (let [(tx ty) (self.followplayer:inverseTransformPoint x y)]
    false))

(tset Pregame :new (fn [self w h old]
  (Pregame.super.new self old) ;; keep old state
  (load w h self.board.px)
  (tset self :player player)
  (tset self :followplayer followplayer)
  (tset self :enemies enemies)
  (tset self :draw draw)
  (tset self :update update)
  (tset self :keypressed nil)
  (tset self :mousemoved mousemoved)
  (tset self :mousepressed mousepressed)
  (tset self :sphereize! -0.4)
  self))
Pregame