(import-macros {: decf : incf} :mac.math)
(local RST (require :classes.RST))
(local REPL (RST:extend))
(local fennel (require :lib.fennel))

(fn REPL.draw [! canvas]
  (let [w     (canvas:getWidth)
        h     (canvas:getHeight)
        f     (love.graphics.getFont)
        fh    (f:getHeight)
        limit (math.ceil (* (/ h fh) 0.75))
        len   (length !.output)]
    (love.graphics.clear 0 0 0 1)
    (love.graphics.setColor 1 1 1 1)
    (love.graphics.printf (.. "FPS: " (love.timer.getFPS)) 0 0 w :left)
    (var i len)
    (var lst (if (> (- len limit) 0) (- len limit) 1))
    (while (>= i lst)
      (match (. !.output i) line
        (let [lines (math.floor (/ (f:getWidth (tostring line)) w))]
          (love.graphics.printf line 2 (* (+ (- i lst lines) 1) (+ fh 2)) w)
          (decf i 1)
          (incf lst lines))))
    (love.graphics.line 0 (- h fh 4) w (- h fh 4))
    (if !.incomplete?
      (love.graphics.print "_ " 2 (- h fh 2))
      (love.graphics.print "> " 2 (- h fh 2)))
    (love.graphics.print (table.concat !.input) 15 (- h fh 2))))

REPL
