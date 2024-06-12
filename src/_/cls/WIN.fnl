(local Object (require :lib.classic))
(local WIN (Object:extend))
(local BOX (require :src._.cls.BOX))

(fn WIN.new [! parent name w h]
  (set !.name name)
  (set !.border [0.4 0.4 0.4])
  (set !.fill [0.2 0.2 0.2])
  (set !.top   (BOX 0 0 w 0.05 parent.inner))
  (set !.outer (BOX 0 0 w h parent.inner))
  (set !.inner (BOX 0.5 0.5 0.99 0.90 !.outer))
  (set !.bot   (BOX 0 1 w 0.05 parent.inner))
  (set !.depth (+ parent.depth 1))
  (set parent.child !))

(fn WIN.draw [!]
  (love.graphics.push)
  (love.graphics.setColor !.border)
  (love.graphics.push) (!.outer:draw) (love.graphics.pop)
  (love.graphics.stencil #(!.outer:draw) :increment 1 true)
  (love.graphics.setStencilTest :greater !.depth)
  (love.graphics.setColor !.fill)
  (!.inner:draw) 
  (love.graphics.setColor 1 1 1 1)
  (when !.child (!.child:draw))
  (love.graphics.setStencilTest)
  (love.graphics.pop))

(fn WIN.update [! dt] (when !.child (!.child:update dt)))

(fn WIN.mousemoved [! x y ...]
  (if (or (!.top:inside? x y) (!.bot:inside? x y))
      (set !.border [0.6 0.6 0.6])
      (set !.border [0.4 0.4 0.4])))

(fn WIN.event [! e ...]
  (when (and (= e :keypressed) (= ... :escape)) 
        (love.event.quit)) ;; TODO close windows then quit
    (let [in        #((. !.inner e) !.inner $...)
          out       #((. !.outer e) !.outer $...)
          apply     #(in (out $...))
          transform (if (. BOX e) apply #$)]
      (when (. ! e) ((. ! e) ! (out ...)))
      (when !.child (!.child:event e (transform ...)))))

WIN
