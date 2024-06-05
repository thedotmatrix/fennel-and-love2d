(local Object (require :lib.classic))
(local MAT (Object:extend))
(local ts [:trans :scale :centr :t])
(local sett (fn [t ...] (t:setTransformation ...)))

(fn MAT.refresh [!]
  (!.t:reset)
  ; (love.graphics.applyTransform parenttransform.trans)
  ; (love.graphics.applyTransform transform.trans)
  ; (love.graphics.applyTransform parenttransform.scale)
  ; (love.graphics.applyTransform parenttransform.centr)
  ; (love.graphics.applyTransform transform.scale)
  ; (love.graphics.applyTransform transform.centr)
  (for [i 1 (- (length ts) 1)] (!.t:apply (. ! (. ts i)))))

(fn MAT.rearrange [! x y]
  (local (w h) (values (- !.parentw !.sw) (- !.parenth !.sh)))
  (set !.x x) (set !.y y)
  (sett !.trans x y 0 1 1 0 0 0 0)
  (!:refresh))

(fn MAT.resize [! w h]
  (set !.sw w) (set !.sh h)
  (set !.s (math.min (/ !.sw !.w) (/ !.sh !.h)))
  (sett !.scale 0 0 0 !.s !.s 0 0 0 0)
  (set !.cx  (/ (- (/ !.sw !.s) !.w) 2))
  (set !.cy  (/ (- (/ !.sh !.s) !.h) 2))
  (sett !.centr !.cx !.cy 0 1 1 0 0 0 0)
  (!:refresh))

(fn MAT.restore [! mx my]
  (let [max?      (and (= !.sw !.parentw) (= !.sh !.parenth))
        cmx       (- mx (/ !.w 2))
        (x y w h) (if max?  (values cmx my !.w !.h)
                            (values 0 0 !.parentw !.parenth))]
    (!:resize w h)
    (!:rearrange x y)))

(fn MAT.new [! parentw parenth x y w h]
  (set !.parentw parentw) (set !.parenth parenth)
  (set !.w w)             (set !.h h)
  (each [_ t (ipairs ts)] (tset ! t (love.math.newTransform)))
  (!:resize w h)
  (!:rearrange x y)
  (!:refresh))

(fn MAT.mousepressed [! top? bot? x y button touch? presses]
  (let [(tx ty) (!.t:inverseTransformPoint x y)]
    (when (or top? bot?) (set !.drag? true))
    (when (and top? (= presses 2)) (!:restore x y))
    (values tx ty button touch? presses)))

(fn MAT.mousereleased [! x y ...]
  (let [(tx ty) (!.t:inverseTransformPoint x y)]
    (set !.drag? false) (set !.top? false) (set !.bot? false)
    (values tx ty ...)))

(fn MAT.mousemoved [! top? bot? x y dx dy ...]
  (let [(tx ty)   (!.t:inverseTransformPoint x y)
        (tdx tdy) (!.scale:inverseTransformPoint dx dy)
        (xdx ydy) (values (+ !.x dx) (+ !.y dy))
        (wdx hdy) (values (+ !.sw dx) (+ !.sh dy))]
    (when (and top? (not !.bot?)) (set !.top? true))
    (when (and bot? (not !.top?)) (set !.bot? true))
    (when (and !.top? !.drag?) (!:rearrange xdx ydy))
    (when (and !.bot? !.drag?) (!:resize wdx hdy))
    (when (and !.top? (not !.drag?)) (set !.top? false))
    (when (and !.bot? (not !.drag?)) (set !.bot? false))
    (values tx ty tdx tdy ...)))

MAT
