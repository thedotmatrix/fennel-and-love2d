(local ROM (require :classes.ROM))
(local Empty (ROM:extend))

(fn Empty.load [!]
  (set !.b 42)
  (set !.next :empty2))

Empty
