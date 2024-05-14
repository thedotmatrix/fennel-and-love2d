(local fennel (require :lib.fennel))
(require :love.event)

(fn prompt [cont?]
  (io.write (if cont? ".." ">> ")) 
  (io.flush) 
  (.. (tostring (io.read)) "\n"))

(fn looper [event channel]
  (match (channel:demand)
    [:write vals] (do (io.write (table.concat vals "\t")) (io.write "\n"))
    [:read cont?] (love.event.push event (prompt cont?)))
  (looper event channel))

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
        (set love.handlers.eval (fn [input] (coroutine.resume coro input)))
        (coroutine.resume coro options)
        (thread:start "eval" io-channel)
        coro))

;; nil on require, loop initialized on coroutine creation
(match ... (event channel) (looper event channel))
{: start}
