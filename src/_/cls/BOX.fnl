(local Object (require :lib.classic))
(local BOX (Object:extend))

(fn BOX.abs [! d] (if !.parent (!.parent:abs d) (. ! d)))
(fn BOX.box [!] (values 
  (* (!:abs :w) (- 1 !.w) !.x)
  (* (!:abs :h) (- 1 !.h) !.y)
  (+ (* (!:abs :w) (- 1 !.w) !.x) (* (!:abs :w) !.w))
  (+ (* (!:abs :h) (- 1 !.h) !.y) (* (!:abs :h) !.h))))
(fn BOX.in? [! x y] (let [(left top right bot) (!:box)]
  (and (> x left) (< x right) (> y top) (< y bot))))
(fn BOX.refresh [!] (when !.parent (let [(x y _ _) (!:box)]
    (!.transform:setTransformation x y 0 !.w !.h))))

(fn BOX.repose [! idx idy]
  (let [(dx dy)   (values (* idx !.w) (* idy !.h))
        (x y _ _) (!:box)
        absw      (* (- 1 !.w) (!:abs :w))
        absh      (* (- 1 !.h) (!:abs :h))]
    (when (< !.w 1) (set !.x (/ (+ x dx) absw)))
    (when (< !.h 1) (set !.y (/ (+ y dy) absh))))
  (!:refresh))
(fn BOX.reshape [! idx idy]
  (let [(dx dy) (values (* idx !.w) (* idy !.h))]
    (set !.w (+ !.w (/ dx (!:abs :w))))
    (set !.h (+ !.h (/ dy (!:abs :h))))
    (when (not (and (= !.w 1) (= !.h 1)))
          (set (!.ow !.oh) (values !.w !.h))))
  (!:refresh))
(fn BOX.restore [!]
  (if (and (>= !.w 1) (>= !.h 1))
      (set (!.x !.y !.w !.h) (values !.x !.y !.ow !.oh))
      (set (!.x !.y !.w !.h) (values 0 0 1 1)))
  (!:refresh))

(fn BOX.new [! parent x y w h]
  (let [(ww wh)   (love.window.getMode)
        (x y)     (if (and x y) (values x y) (values 0 0))
        (w h)     (if (and w h) (values w h) (values ww wh))]
    (set (!.x !.y !.w !.h !.ow !.oh) (values x y w h w h))
    (set !.transform (love.math.newTransform))
    (set !.parent parent))
  (!:refresh))
(fn BOX.draw [! line?]
  (local (w h) (values (!:abs :w) (!:abs :h)))
  (love.graphics.applyTransform !.transform)
  (love.graphics.rectangle :fill 0 0 w h)
  (love.graphics.setColor 0 0 0 1)
  (when line? (love.graphics.rectangle :line 0 0 w h))
  (love.graphics.setColor 1 1 1 1))

(fn BOX.mousepressed [! x y ...]
  (let [(tx ty) (!.transform:inverseTransformPoint x y)]
    (values tx ty ...)))
(fn BOX.mousereleased [! x y ...]
  (let [(tx ty) (!.transform:inverseTransformPoint x y)]
    (values tx ty ...)))
(fn BOX.mousemoved [! x y dx dy ...]
  (let [(ix iy)   (!.transform:inverseTransformPoint x y)
        (idx idy) (values (/ dx !.w) (/ dy !.h))]
    (values ix iy idx idy ...)))

BOX
