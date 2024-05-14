;; since one of the strengths of Fennel is access to Lua frameworks, here's
;; a graphical REPL which runs inside LÖVE (https://love2d.org)

;; supports multiline input, showing errors in red, detecting incomplete input.
;; for a slightly more complex version which supports running inside a sandbox
;; see the wiki: https://github.com/bakpakin/Fennel/wiki/Repl
;; to run: fennel -c love-repl.fnl > main.lua && love .
(local fennel (require :lib.fennel))
(local stdio (require :lib.stdio))
(require :love.event)
(local input []) ; store characters as they are typed
(local buffer []) ; output that has been printed
(var incomplete? false)

;; put things into the output buffer
(fn out [xs] (icollect [_ x (ipairs xs) :into buffer] x))
(fn _G.print [...] (out [...]) nil) ; override global print to use our buffer

;; display errors in red (love2d-specific convention for colored text)
(fn err [_errtype msg]
  (each [line (msg:gmatch "([^\n]+)")]
    (table.insert buffer [[0.9 0.4 0.5] line])))

;; create the repl inside a coroutine OR hook into stdio repl instead
;; start it using the options table OR setup stdio event callbacks
(var repl nil)
(set love.handlers.startrepl (fn [web?] (if web? 
  (do 
    (set repl (coroutine.create (partial fennel.repl)))
    (coroutine.resume repl {:readChunk coroutine.yield :onValues out :onError err}))
  (do 
    (set repl (stdio.start))
    (set love.handlers.vals out)
    (set love.handlers.err err)))))

(fn enter []
  (let [input-text (table.concat (doto input (table.insert "\n")))
        ;; send the input to the repl
        (_ {: stack-size}) (coroutine.resume repl input-text)]
    (set incomplete? (< 0 stack-size))
  ;; clear the input table afterwards
  (while (next input) (table.remove input))))

{:keypressed (fn keypressed [key]
  (match key
    :return (enter)
    :backspace (table.remove input)))
 :textinput (fn textinput [text] (table.insert input text))
 :draw (fn draw []
  (let [(w h) (love.window.getMode)
        fh (: (love.graphics.getFont) :getHeight)]
    ;; draw every line in the buffer (wasteful but easy)
    (for [i (length buffer) 1 -1]
      (match (. buffer i)
        line (love.graphics.print line 2 (* i (+ fh 2)))))
    ;; draw the input text at the bottom
    (love.graphics.line 0 (- h fh 4) w (- h fh 4))
    (if incomplete? ; change the prompt character
        (love.graphics.print "- " 2 (- h fh 2))
        (love.graphics.print "> " 2 (- h fh 2)))
    (love.graphics.print (table.concat input) 15 (- h fh 2))))}
