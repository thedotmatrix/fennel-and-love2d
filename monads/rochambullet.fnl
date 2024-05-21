(import-macros {: incf : decf : clamp} :macros.math)
(local lume (require "lib.lume"))
(local Object (require "lib.classic"))
(local Character (Object:extend))
(tset Character :new (fn [self x y]
  (set self.x x)
  (set self.y y)
  (set self.speed 256)
  (set self.angle 0)))
(local Player (Character:extend))
(tset Player :new (fn [self x y]
  (Player.super:new x y)
  (set self.i (love.graphics.newImage "bin/howtolove/arrow_right.png"))
  (set self.ox (/ (self.i:getWidth) 2))
  (set self.oy (/ (self.i:getHeight) 2))
  (set self.scale 0.5)
  (set self.keys {})
  (set self.dir [])
  (set self.mx 0)
  (set self.my 0)
  (set self.attack 0)
  (set self.duration (/ 1 8))))
(tset Player :moving (fn [self]
  (set self.dir [])
  (when (and self.keys.down (not self.keys.up)) (table.insert self.dir :s))
  (when (and self.keys.up (not self.keys.down)) (table.insert self.dir :n))
  (when (and self.keys.left (not self.keys.right)) (table.insert self.dir :w))
  (when (and self.keys.right (not self.keys.left)) (table.insert self.dir :e))
  (match self.dir
    [:s :w]  (set self.angle (* math.pi 0.75))
    [:n :w]  (set self.angle (* math.pi 1.25))
    [:s :e]  (set self.angle (* math.pi 0.25))
    [:n :e]  (set self.angle (* math.pi 1.75))
    [:w]     (set self.angle (* math.pi 1.00))
    [:e]     (set self.angle (* math.pi 0.00))
    [:s]     (set self.angle (* math.pi 0.50))
    [:n]     (set self.angle (* math.pi 1.50))
    )))
(tset Player :draw (fn [pc w h]
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.draw pc.i pc.x pc.y pc.angle pc.scale pc.scale pc.ox pc.oy)
  (love.graphics.setColor 1 0.25 0.5 1)
  (let [stdarc  (* (math.max pc.ox pc.oy) pc.scale)
        attack  (* (math.sin (/ (* pc.attack math.pi) pc.duration)) 25) 
        aim     (- (math.atan2 (- pc.mx pc.x) (- pc.y pc.my)) (/ math.pi 2))
        arca    (- aim (/ math.pi 4))
        arcb    (+ aim (/ math.pi 4))]
    (if (> pc.attack 0)
      (love.graphics.arc "fill" "open" pc.x pc.y (+ stdarc attack) arca arcb)
      (love.graphics.arc "line" "open" pc.x pc.y stdarc arca arcb)))
  (love.graphics.setColor 1 1 1 1)))
(var player nil)
(local board {:tiles 32 :tilepx 32})
(tset board :px (* board.tiles board.tilepx))
(fn drawBoard [x y]
  (love.graphics.push)
  (love.graphics.translate (- x (/ board.px 2)) (- y (/ board.px 2)))
  (for [j 0 (- board.tiles 1)] (for [i 0 (- board.tiles 1)]
    (if (= (% (+ i j) 2) 0) 
        (love.graphics.setColor 0.5 0.25 0.125 1)
        (love.graphics.setColor 0.25 0.125 0 1))
    (love.graphics.rectangle "fill" (* j board.tilepx)  (* i board.tilepx)
                                    board.tilepx        board.tilepx)))
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.rectangle "line" 0 0 board.px board.px)
  (love.graphics.pop))
(fn drawBoards [] 
  (drawBoard (* board.px -1)  (* board.px -1))
  (drawBoard (* board.px 0)   (* board.px -1))
  (drawBoard (* board.px 1)   (* board.px -1))
  (drawBoard (* board.px -1)  (* board.px 0))
  (drawBoard (* board.px 0)   (* board.px 0))
  (drawBoard (* board.px 1)   (* board.px 0))
  (drawBoard (* board.px -1)  (* board.px 1))
  (drawBoard (* board.px 0)   (* board.px 1))
  (drawBoard (* board.px 1)   (* board.px 1)))
(local transform (love.math.newTransform))
(fn updateTransform [w h]
  (let [tx (- (/ w 2) player.x)
        ty (- (/ h 2) player.y)
        (mx my) (love.mouse.getPosition)]
    (transform:setTransformation tx ty 0 1 1 0 0 0 0)
    (love.mousemoved mx my 0 0 false)))
(var canvas nil)
(var shader nil)
(local fov (/ -1 8)) ;; -1 (black hole) - 0 (regular sphere) - 1 (basically flat)
(local centercanvas (love.math.newTransform))

(fn load [w h]
  (set player (Player 0 0))
  (updateTransform w h)
  (set shader (love.graphics.newShader "bin/sphere.glsl"))
  (let [csize (* w (+ fov 1.0))]
    (set canvas (love.graphics.newCanvas csize csize)))
  (let [tx (/ (- (canvas:getWidth) w) 2)
        ty (/ (- (canvas:getHeight) h) 2)]
    (centercanvas:setTransformation tx ty 0 1 1 0 0 0 0)))

(fn draw [w h supercanvas] (fn []
  (love.graphics.setCanvas canvas)
  (love.graphics.push)
  (love.graphics.applyTransform transform)
  (love.graphics.applyTransform centercanvas)
  (drawBoards)
  (player:draw w h)
  (love.graphics.pop)
  (love.graphics.setCanvas supercanvas)
  (love.graphics.setShader shader) ;FIXME shader code, no magic numbers here!
  (love.graphics.push)
  (love.graphics.applyTransform (centercanvas:inverse))
  (love.graphics.clear 0.1 0 0.2 1)
  (love.graphics.draw canvas)
  (love.graphics.pop)
  (love.graphics.setShader)))

(fn update [dt w h]
  (when (> (length player.dir) 0)
    (incf player.x (* (math.cos player.angle) player.speed dt))
    (incf player.y (* (math.sin player.angle) player.speed dt))
    (print (.. player.x ", " player.y))
    (updateTransform w h)
    (set player.x (- (% (+ player.x (/ board.px 2)) board.px) (/ board.px 2)))
    (set player.y (- (% (+ player.y (/ board.px 2)) board.px) (/ board.px 2))))
  (when (> player.attack 0) (decf player.attack dt)))

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
