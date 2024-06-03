(local ROM (require :classes.ROM))
(local Empty (ROM:extend))

(fn Empty.load [!]
  (set !.a nil)
  (set !.b 69)
  (set !.next :main)
  (when (> (love.math.random -1 1) 0) (error "random failure")))

Empty
