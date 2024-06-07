(local Object (require :lib.classic))
(local MAT (Object:extend))
(local ts [:trans :scale :t])
(local sett (fn [t ...] (t:setTransformation ...)))

(fn MAT.border [! recur?] ;; TODO should be in window
  (local b (/ (math.max !.w !.h) 64))
  (if (not (and recur? !.parent)) 
                b   (+ b (!.parent:border recur?))))

(fn MAT.refresh [!] (!.t:reset)
  (for [i 1 (- (length ts) 1)] (!.t:apply (. ! (. ts i)))))

(fn MAT.repose [! tx ty]
  (set (!.x !.y) (values tx ty))
  (sett !.trans !.x !.y 0 1 1 0 0 0 0)
  (!:refresh))

(fn MAT.rescale [! sw sh] (when (and sw sh)
  (set (!.sw !.sh) (values sw sh))
  (set !.s (math.min (/ !.sw !.w) (/ !.sh !.h)))
  (sett !.scale 0 0 0 !.s !.s 0 0 0 0)
  (!:refresh)))

(fn MAT.restore [!]
  ;; TODO get parent out of matrix
  (let [maxw  (-  (/ !.parent.sw !.parent.s) 2)
        maxh  (-  (/ !.parent.sh !.parent.s) 
                  (* 2 (!.parent:border false)))
        max?  (and (>= !.sw maxw) (>= !.sh maxh))
        (x y) (values 1 (!.parent:border false))
        (w h) (if max? (values !.w !.h) (values maxw maxh))]
    (!:repose x y) 
    (!:rescale w h)))

(fn MAT.new [! parent x y w h]
  (set !.parent parent)
  (set (!.w !.h) (values w h))
  (each [_ t (ipairs ts)] (tset ! t (love.math.newTransform)))
  (!:repose x y)
  (!:rescale !.w !.h)
  (!:refresh))

(fn MAT.mousepressed [! top? bot? x y button touch? presses]
  (let [(tx ty) (!.t:inverseTransformPoint x y)]
    (when (or top? bot?) (set !.drag? true))
    (if (and top? (= presses 2))
      (do (!:restore) (values tx ty nil false 0))
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
    (when (and !.top? !.drag?) (!:repose tx ty idx idy))
    (when (and !.bot? !.drag?) (!:rescale sw sh))
    (values ix iy idx idy ...)))

MAT
