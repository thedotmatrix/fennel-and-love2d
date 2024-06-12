(local Object (require :lib.classic))
(local BOX (Object:extend))

(fn BOX.abs [! d] 
  (if !.parent (!.parent:abs d) (. ! d)))

(fn BOX.box [!] 
  (values 
    (* (!:abs :w) (- 1 !.w) !.x)
    (* (!:abs :h) (- 1 !.h) !.y) ;; TODO why not !.w?
    (+ (* (!:abs :w) (- 1 !.w) !.x) (* (!:abs :w) 1))
    (+ (* (!:abs :h) (- 1 !.h) !.y) (* (!:abs :h) !.h))))

(fn BOX.refresh [!]
  (when !.parent (let [(x y _ _) (!:box)]
    (!.transform:setTransformation x y 0 !.w !.h))))

(fn BOX.in? [! x y]
  (let [(l u r d) (!:box)]
    (and (> x l) (< x r) (> y u) (< y d))))

(fn BOX.new [! x y w h parent]
  (let [(x y)   (if (and x y) (values x y) (values 0 0))
        (ww wh) (love.window.getMode)
        (w h)   (if (and w h) (values w h) (values ww wh))]
    (set !.x x) (set !.y y) (set !.w w) (set !.h h))
  (set !.parent parent)
  (set !.transform (love.math.newTransform))
  (!:refresh))

(fn BOX.draw [!]
  (love.graphics.applyTransform !.transform)
  (let [ x 0         y 0        w (!:abs :w)  h (!:abs :h)
        lx (+ x 1)  ly (+ y 1) lw (- w 2)    lh (- h 2)]
    (love.graphics.rectangle :fill x y w h)
    (love.graphics.setColor 0 0 0 1)
    (love.graphics.rectangle :line lx ly lw lh)
    (love.graphics.setColor 1 1 1 1)))

(fn BOX.mousepressed [! x y ...]
  (let [(tx ty) (!.transform:inverseTransformPoint x y)]
    (values tx ty ...)))

(fn BOX.mousereleased [! x y ...]
  (let [(tx ty) (!.transform:inverseTransformPoint x y)]
    (values tx ty ...)))

(fn BOX.mousemoved [! x y dx dy ...]
  (let [(ix iy)   (!.transform:inverseTransformPoint x y)
        (idx idy) (!.transform:inverseTransformPoint dx dy)]
    (values ix iy idx idy ...)))

BOX
