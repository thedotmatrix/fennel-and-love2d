(local ROM (require :src._.cls.ROM))
(local REPL (ROM:extend))

(fn REPL.textinput [!! ! text] (table.insert !.input text))

(fn REPL.keypressed [!! ! key scancode repeat?] 
  (match key
    :return (REPL.enter !)
    :backspace (table.remove !.input)))

(fn REPL.enter [!]
  (let [texts (doto !.input (table.insert "\n"))
        text (table.concat texts)
        _ ((REPL.inp !) text)]
    (when !.repl
      (let [(_ {: stack-size}) (coroutine.resume !.repl text)]
        (set !.incomplete? (< 0 stack-size))))
    (while (next !.input) (table.remove !.input))))

(fn REPL.inp [!] (fn [in]
  (when (~= in "\n") (print [[0.5 0.4 0.9] in]))))

REPL
