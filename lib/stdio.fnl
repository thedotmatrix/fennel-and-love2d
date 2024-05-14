(local fennel (require :lib.fennel))
(require :love.event)

;; FIXME blocking io -> delayed / out of order stdout waiting for stdin
;; repl works fine from both the console and the GUI
;; but the console output is terrible
;; not using this much, so low priority fix imho
(fn prompt [cont?]
  (io.write (if cont? ".." ">> ")) 
  (io.flush)
  (.. (tostring (io.read)) "\n"))

(fn looper [loop channel]
  (match (channel:demand)
    [:write vals] (do (io.write (table.concat vals "\t")) (io.write "\n"))
    [:read cont?] (let [in (prompt cont?)]
      (love.event.push "inp" false in)
      (love.event.push loop in)))
  (looper loop channel))
(match ... (loop channel) (looper loop channel))

(fn start []
  (let [code (love.filesystem.read "lib/stdio.fnl")
        luac (love.filesystem.newFileData (fennel.compileString code) "io")
        thread (love.thread.newThread luac)
        io-channel (love.thread.newChannel)
        coro (coroutine.create (partial fennel.repl))
        options {
          :readChunk (fn [{: stack-size}] 
            (io-channel:push [:read (< 0 stack-size)])
            (coroutine.yield {: stack-size}))
          :onValues (fn [vals]
            (io-channel:push [:write vals])
            (love.event.push "vals" vals)) 
          :onError (fn [errtype err]
            (io-channel:push [:write [err]])
            (love.event.push "err" errtype err))}]
        (coroutine.resume coro options)
        (set love.handlers.eval (fn [input] (coroutine.resume coro input)))
        (thread:start "eval" io-channel)
        coro))

{: start}
