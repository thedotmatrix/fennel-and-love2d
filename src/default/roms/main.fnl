(local ROM (require :classes.ROM))
(local Empty (ROM:extend))

(fn Empty.load [!]
  (set !.a 42))

(fn Empty.keypressed [!! ! key scancode repeat?] (match key
  :space (!! [:default :empty])))

Empty
