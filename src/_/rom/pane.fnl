(local BOX (require :src._.cls.BOX))
(local ROM (require :src._.cls.ROM))
(local Pane (ROM:extend))

(fn Pane.update [!! ! dt]
  (each [_ s (ipairs !.subs)] (s:update dt)))

;; TODO CAB/ROM anti-pattern?
(fn Pane.event [!! ! rom e ...]
  (let [in    #((. !.inner e) !.inner $...)
        out   #((. !.outer e) !.outer $...)
        apply #(in (out $...))
        trans (if (. BOX e) apply #$)
        go?   (if (. rom e) ((. rom e) !! ! (out ...)) true)]
    (when go? (each [_ s (ipairs !.subs)]
      (s:event e (trans ...))))))

(fn Pane.mousepressed [!! ! x y button touch? presses]
  (set !.drag? (or (!.top:in? x y) (!.bot:in? x y)))
  (if (and (!.top:in? x y) (= presses 2))
      (do (!.outer:restore 1 1) false) true))

(fn Pane.mousereleased [!! ! x y ...] 
  (set [!.drag? !.top? !.bot?] [false false false]) true)

(fn Pane.mousemoved [!! ! x y dx dy ...]
  (if (or (!.top:in? x y) (!.bot:in? x y true))
      (set !.border [0.6 0.6 0.6])
      (set !.border [0.4 0.4 0.4]))
  (when (and (!.top:in? x y) (not !.bot?)) (set !.top? true))
  (when (and (!.bot:in? x y) (not !.top?)) (set !.bot? true))
  (when (and !.top? (not !.drag?)) (set !.top? false))
  (when (and !.bot? (not !.drag?)) (set !.bot? false))
  (when (and !.top? !.drag?) (!.outer:repose dx dy))
  (when (and !.bot? !.drag?) (!.outer:reshape dx dy))
  (not (or !.top? !.bot? !.drag?)))

Pane
