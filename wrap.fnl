(local fennel (require :lib.fennel))
(require :love.event)
(local (w h) (love.window.getMode))
(var scale 1)
(local windows {:l nil :r nil})
(local canvasl (love.graphics.newCanvas (/ w 2) h))
(local canvasr (love.graphics.newCanvas (/ w 2) h))

(fn enter-monad [window name ...]
  (let [monad (require name)]
    (tset windows window {:monad monad :name name})
    (when monad.activate
      (match (pcall monad.activate ...)
        (false msg) (print name "activate error" msg)))))
(fn safely [func name] 
  (xpcall func #(enter-monad :monads.error name $ (fennel.traceback))))

(fn love.load [args]
  (enter-monad :l :monads.repl)
  (enter-monad :r :monads.editor)
  (canvasl:setFilter "nearest" "nearest")
  (canvasr:setFilter "nearest" "nearest")
  (love.event.push "repl" (= :web (. args 1))))

(fn love.draw []
  (love.graphics.setCanvas canvasl)
  (love.graphics.clear 0.2 0.2 0.2 1)
  (love.graphics.setColor 1 1 1 1)
  (safely windows.l.monad.draw windows.l.name)
  (love.graphics.setCanvas canvasr)
  (love.graphics.clear 0.8 0.8 0.8 1)
  (love.graphics.setColor 0 0 0 1)
  (safely windows.r.monad.draw windows.r.name)
  (love.graphics.setCanvas)
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.draw canvasl 0 0 0 scale scale)
  (love.graphics.draw canvasr (/ w 2) 0 0 scale scale))

(fn love.update [dt]
  (when windows.l.monad.update 
    (safely #(windows.l.monad.update dt) windows.l.name))
  (when windows.r.monad.update 
    (safely #(windows.r.monad.update dt) windows.r.name)))

(fn love.keypressed [key]
  (if (and (love.keyboard.isDown "lctrl" "rctrl") (= key "q"))
      (love.event.quit)
      (let [lfunc windows.l.monad.keypressed
            lname windows.l.name
            rfunc windows.r.monad.keypressed
            rname windows.l.name]
            (when lfunc (safely #(lfunc key) lname))
            (when rfunc (safely #(rfunc key) rname)))))

(fn love.textinput [text]
  (when windows.l.monad.textinput 
    (safely #(windows.l.monad.textinput text) windows.l.name)))
