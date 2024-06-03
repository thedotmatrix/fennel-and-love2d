(local ROM (require :classes.ROM))
(local Empty (ROM:extend))

(fn Empty.load [!]
  (set !.b nil)
  (set !.next :empty2))

Empty
