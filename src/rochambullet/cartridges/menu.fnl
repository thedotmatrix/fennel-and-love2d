(import-macros {: decf : coin} :mac.math)
(local Cartridge (require :classes.cartridge))
(local Menu (Cartridge:extend))
(local Board (require :src.rochambullet.classes.board))
(local Player (require :src.rochambullet.classes.player))

(local board (Board 8 128))
(var player nil)
(var canvas nil)
(local centercanvas (love.math.newTransform))
(local followplayer (love.math.newTransform))
(local shader (love.graphics.newShader "src/rochambullet/assets/sphere.glsl"))

(fn load [w h]
  (set player   (Player (coin (/ board.tilepx -2) (/ board.tilepx 2))
                        (coin (/ board.tilepx -2) (/ board.tilepx 2))))
  (let [csize (* w (+ (/ 1 16) 1.0))]
    (set canvas (love.graphics.newCanvas csize csize)))
  (let [tx    (/ (- (canvas:getWidth) w) 2)
        ty    (/ (- (canvas:getHeight) h) 2)]
    (centercanvas:setTransformation tx ty 0 1 1 0 0 0 0))
  (shader:send :manual_amount 1.5)
  (shader:send :fx -0.4))

(fn overlay [self w h]
  ;; FIXME tutorial description of aiming, choosing, attacking with gifs!
  (love.graphics.printf "RoChamBULLET" 0 (/ h 8) (/ w 8) :center 0 8 8)
  (love.graphics.printf   (.. "F11 to Enter Fullscreen\n"
                              "Double-Click/Tap to Start")
                          0 (/ h 2) (/ w 4) :center 0 4 4))

(fn draw [self w h supercanvas]
  (love.graphics.setCanvas self.canvas)
  (love.graphics.push)
  (love.graphics.applyTransform self.followplayer)
  (love.graphics.applyTransform self.centercanvas)
  (self.board:draw*)
  (when self.enemies (each [_ e (pairs self.enemies)] (e:draw* self.board.px)))
  (self.player:draw)
  (love.graphics.pop)
  (love.graphics.setCanvas supercanvas)
  (love.graphics.setShader self.shader)
  (love.graphics.push)
  (love.graphics.applyTransform (self.centercanvas:inverse))
  (love.graphics.clear 0.25 0 0.25 1)
  (love.graphics.draw self.canvas)
  (love.graphics.pop)
  (love.graphics.setShader)
  (when self.overlay (self:overlay w h)))

(fn update [self dt w h]
  (self.player:anim dt self.board)
  ;; TODO class since duped across every update
  (let [tx (- (/ w 2) self.player.x)
        ty (- (/ h 2) self.player.y)]
    (self.followplayer:setTransformation tx ty 0 1 1 0 0 0 0)))

(fn mousepressed [self x y button istouch presses]
  (when (and (or (= button 1) istouch) (> presses 1))
    (Cartridge.load self :src.rochambullet.cartridges.pregame)))

(tset Menu :new (fn [self w h old]
  (Menu.super.new self) ;; discard old state
  (load w h)
  (tset self :board board)
  (tset self :player player)
  (tset self :canvas canvas)
  (tset self :centercanvas centercanvas)
  (tset self :followplayer followplayer)
  (tset self :shader shader)
  (tset self :overlay overlay)
  (tset self :draw draw)
  (tset self :update update)
  (tset self :mousepressed mousepressed)
  self))
Menu
