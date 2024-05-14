(local fennel (require :lib.fennel))
(local stdio (require :lib.stdio))
(require :love.event)
(local input [])
(local output [])
(var incomplete? false)
(var repl nil)
(var std false)

(fn out [xs] (icollect [_ x (ipairs xs) :into output] x))
(fn err [_errtype msg]
  (each [line (msg:gmatch "([^\n]+)")]
    (table.insert output [[0.9 0.4 0.5] line])))
(fn _G.print [...] (out [...]) nil)
(fn inp [stdin in] 
  (when std (io.stdout:write in))
  (when (~= in "\n") (print [[0.5 0.4 0.9] in])))

;; create the repl hooking into stdio if available, otherwise standalone repl
;; start it using the options table OR setup stdio event callbacks
(fn start [web?]
  (if web? 
    (do 
      (set repl (coroutine.create (partial fennel.repl)))
      (coroutine.resume repl {
        :readChunk coroutine.yield 
        :onValues out 
        :onError err}))
    (do
      (set repl (stdio.start))
      (set std true)
      (set love.handlers.inp inp)
      (set love.handlers.vals out)
      (set love.handlers.err err))))

(fn enter []
  (let [input-text (table.concat (doto input (table.insert "\n")))
        _ (inp std input-text)
        (_ {: stack-size}) (coroutine.resume repl input-text)]
        ;; clear the input table afterwards
        (while (next input) (table.remove input))
        (set incomplete? (< 0 stack-size))))

(fn keypressed [key]
  (match key
    :return (enter)
    :backspace (table.remove input)))

(fn textinput [text] (table.insert input text))

(fn draw [] ;; FIXME wrong (w h)
  (let [(w h) (love.window.getMode)
        fh (: (love.graphics.getFont) :getHeight)]
        ;; draw every line in the output (wasteful but easy)
        (for [i (length output) 1 -1]
          (match (. output i) line (love.graphics.print line 2 (* i (+ fh 2)))))
        ;; draw the input text at the bottom
        (love.graphics.line 0 (- h fh 4) w (- h fh 4))
        ;; prompt character
        (if incomplete?
          (love.graphics.print "_ " 2 (- h fh 2))
          (love.graphics.print "> " 2 (- h fh 2)))
        (love.graphics.print (table.concat input) 15 (- h fh 2))))

{: start : keypressed : textinput : draw }
