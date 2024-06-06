(local Object (require :lib.classic))
(local MAT (Object:extend))
(local ts [:trans :scale :t])
(local sett (fn [t ...] (t:setTransformation ...)))

(fn MAT.refresh [!]
  (!.t:reset)
  (for [i 1 (- (length ts) 1)] (!.t:apply (. ! (. ts i)))))

(fn MAT.repose [! x y]
  (set !.x x) (set !.y y)
  (sett !.trans !.x !.y 0 1 1 0 0 0 0)
  (!:refresh))

(fn MAT.resize [! w h] (when (and w h)
  (set !.sw w) (set !.sh h)
  (set !.s (math.min (/ !.sw !.w) (/ !.sh !.h)))
  (sett !.scale 0 0 0 !.s !.s 0 0 0 0)
  (!:refresh)))

(fn MAT.restore [! mx my]
  (let [maxw  (/ !.parent.sw !.parent.s)
        maxh  (/ !.parent.sh !.parent.s)
        max?  (and (>= !.sw maxw) (>= !.sh maxh))
        cmx   (- mx (/ !.w 2))
        (x y) (if max? (values cmx my) (values 0 0))
        (w h) (if max? (values !.w !.h) (values maxw maxh))]
    (!:repose x y)
    (!:resize w h)))

(fn MAT.new [! parent x y w h]
  (set !.parent parent) (set !.w w) (set !.h h)
  (each [_ t (ipairs ts)] (tset ! t (love.math.newTransform)))
  (!:repose x y)
  (!:resize w h)
  (!:refresh))

(fn MAT.mousepressed [! top? bot? x y button touch? presses]
  (let [(tx ty) (!.t:inverseTransformPoint x y)]
    (when (or top? bot?) (set !.drag? true))
    (if (and top? (= presses 2))
      (do (!:restore x y) (values tx ty nil false 0))
      (values tx ty button touch? presses))))

(fn MAT.mousereleased [! x y ...]
  (let [(tx ty) (!.t:inverseTransformPoint x y)]
    (set !.drag? false) (set !.top? false) (set !.bot? false)
    (values tx ty ...)))

(fn MAT.mousemoved [! top? bot? x y dx dy ...]
  (let [(ix iy)   (!.t:inverseTransformPoint x y)
        (idx idy) (!.scale:inverseTransformPoint dx dy)
        (tx ty) (values (+ !.x idx) (+ !.y idy))
        (sw sh) (values (+ !.sw idx) (+ !.sh idy))]
    (when (and top? (not !.bot?)) (set !.top? true))
    (when (and bot? (not !.top?)) (set !.bot? true))
    (when (and !.top? (not !.drag?)) (set !.top? false))
    (when (and !.bot? (not !.drag?)) (set !.bot? false))
    ;; TODO block children from also repose/resize
    (when (and !.top? !.drag?) (!:repose tx ty))
    (when (and !.bot? !.drag?) (!:resize sw sh))
    (values ix iy idx idy ...)))

MAT
