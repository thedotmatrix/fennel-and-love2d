(local ROM (require :classes.ROM))
(local Empty (ROM:extend))

(fn Empty.load [!]
  (set !.a nil)
  (set !.b 69))

(fn Empty.keypressed [!! ! key scancode repeat?] (match key
  :space (error "here")));(!! [:default :main])))

Empty
