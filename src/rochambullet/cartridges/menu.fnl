(import-macros {: decf} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Menu (Cartridge:extend))
(local Board (require :src.rochambullet.classes.board))

(local board (Board 8 128))
(local shader (love.graphics.newShader "src/rochambullet/assets/sphere.glsl"))
(var canvas nil)
(local centercanvas (love.math.newTransform))
(local centerworld (love.math.newTransform))
(local rotateworld (love.math.newTransform))
(var rotationspeed! 0)

(fn load [w h]
  (let [csize (* w (+ (/ 1 16) 1.0))]
    (set canvas (love.graphics.newCanvas csize csize)))
  (let [tx    (/ (- (canvas:getWidth) w) 2)
        ty    (/ (- (canvas:getHeight) h) 2)]
    (centercanvas:setTransformation tx ty 0 1 1 0 0 0 0))
  (let [tx (- (/ w 2) 0)
        ty (- (/ h 2) 0)]
    (centerworld:setTransformation tx ty 0 1 1 0 0 0 0)))

(fn draw [self w h supercanvas]
  (love.graphics.setCanvas self.canvas)
  (love.graphics.push)
  (love.graphics.applyTransform centerworld)
  (love.graphics.applyTransform rotateworld)
  (love.graphics.applyTransform self.centercanvas)
  (self.board:draw*)
  (love.graphics.pop)
  (love.graphics.setCanvas supercanvas)
  (love.graphics.setShader self.shader)
  (love.graphics.push)
  (love.graphics.applyTransform (self.centercanvas:inverse))
  (love.graphics.clear 0.25 0 0.25 1)
  (love.graphics.draw self.canvas)
  (love.graphics.pop)
  (love.graphics.setShader)
  ;; FIXME tutorial description of aiming, choosing, attacking with gifs!
  (love.graphics.printf "RoChamBULLET" 0 (/ h 8) (/ w 8) :center 0 8 8)
  (love.graphics.printf   (.. "F11 to Enter Fullscreen\n"
                              "Double-Click/Tap to Start")
                          0 (/ h 2) (/ w 4) :center 0 4 4))

(fn update [self dt w h]
  (set rotationspeed! (% (+ rotationspeed! (* dt 64)) 512))
  (rotateworld:setTransformation 0 rotationspeed! 0 1 1 0 0 0 0)
  (self.shader:send :manual_amount 2)
  (self.shader:send :fx -0.4))

(fn mousepressed [self x y button istouch presses]
  (when (and (or (= button 1) istouch) (> presses 1))
    (Cartridge.load self :src.rochambullet.cartridges.pregame)))

(tset Menu :new (fn [self w h old]
  (Menu.super.new self) ;; discard old state
  (load w h)
  (tset self :board board)
  (tset self :shader shader)
  (tset self :canvas canvas)
  (tset self :centercanvas centercanvas)
  (tset self :draw draw)
  (tset self :update update)
  (tset self :mousepressed mousepressed)
  self))
Menu
