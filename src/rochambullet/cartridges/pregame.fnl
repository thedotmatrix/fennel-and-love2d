(import-macros {: decf} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Pregame (Cartridge:extend))

(local Player (require "src.rochambullet.classes.player"))
(var player nil)
(local followplayer (love.math.newTransform))

(fn load [w h]
  (set player (Player (love.math.random (* w -1) w) 
                      (love.math.random (* h -1) h))))

(fn draw [self w h supercanvas]
  (love.graphics.setCanvas self.canvas)
  (love.graphics.push)
  (love.graphics.applyTransform self.followplayer)
  (love.graphics.applyTransform self.centercanvas)
  (self.board:draw*)
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
    (Cartridge.load self :src.rochambullet.cartridges.game))
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
  (load w h)
  (tset self :player player)
  (tset self :followplayer followplayer)
  (tset self :draw draw)
  (tset self :update update)
  (tset self :keypressed nil)
  (tset self :mousemoved mousemoved)
  (tset self :mousepressed mousepressed)
  (tset self :sphereize! -0.4)
  self))
Pregame
