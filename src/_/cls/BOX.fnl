(local Object (require :lib.classic))
(local BOX (Object:extend))

(fn BOX.box [!] (values ;; TODO avoid (- 1 !.w/h) ?
  (* !.absw (- 1 !.w) !.x) (* !.absh (- 1 !.h) !.y)
  (+ (* !.absw (- 1 !.w) !.x) (* !.absw !.w))
  (+ (* !.absh (- 1 !.h) !.y) (* !.absh !.h))))

(fn BOX.in? [! x y] (let [(left top right bot) (!:box)]
  (and (> x left) (< x right) (> y top) (< y bot))))

(fn BOX.refresh [!] (when !.parent (let [(x y _ _) (!:box)]
  (!.t:setTransformation x y 0 !.w !.h))))

(fn BOX.new [! p x y w h]
  (let [(ww wh)   (love.window.getMode)
        (x y)     (if (and x y) (values x y) (values 0 0))
        (w h)     (if (and w h) (values w h) (values ww wh))
        (pw ph)   (if p (values p.absw p.absh) (values w h))]
    (set (!.x !.y !.w !.h)          (values x y w h))
    (set (!.ow !.oh !.absw !.absh)  (values w h pw ph))
    (set !.t (love.math.newTransform)) (set !.parent p))
  (!:refresh))

(fn BOX.draw [! line?]
  (local (w h) (values !.absw !.absh))
  (love.graphics.applyTransform !.t)
  (love.graphics.rectangle :fill 0 0 w h)
  (love.graphics.setColor 0 0 0 1)
  (when line? (love.graphics.rectangle :line 0 0 w h))
  (love.graphics.setColor 1 1 1 1))

(fn BOX.repose [! idx idy] ;; TODO give dx/dy
  (let [(dx dy)   (values (* idx !.w) (* idy !.h))
        (x y _ _) (!:box)]
    (when (< !.w 1) (set !.x (/ (+ x dx) (- 1 !.w) !.absw)))
    (when (< !.h 1) (set !.y (/ (+ y dy) (- 1 !.h) !.absh))))
  (!:refresh))

(fn BOX.reshape [! idx idy] ;; TODO give dx/dy
  (let [(dx dy) (values (* idx !.w) (* idy !.h))]
    (set !.w (+ !.w (/ dx !.absw)))
    (set !.h (+ !.h (/ dy !.absh)))
    (when (not (and (= !.w 1) (= !.h 1)))
          (set (!.ow !.oh) (values !.w !.h))))
  (!:refresh))

(fn BOX.restore [!]
  (if (and (>= !.w 1) (>= !.h 1))
      (set (!.x !.y !.w !.h) (values !.x !.y !.ow !.oh))
      (set (!.x !.y !.w !.h) (values 0 0 1 1)))
  (!:refresh))

(fn BOX.itp [! x y ...]
  (let [(ix iy) (!.t:inverseTransformPoint x y)]
    (values ix iy ...)))
;; TODO more pattern match/reduce
(fn BOX.mousepressed [! x y ...] (!:itp x y ...))
(fn BOX.mousereleased [! x y ...] (!:itp x y ...))
(fn BOX.mousemoved [! x y dx dy ...]
  (!:itp x y (/ dx !.w) (/ dy !.h) ...))

BOX
