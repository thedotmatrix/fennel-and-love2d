(import-macros {: decf : arctan} :mac.math)
(local Board (require "src.rochambullet.classes.board"))
(local board (Board 16 32))
(local Player (require "src.rochambullet.classes.player"))
(local player (Player 0 0))
(local Enemy (require "src.rochambullet.classes.enemy"))
(local enemies [])
(local transform (love.math.newTransform))
(fn updateTransform [w h]
  (let [tx (- (/ w 2) player.x)
        ty (- (/ h 2) player.y)
        (mx my) (love.mouse.getPosition)]
    (transform:setTransformation tx ty 0 1 1 0 0 0 0)
    (love.mousemoved mx my 0 0 false)))
(local shader (love.graphics.newShader "src/rochambullet/assets/sphere.glsl"))
(local fov (/ 1 16)) ;; -1 (black hole) - 0 (regular sphere) - 1 (almost flat)
(local centercanvas (love.math.newTransform))
(var canvas nil)

(fn load [w h]
  (let [csize (* w (+ fov 1.0))]
    (set canvas (love.graphics.newCanvas csize csize)))
  (let [tx    (/ (- (canvas:getWidth) w) 2)
        ty    (/ (- (canvas:getHeight) h) 2)]
    (centercanvas:setTransformation tx ty 0 1 1 0 0 0 0))
  (for [i 1 128] (table.insert enemies (Enemy board.px)))
  (updateTransform w h))

(fn draw [w h supercanvas] (fn []
  (love.graphics.setCanvas canvas)
  (love.graphics.push)
  (love.graphics.applyTransform transform)
  (love.graphics.applyTransform centercanvas)
  (board:draw* 0 0)
  (each [_ e (pairs enemies)] (e:draw* board.px))
  (player:draw)
  (love.graphics.pop)
  (love.graphics.setCanvas supercanvas)
  (love.graphics.setShader shader)
  (love.graphics.push)
  (love.graphics.applyTransform (centercanvas:inverse))
  (love.graphics.clear 0.25 0 0.25 1)
  (love.graphics.draw canvas)
  (love.graphics.pop)
  (love.graphics.setShader)))

(fn update [dt w h]
  ;; player
  (when (> (length player.dir) 0)
    (player:update dt board.px)
    ;(print (.. player.x ", " player.y))
    (updateTransform w h))
  (when (> player.attack 0) (decf player.attack dt))
  ;; enemies
  (var collision? false)
  (each [_ e (pairs enemies)] 
    (e:update dt board.px)
    ;; player collision
    (let [outer (player:collision? e.x e.y (* (+ player.size e.size) 2))
          inner (player:collision? e.x e.y (* (+ player.size e.size) 0.5))
          angle (arctan e.x e.y player.x player.y)]
      (when (and (~= player.threat 1) outer) (do
        (set player.threat 0)
        ;(print (.. angle "=" player.aim))
        (when (< (math.abs (- angle player.aim)) (/ math.pi 2))
          (do (player:attacking) (set e.angle player.aim)))
        (when inner (set player.threat 1))))
      (set collision? (or collision? outer inner))))
  (when (not collision?) (set player.threat -1))
  ;; enemy collision
  (local collided [])
  (for [i 1 (length enemies)] ;; FIXME spatial hashmap avoid polynomial checks
    (for [j 1 (length enemies)]
      (when (~= i j)
        (let [a (. enemies i)
              b (. enemies j)
              c (a:collision? b.x b.y (/ (+ a.size b.size) 2))]
          (when c (do
            (table.insert collided i)
            ;(print (.. "collide: "  (math.floor a.x) "=" (math.floor b.x) " " 
            ;                        (math.floor a.y) "=" (math.floor b.y)))
            ))))))
  (for [i (length collided) 1 -1]
    (table.remove enemies (. collided i))))

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
    (player:aiming tx ty)))

(fn mousepressed [x y button istouch presses]
  (let [(tx ty) (transform:inverseTransformPoint x y)]
    false))

{: load : draw : update : keypressed : keyreleased : mousemoved : mousepressed}