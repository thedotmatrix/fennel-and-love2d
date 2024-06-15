(local Object (require :lib.classic))
(local RST (Object:extend))

(fn RST.mix [a b ! mode]
  (a:implement b)
  (when ! (a.load !))
  a)

(fn RST.load [!])
(set RST.load nil)

(fn RST.draw [! canvas])
(set RST.draw nil)

RST
