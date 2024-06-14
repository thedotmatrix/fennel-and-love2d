(local Object (require :lib.classic))
(local WIN (Object:extend))
(local BOX (require :src._.cls.BOX))

(fn WIN.new [! parent w h]
  (set !.border [0.4 0.4 0.4])
  (set !.fill   [0.2 0.2 0.2])
  (set !.outer (BOX parent.inner 0 0 w h))
  (set !.top   (BOX !.outer 0 0 1 0.05))
  (set !.bot   (BOX !.outer 0 1 1 0.05))
  (set !.inner (BOX !.outer 0.5 0.5 0.99 0.90))
  (set !.depth (+ parent.depth 1))
  (set parent.child !))

(fn WIN.draw [!]
  (love.graphics.push)
  (love.graphics.setColor !.border)
  (!.outer:draw true)
  (love.graphics.setColor !.fill)
  (love.graphics.push) (!.inner:draw true) (love.graphics.pop)
  (love.graphics.stencil #(!.inner:draw) :increment 1 true)
  (love.graphics.setStencilTest :greater !.depth)
  (love.graphics.setColor 1 1 1 1)
  (when !.child (!.child:draw))
  (love.graphics.setStencilTest)
  (love.graphics.pop))

(fn WIN.update [! dt] (when !.child (!.child:update dt)))

(fn WIN.mousepressed [! x y button touch? presses]
  (set !.drag? (or (!.top:in? x y) (!.bot:in? x y)))
  (if (and (!.top:in? x y) (= presses 2))
      (do (!.outer:restore) false) true))

(fn WIN.mousereleased [! x y ...] 
  (set !.drag? false) (set !.top? false) (set !.bot? false)
  true)

(fn WIN.mousemoved [! x y dx dy ...]
  (if (or (!.top:in? x y) (!.bot:in? x y))
      (set !.border [0.6 0.6 0.6])
      (set !.border [0.4 0.4 0.4]))
  (when (and (!.top:in? x y) (not !.bot?)) (set !.top? true))
  (when (and (!.bot:in? x y) (not !.top?)) (set !.bot? true))
  (when (and !.top? (not !.drag?)) (set !.top? false))
  (when (and !.bot? (not !.drag?)) (set !.bot? false))
  (when (and !.top? !.drag?) (!.outer:repose dx dy))
  (when (and !.bot? !.drag?) (!.outer:reshape dx dy))
  (not (or !.top? !.bot? !.drag?)))

(fn WIN.event [! e ...]
  (when (and (= e :keypressed) (= ... :escape)) 
        (love.event.quit)) ;; TODO close windows then quit
    (let [in    #((. !.inner e) !.inner $...)
          out   #((. !.outer e) !.outer $...)
          apply #(in (out $...))
          trans (if (. BOX e) apply #$)
          go?   (if (. ! e) ((. ! e) ! (out ...)) true)]
      (when (and go? !.child) (!.child:event e (trans ...)))))

WIN
