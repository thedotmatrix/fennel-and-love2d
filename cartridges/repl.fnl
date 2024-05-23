(import-macros {: decf : incf} :mac.math)
(local Cartridge (require :classes.cartridge))
(local REPL (Cartridge:extend))
(local fennel (require :lib.fennel))
(local tst "1234567890123456789012345678901234567890123456789012345678901234")
(local msg "press [left ctrl] to show/hide")
(local input [])
(local output [])
(var incomplete? false)
(var stdio nil)
(var repl nil)

(fn out [xs] (icollect [_ x (ipairs xs) :into output] x))
(fn err [_errtype msg]
  (each [line (msg:gmatch "([^\n]+)")]
    (table.insert output [[0.9 0.4 0.5] line])))
(fn _G.print [...] (out [...]) nil)
(fn inp [in]
  (when (~= in "\n") (print [[0.5 0.4 0.9] in])))

(fn enter []
  (let [input-text (table.concat (doto input (table.insert "\n")))
        _ (inp input-text)]
    (when repl
      (local (_ {: stack-size}) (coroutine.resume repl input-text))
      (set incomplete? (< 0 stack-size)))
    (while (next input) (table.remove input))))

(fn keypressed [self key]
  (match key
    :return (enter)
    :backspace (table.remove input)))

(fn textinput [self text] (table.insert input text))

(fn draw [self w h] (fn []
  (let [f (love.graphics.getFont)
        fh (: f :getHeight)
        len (length output)]
    (love.graphics.clear 0 0 0 1)
    (love.graphics.setColor 1 1 1 1)
    (love.graphics.printf msg 0 0 w :center)
    (love.graphics.printf (.. "FPS: " (love.timer.getFPS)) 0 0 w :left)
    ;; draw the last 33 lines of output
    (var i len)
    (var lst (if (> (- len 32) 0) (- len 32) 1))
    (while (>= i lst)
      (match (. output i) line
        (let [getlines (fn [] (math.floor (/ (f:getWidth (tostring line)) w)))
              lines (getlines)]
          (love.graphics.printf line 2 (* (+ (- i lst lines) 1) (+ fh 2)) w)
          (decf i 1)
          (incf lst lines))))
    ;; draw the input text at the bottom
    (love.graphics.line 0 (- h fh 4) w (- h fh 4))
    ;; prompt character
    (if incomplete?
      (love.graphics.print "_ " 2 (- h fh 2))
      (love.graphics.print "> " 2 (- h fh 2)))
    (love.graphics.print (table.concat input) 15 (- h fh 2)))))

(tset REPL :new (fn [self w h web?]
  (self.super.new self) ;; discard old state
  (tset self :draw draw)
  (tset self :keypressed keypressed)
  (tset self :textinput textinput)
  (let [(success? _) (pcall #(set stdio (require :lib.stdio)))]
    (when success? (do
      (set repl (stdio.start))
      (set love.handlers.inp inp)
      (set love.handlers.vals out)
      (set love.handlers.err err))))
  ;; FIXME love.js does not support threads/coroutines afaik
  ; (when web? (do
  ;   (set repl (coroutine.create (partial fennel.repl)))
  ;   (coroutine.resume repl {:readChunk coroutine.yield 
  ;                           :onValues out  
  ;                           :onError err})))
  self))
REPL
