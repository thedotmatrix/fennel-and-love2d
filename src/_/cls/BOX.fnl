(local Object (require :lib.classic))
(local BOX (Object:extend))

(fn BOX.abs [! d] (if !.parent (!.parent:abs d) (. ! d)))

(fn BOX.refresh [!] 
  (when !.parent
    (let [x (* (!:abs :w) (- 1 !.w) !.x)
          y (* (!:abs :h) (- 1 !.h) !.y)]
      (!.transform:setTransformation x y 0 !.w !.h))))

(fn BOX.draw [!]
  (love.graphics.applyTransform !.transform)
  (when !.color (love.graphics.setColor !.color))
  (let [x 0 y 0 w (!:abs :w) h (!:abs :h)]
    (love.graphics.rectangle :fill x y w h))
  (love.graphics.setColor 0 0 0 1)
  (when !.mx (love.graphics.circle :fill !.mx !.my 4))
  (love.graphics.setColor 1 1 1 1)
  (when !.child (!.child:draw)))

(fn BOX.update [! dt])

(fn BOX.new [! x y w h parent color]
  (let [(x y)   (if (and x y) (values x y) (values 0 0))
        (ww wh) (love.window.getMode)
        (w h)   (if (and w h) (values w h) (values ww wh))]
    (set !.x x) (set !.y y) (set !.w w) (set !.h h))
  (set !.parent parent)
  (set !.color color)
  (set !.transform (love.math.newTransform))
  (!:refresh))

(fn BOX.event [! e ...] (match e
  :keypressed     (!:keypressed ...)
  :mousemoved     (!:mousemoved ...)))

(fn BOX.keypressed [! key ...] (match key
  :escape (love.event.quit)))

(fn BOX.mousemoved [! x y ...]
  (let [(ix iy)   (!.transform:inverseTransformPoint x y)]
    (set !.mx ix) (set !.my iy)
    (when !.child (!.child:mousemoved ix iy ...))))

BOX
