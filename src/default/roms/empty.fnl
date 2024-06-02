(local ROM (require :classes.ROM))
(local Empty (ROM:extend))

(fn Empty.load [!]
  (set !.b nil))

(fn Empty.keypressed [!! ! key scancode repeat?] (match key
  :space (!! :empty2)))

Empty
