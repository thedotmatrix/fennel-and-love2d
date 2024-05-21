(import-macros {: decf} :macros.math)
(local Board (require "rochambullet.board"))
(local board (Board 32 32))
(local Player (require "rochambullet.player"))
(local player (Player 0 0))
(local Enemy (require "rochambullet.enemy"))
(local enemies [])
(local transform (love.math.newTransform))
(fn updateTransform [w h]
  (let [tx (- (/ w 2) player.x)
        ty (- (/ h 2) player.y)
        (mx my) (love.mouse.getPosition)]
    (transform:setTransformation tx ty 0 1 1 0 0 0 0)
    (love.mousemoved mx my 0 0 false)))
(local shader (love.graphics.newShader "bin/rochambullet/sphere.glsl"))
(local fov (/ 1 8)) ;; -1 (black hole) - 0 (regular sphere) - 1 (almost flat)
(var canvas nil)
(local centercanvas (love.math.newTransform))

(fn load [w h]
  (let [csize (* w (+ fov 1.0))]
    (set canvas (love.graphics.newCanvas csize csize)))
  (let [tx    (/ (- (canvas:getWidth) w) 2)
        ty    (/ (- (canvas:getHeight) h) 2)]
    (centercanvas:setTransformation tx ty 0 1 1 0 0 0 0))
  (for [i 1 4] (table.insert enemies (Enemy board.px)))
  (updateTransform w h))

(fn draw [w h supercanvas] (fn []
  (love.graphics.setCanvas canvas)
  (love.graphics.push)
  (love.graphics.applyTransform transform)
  (love.graphics.applyTransform centercanvas)
  (board:draw* 0 0)
  (each [_ e (ipairs enemies)] (e:draw w h))
  (player:draw w h)
  (love.graphics.pop)
  (love.graphics.setCanvas supercanvas)
  (love.graphics.setShader shader)
  (love.graphics.push)
  (love.graphics.applyTransform (centercanvas:inverse))
  (love.graphics.clear 0.1 0 0.2 1)
  (love.graphics.draw canvas)
  (love.graphics.pop)
  (love.graphics.setShader)))

(fn update [dt w h]
  (when (> (length player.dir) 0)
    (player:update dt board.px)
    (print (.. player.x ", " player.y))
    (updateTransform w h))
  (when (> player.attack 0) (decf player.attack dt))
  (each [_ e (ipairs enemies)] (e:update dt board.px)))

(fn keypressed [key scancode repeat?]
  (match key
    :left  (tset player.keys key true)
    :right (tset player.keys key true)
    :up    (tset player.keys key true)
    :down  (tset player.keys key true))
  (player:moving))

(fn keyreleased [key scancode]
  (match key
    :left  (tset player.keys key false)
    :right (tset player.keys key false)
    :up    (tset player.keys key false)
    :down  (tset player.keys key false))
  (player:moving))

(fn mousemoved [x y dx dy istouch]
  (let [(tx ty) (transform:inverseTransformPoint x y)]
    (set player.mx tx)
    (set player.my ty)))

(fn mousepressed [x y button istouch presses]
  (let [(tx ty) (transform:inverseTransformPoint x y)]
    (set player.attack player.duration)))

{: load : draw : update : keypressed : keyreleased : mousemoved : mousepressed}
