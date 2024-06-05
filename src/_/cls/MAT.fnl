(local Object (require :lib.classic))
(local MAT (Object:extend))
(local ts [:trans :scale :centr :t])
(local sett (fn [t ...] (t:setTransformation ...)))

(fn MAT.refresh [!]
  (!.t:reset)
  (for [i 1 (- (length ts) 1)] (!.t:apply (. ! (. ts i)))))

(fn MAT.rearrange [! x y]
  (local (w h) (values (- !.ww !.w) (- !.wh !.h)))
  (when (not (or (< x 0) (> x w) (< y 0) (> y h)))
    (set !.x x) (set !.y y)
    (sett !.trans x y 0 1 1 0 0 0 0)
    (!:refresh)))

(fn MAT.resize [! w h] (when (and (> w 0) (> h 0)) (do
  (set !.w w) (set !.h h)
  (set !.s (math.min (/ !.w !.ow) (/ !.h !.oh)))
  (sett !.scale 0 0 0 !.s !.s 0 0 0 0)
  (set !.cx  (/ (- (/ !.w !.s) !.ow) 2))
  (set !.cy  (/ (- (/ !.h !.s) !.oh) 2))
  (sett !.centr !.cx !.cy 0 1 1 0 0 0 0)
  (!:refresh))))

(fn MAT.restore [! mx my]
  (let [max?      (and (= !.w !.ww) (= !.h !.wh))
        cmx       (- mx (/ !.ow 2))
        (x y w h) (if max?  (values cmx my !.ow !.oh)
                            (values 0 0 !.ww !.wh ))]
    (!:resize w h)
    (!:rearrange x y)))

(fn MAT.new [! ww wh x y w h]
  (set !.ww ww)    (set !.wh wh)
  (set !.ow w)     (set !.oh h)
  (each [_ t (ipairs ts)] (tset ! t (love.math.newTransform)))
  (!:resize w h)
  (!:rearrange x y))

(fn MAT.mousepressed [! top bot x y button touch? presses]
  (let [(tx ty) (!.t:inverseTransformPoint x y)]
    (when (or top bot) (set !.drag? true))
    (when (and top (= presses 2)) (!:restore x y))
    (values tx ty button touch? presses)))

(fn MAT.mousereleased [! x y ...]
  (let [(tx ty) (!.t:inverseTransformPoint x y)]
    (set !.drag? false) (set !.top? false) (set !.bot? false)
    (values tx ty ...)))

(fn MAT.mousemoved [! top? bot? x y dx dy ...]
  (let [(tx ty)   (!.t:inverseTransformPoint x y)
        (tdx tdy) (!.scale:inverseTransformPoint dx dy)
        (xdx ydy) (values (+ !.x dx) (+ !.y dy))
        (wdx hdy) (values (+ !.w dx) (+ !.h dy))]
    (when (and top? (not !.bot?)) (set !.top? true))
    (when (and bot? (not !.top?)) (set !.bot? true))
    (when (and !.top? !.drag?) (!:rearrange xdx ydy))
    (when (and !.bot? !.drag?) (!:resize wdx hdy))
    (values tx ty tdx tdy ...)))

MAT
