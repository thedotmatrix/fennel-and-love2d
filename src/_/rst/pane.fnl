(local BOX (require :src._.cls.BOX))
(local RST (require :src._.cls.RST))
(local Pane (RST:extend))

;; TODO multi-sub/focus
;; TODO CAB/RAM anti-pattern?
(fn Pane.load [! cab parent name x y w h]
  (set !.border [0.4 0.4 0.4]) (set !.fill [0.2 0.2 0.2])
  (set !.outer (BOX parent.live.ram.inner x y w h))
  (set !.top   (BOX !.outer 0 0 1 0.05))
  (set !.bot   (BOX !.outer 0 1 1 0.05))
  (set !.inner (BOX !.outer 0.5 0.5 0.99 0.90))
  (set !.name name) (set !.depth (+ parent.live.ram.depth 1))
  (set !.subs []) (table.insert parent.live.ram.subs cab))

;; TODO stencil buggy with multiple children
(fn Pane.draw [! w h] (love.graphics.push)
  (love.graphics.setColor !.border) (!.outer:draw true)
  (love.graphics.printf !.name 0 0 !.outer.aw :center)
  (love.graphics.stencil #(!.inner:draw) :increment 1 true)
  (love.graphics.setStencilTest :greater !.depth)
  (love.graphics.setColor !.fill) (!.inner:draw true)
  (love.graphics.setColor 1 1 1 1)
  (each [_ s (ipairs !.subs)] (s:draw !.inner.aw !.inner.ah))
  (love.graphics.setStencilTest) (love.graphics.pop))

Pane
