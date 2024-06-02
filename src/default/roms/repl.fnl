(local ROM (require :classes.ROM))
(local REPL (ROM:extend))
(local fennel (require :lib.fennel))

(fn inp [!] (fn [in]
  (when (~= in "\n") (print [[0.5 0.4 0.9] in]))))

(fn out [!] (fn [xs] 
  (icollect [_ x (ipairs xs) :into !.output] x)))

(fn err [!] (fn [_errtype msg]
  (each [line (msg:gmatch "([^\n]+)")]
    (table.insert !.output [[0.9 0.4 0.5] line]))))

(fn enter [!]
  (let [input-text (table.concat (doto !.input (table.insert "\n")))
        _ ((inp !) input-text)]
    (when !.repl
      (local (_ {: stack-size}) (coroutine.resume !.repl input-text))
      (set !.incomplete? (< 0 stack-size)))
    (while (next !.input) (table.remove !.input))))

(fn REPL.load [!]
  (let [(success? _) (pcall #(set !.stdio (require :lib.stdio)))]
    (when success? (do
      (set !.input [])
      (set !.output [])
      (set !.repl (!.stdio.start))
      (set love.handlers.inp (inp !))
      (set love.handlers.vals (out !))
      (set love.handlers.err (err !))
      (set _G.print (fn [...] ((out !) [...])))))))
;; TODO love.js does not support threads/coroutines afaik
; (when _G.web? (do
;   (set repl (coroutine.create (partial fennel.repl)))
;   (coroutine.resume repl {:readChunk coroutine.yield 
;                           :onValues out  
;                           :onError err})))

(fn REPL.keypressed [!! ! key scancode repeat?] (match key
    :return (enter !)
    :backspace (table.remove !.input)))

(fn REPL.textinput [!! ! text] (table.insert !.input text))

REPL
