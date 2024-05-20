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
  (set self.keys {})
  (set self.dir [])
  (set self.sx 0)
  (set self.sy 0)
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
(var pc nil)
(var universe nil)
(var quantum nil)
(var shader nil)
(local sphere "
uniform float fx = -1.1; // -1.0 is BARREL, 0.1 is PINCUSHION. For planets, ideally -1.1 to -4.
uniform float fx_scale = 1.1; // Play with this to slightly vary the results.
uniform bool dynamic_crop = false; // Guesses the crop amount with an admittedly badly inaccurate formula.
uniform bool manual_crop = true; // Cut out the junk outside the sphere.
uniform float manual_amount = 0.95; // Higher value = more crop.
vec2 distort(vec2 p) {
  float d = length(p);
  float z = sqrt(1.0 + d * d * fx);
  float r = atan(d, z) / 3.14159;
  r *= fx_scale;
  float phi = atan(p.y, p.x);
  return vec2(r*cos(phi)+.5,r*sin(phi)+.5);
}
vec4 effect( vec4 COLOR, Image TEXTURE, vec2 texture_coords, vec2 screen_coords ) {
  vec2 xy = (2.0 * texture_coords);
  xy.x = xy.x - 1.0;
  xy.y = xy.y - 1.0;
  // Dynamic crop adjustment. -0.5 is equavalent to 'none'.
  float d_adjust = -0.5;
  if (dynamic_crop) {
    d_adjust = (fx/4.0) * -0.6;
  }
  // Perform distortion if needed.
  vec4 tex;
  float d = length(xy);
  if (d < 1.0 - d_adjust) {
    xy = distort(xy);
    tex = Texel(TEXTURE, xy);
    COLOR = tex;
  }
  else {
    COLOR.a = 0.0;
  }
  // Apply manual crop.
  if (manual_crop && d > manual_amount) {
    COLOR.a = 0.0;
  }
  return COLOR;
}")

(fn load [w h] 
  (set pc (Player (/ w 2) (/ h 2)))
  (set universe (love.graphics.newCanvas w w))
  (set quantum (love.graphics.newCanvas w w))
  (set shader (love.graphics.newShader sphere)))

(fn board [w h] 
  (love.graphics.clear 1 0 1 1)
  (for [j 0 15] (for [i 0 15]
    (if (= (% (+ i j) 2) 0) 
        (love.graphics.setColor 0.5 0.25 0.125 1)
        (love.graphics.setColor 0.25 0.125 0 1))
    (love.graphics.rectangle "fill" (* j 64) (* (- i (/ (- 16 9) 2)) 64) 64 64)))
  (love.graphics.setColor 1 1 1 1)
  ;(love.graphics.rectangle "line" 0 (/ (- h w) 2) w w))
  )
(fn player [w h]
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.draw pc.i pc.x pc.y pc.angle 1 1 pc.ox pc.oy))
(fn hud [w h]
  (love.graphics.setColor 1 0.25 0.5 1)
  (let [stdarc  (math.max pc.ox pc.oy)
        attack  (* (math.sin (/ (* pc.attack math.pi) pc.duration)) 25)
        (x y)   (love.graphics.inverseTransformPoint pc.sx pc.sy)
        t       (/ (- w h) 2) ;; FIXME shader transform not in inverse point
        aim     (- (math.atan2 (- x pc.x) (- pc.y y t)) (/ math.pi 2))
        arca    (- aim (/ math.pi 4))
        arcb    (+ aim (/ math.pi 4))]
    (if (> pc.attack 0)
      (love.graphics.arc "fill" "open" pc.x pc.y (+ stdarc attack) arca arcb)
      (love.graphics.arc "line" "open" pc.x pc.y stdarc arca arcb)))
  (love.graphics.setColor 1 1 1 1))
(fn flat [w h supercanvas]
  (love.graphics.setCanvas universe)
  (love.graphics.push)
  (love.graphics.translate 0 (/ (- w h) 2))
  (board w h)
  (love.graphics.pop)
  (love.graphics.setCanvas supercanvas)
  (love.graphics.clear 0 0 0 1)
  (let [boardx (- (/ w 2) pc.x)
        boardy (- (/ h 2) pc.y)
        characterx boardx
        charactery (+ boardy (/ (* (- 16 9) 64) 2))]
    (love.graphics.push)
    (love.graphics.translate boardx boardy)
    (love.graphics.draw universe (* -1 w)   (* -1 w)    0 1 1)
    (love.graphics.draw universe 0          (* -1 w)    0 1 1)
    (love.graphics.draw universe w          (* -1 w)    0 1 1)
    (love.graphics.draw universe (* -1 w)   0           0 1 1)
    (love.graphics.draw universe 0          0           0 1 1)
    (love.graphics.draw universe w          0           0 1 1)
    (love.graphics.draw universe (* -1 w)   w           0 1 1)
    (love.graphics.draw universe 0          w           0 1 1)
    (love.graphics.draw universe w          w           0 1 1)
    (love.graphics.pop)
    (love.graphics.push)
    (love.graphics.translate characterx charactery)
    (player w h)
    (hud w h)
    (love.graphics.pop)))
(fn draw [w h supercanvas] (fn []
  (love.graphics.setCanvas quantum)
  (flat w h quantum)
  (love.graphics.setCanvas supercanvas)
  (love.graphics.clear 0.1 0 0.2 1)
  (love.graphics.setShader shader)
  (love.graphics.push)
  (love.graphics.translate 0 (/ (- h w) 2))
  (love.graphics.draw quantum 0 0 0 1 1)
  (love.graphics.pop)
  (love.graphics.setShader)
  (love.graphics.setColor 0.9 0.7 0.8 1)
  (love.graphics.printf "RoChamBULLET" 0 0 w :center)
  (love.graphics.setColor 1 1 1 1)))

(fn update [dt w h]
  (when (> (length pc.dir) 0)
    (incf pc.x (* (math.cos pc.angle) pc.speed dt))
    (incf pc.y (* (math.sin pc.angle) pc.speed dt))
    (set pc.x (% pc.x w))
    (set pc.y (- (% (+ pc.y (- (/ w 2) (/ h 2))) w) (- (/ w 2) (/ h 2)))))
  (when (> pc.attack 0) (decf pc.attack dt))
  (print (.. pc.x ", " pc.y)))

(fn keypressed [key scancode repeat?]
  (match key
    :left  (tset pc.keys key true)
    :right (tset pc.keys key true)
    :up    (tset pc.keys key true)
    :down  (tset pc.keys key true))
  (pc:moving))

(fn keyreleased [key scancode]
  (match key
    :left  (tset pc.keys key false)
    :right (tset pc.keys key false)
    :up    (tset pc.keys key false)
    :down  (tset pc.keys key false))
  (pc:moving))

(fn mousemoved [x y dx dy istouch]
  (set pc.sx x)
  (set pc.sy y))

(fn mousepressed [x y button istouch presses]
  (set pc.attack pc.duration))

{: load : draw : update : keypressed : keyreleased : mousemoved : mousepressed}
