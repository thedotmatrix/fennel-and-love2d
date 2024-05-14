(local fennel (require :lib.fennel))
(require :love.event)
(import-macros {: incf} :macros.sample-macros)

; wrapper layout
(local (w h) (love.window.getMode))
(local canvasl (love.graphics.newCanvas (/ w 2) h))
(local canvasr (love.graphics.newCanvas (/ w 2) h))
(var scale 1)

; mode monads (TODO unsure how to polymorph over var type in fennel)
(var (model namel) nil)
(var (moder namer) nil)
(fn set-model [new-mode-name ...]
  (set (model namel) (values (require new-mode-name) new-mode-name))
    (when model.activate
      (match (pcall model.activate ...)
        (false msg) (print namel "activate error" msg))))
(fn set-moder [new-mode-name ...]
  (set (moder namer) (values (require new-mode-name) new-mode-name))
    (when moder.activate
      (match (pcall moder.activate ...)
        (false msg) (print namer "activate error" msg))))
(fn love.load [args]
  (set-model :monads.mode-repl)
  (set-moder :monads.mode-editor)
  (canvasl:setFilter "nearest" "nearest")
  (canvasr:setFilter "nearest" "nearest")
  (love.event.push "startrepl" (= :web (. args 1))))
(fn safelyl [f]
  (xpcall f #(set-model :monads.error-mode namel $ (fennel.traceback))))
(fn safelyr [f]
  (xpcall f #(set-moder :monads.error-mode namer $ (fennel.traceback))))

; love2d functions
(fn love.draw []
  ;; the canvas allows you to get sharp pixel-art style scaling; if you
  ;; don't want that, just skip that and call mode.draw directly.
  (love.graphics.setCanvas canvasl)
  (love.graphics.clear 0.2 0.2 0.2 1)
  (love.graphics.setColor 1 1 1 1)
  (safelyl model.draw)
  (love.graphics.setCanvas canvasr)
  (love.graphics.clear 0.8 0.8 0.8 1)
  (love.graphics.setColor 0 0 0 1)
  (safelyr moder.draw)
  (love.graphics.setCanvas)
  (love.graphics.setColor 1 1 1 1)
  (love.graphics.draw canvasl 0 0 0 scale scale)
  (love.graphics.draw canvasr (/ w 2) 0 0 scale scale))

(fn love.update [dt]
  (when model.update (safelyl #(model.update dt set-model)))
  (when moder.update (safelyr #(moder.update dt set-moder))))

(fn love.keypressed [key]
  (if (and (love.keyboard.isDown "lctrl" "rctrl" "capslock") (= key "q"))
      (love.event.quit)
      ;; add what each keypress should do in each mode
      (do 
        (when model.keypressed (safelyl #(model.keypressed key set-model)))
        (when moder.keypressed (safelyr #(moder.keypressed key set-moder))))))

(fn love.textinput [text]
  (when model.textinput (safelyl #(model.textinput text set-model))))
