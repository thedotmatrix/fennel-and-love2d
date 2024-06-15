(import-macros {: incf} :mac.math)
(local Object (require :lib.classic))
(local BOX (Object:extend))

(fn BOX.box [!] 
  (values
    (* !.aw (- 1 !.w) !.x) (* !.ah (- 1 !.h) !.y)
    (+ (* !.aw (- 1 !.w) !.x) (* !.aw !.w))
    (+ (* !.ah (- 1 !.h) !.y) (* !.ah !.h))))

(fn BOX.in? [! x y] 
  (let [(left top right bot) (!:box)]
    (and (> x left) (< x right) (> y top) (< y bot))))

(fn BOX.refresh [!] (if !.parent
  (let [(x y) (!:box)] (!.t:setTransformation x y 0 !.w !.h))
  (!.t:setTransformation 0 0 0 (/ !.w !.ow) (/ !.h !.oh))))

(fn BOX.new [! p x y w h]
  (set [!.x !.y !.w !.h !.ow !.oh] [x y w h w h p])
  (set [!.parent !.aw !.ah] [p w h])
  (when p (set [!.aw !.ah] [p.aw p.ah]))
  (set !.t (love.math.newTransform)) (!:refresh))

(fn BOX.draw [! l?]
  (when (not l?) (love.graphics.push))
  (love.graphics.applyTransform !.t)
  (love.graphics.rectangle :fill 0 0 !.aw !.ah)
  (love.graphics.setColor 0 0 0 1)
  (when l? (love.graphics.rectangle :line 0 0 !.aw !.ah))
  (when (not l?) (love.graphics.pop)))

(fn BOX.repose [! idx idy]
  (when (< !.w 1) (incf !.x (/ (* idx !.w) (- 1 !.w) !.aw)))
  (when (< !.h 1) (incf !.y (/ (* idy !.h) (- 1 !.h) !.ah)))
  (!:refresh))

(fn BOX.reshape [! idx idy]
  (incf !.w (/ (* idx !.w) !.aw))
  (incf !.h (/ (* idy !.h) !.ah))
  (when (~= [!.w !.h] [1 1]) (set [!.ow !.oh] [!.w !.h]))
  (!:refresh))

(fn BOX.restore [! maxw maxh]
  (if (and (>= !.w maxw) (>= !.h maxh))
      (set [!.x !.y !.w !.h] [!.x !.y !.ow !.oh])
      (set [!.x !.y !.w !.h] [0 0 maxw maxh]))
  (!:refresh))

(fn BOX.itp [! x y ...]
  (let [(ix iy) (!.t:inverseTransformPoint x y)]
    (values ix iy ...)))

(fn BOX.mousepressed [! x y ...] (!:itp x y ...))

(fn BOX.mousereleased [! x y ...] (!:itp x y ...))

(fn BOX.mousemoved [! x y dx dy ...]
  (!:itp x y (/ dx !.w) (/ dy !.h) ...))

BOX
