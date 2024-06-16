(import-macros {: decf : incf} :mac.math)
(local fennel (require :lib.fennel))
(local RST (require :src._.cls.RST))
(local REPL (RST:extend))

(fn REPL.load [!]
  (set !.input [])
  (set !.output [])
  (set _G.print (fn [...] ((REPL.out !) [...])))
  (when (not _G.web?) (do ;; TODO love.js repl?
    (set !.repl (coroutine.create (partial fennel.repl)))
    (coroutine.resume !.repl {:readChunk  coroutine.yield 
                              :onValues   (REPL.out !)
                              :onError    (REPL.err !)}))))

(fn REPL.out [!] (fn [xs]
  (icollect [_ x (ipairs xs) :into !.output] x)))

(fn REPL.err [!] (fn [_errtype msg]
  (each [line (msg:gmatch "([^\n]+)")]
    (table.insert !.output [[0.9 0.4 0.5] line]))))

(fn REPL.draw [! w h]
  (let [f     (love.graphics.getFont)
        fh    (f:getHeight)
        limit (math.ceil (* (/ h fh) 0.75))
        len   (length !.output)
        fps   (.. "FPS: " (love.timer.getFPS))]
    (love.graphics.setColor 0 0 0 1)
    (love.graphics.rectangle :fill 0 0 w h)
    (love.graphics.setColor 1 1 1 1)
    (love.graphics.printf fps 0 0 w :left)
    (var i len)
    (var lst (if (> (- len limit) 0) (- len limit) 1))
    (while (>= i lst)
      (match (. !.output i) line
        (let [linewidth (f:getWidth (tostring line))
              lines     (math.floor (/ linewidth w))
              lineh     (* (+ (- i lst lines) 1) (+ fh 2))]
          (love.graphics.printf line 2 lineh w)
          (decf i 1)
          (incf lst lines))))
    (let [top     (- h fh 4)
          center  (- h fh 2)
          current (table.concat !.input)]
      (love.graphics.line 0 top w top)
      (if !.incomplete?
        (love.graphics.print "_ " 2 center)
        (love.graphics.print "> " 2 center))
      (love.graphics.print current 15 center))))

REPL
